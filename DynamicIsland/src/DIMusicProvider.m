#import "DIMusicProvider.h"
#import "DIActivityManager.h"
#import "DIPreferencesManager.h"
#import <dlfcn.h>

typedef void (*MRRegisterFunc)(dispatch_queue_t queue);
typedef void (*MRGetInfoFunc)(dispatch_queue_t queue, void (^callback)(CFDictionaryRef information));
typedef void (*MRGetIsPlayingFunc)(dispatch_queue_t queue, void (^callback)(Boolean isPlaying));

@interface DIMusicProvider ()
@property (nonatomic, assign) BOOL isMonitoring;
@end

@implementation DIMusicProvider

+ (instancetype)sharedInstance {
    static DIMusicProvider *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (void)startMonitoring {
    if (_isMonitoring) return;
    _isMonitoring = YES;
    
    // 1. Dynamic MediaRemote setup (works for Spotify, YouTube, Apple Music, etc.)
    void *mr = dlopen("/System/Library/PrivateFrameworks/MediaRemote.framework/MediaRemote", RTLD_NOW);
    if (mr) {
        MRRegisterFunc reg = (MRRegisterFunc)dlsym(mr, "MRMediaRemoteRegisterForNowPlayingNotifications");
        if (reg) {
            reg(dispatch_get_main_queue());
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mediaRemoteDidChange:)
                                                     name:@"kMRMediaRemoteNowPlayingInfoDidChangeNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mediaRemoteDidChange:)
                                                     name:@"kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification"
                                                   object:nil];
    }
    
    // 2. MPMusicPlayerController backup observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(nowPlayingChanged:)
                                                 name:@"MPMusicPlayerControllerNowPlayingItemDidChangeNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateChanged:)
                                                 name:@"MPMusicPlayerControllerPlaybackStateDidChangeNotification"
                                               object:nil];
}

- (void)stopMonitoring {
    _isMonitoring = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)mediaRemoteDidChange:(NSNotification *)note {
    void *mr = dlopen("/System/Library/PrivateFrameworks/MediaRemote.framework/MediaRemote", RTLD_NOW);
    if (!mr) return;
    
    MRGetIsPlayingFunc getIsPlaying = (MRGetIsPlayingFunc)dlsym(mr, "MRMediaRemoteGetNowPlayingApplicationIsPlaying");
    MRGetInfoFunc getInfo = (MRGetInfoFunc)dlsym(mr, "MRMediaRemoteGetNowPlayingInfo");
    
    if (getIsPlaying) {
        getIsPlaying(dispatch_get_main_queue(), ^(Boolean isPlaying) {
            if (!isPlaying) {
                [[DIActivityManager sharedInstance] clearContentOfType:DIActivityTypeMusic];
                return;
            }
            if (getInfo) {
                getInfo(dispatch_get_main_queue(), ^(CFDictionaryRef infoRef) {
                    NSDictionary *dict = (__bridge NSDictionary *)infoRef;
                    [self updateWithInfo:dict];
                });
            }
        });
    } else if (getInfo) {
        getInfo(dispatch_get_main_queue(), ^(CFDictionaryRef infoRef) {
            NSDictionary *dict = (__bridge NSDictionary *)infoRef;
            [self updateWithInfo:dict];
        });
    }
}

- (void)nowPlayingChanged:(NSNotification *)notif {
    [self updateFromCurrentItem];
}

- (void)playbackStateChanged:(NSNotification *)notif {
    MPMusicPlayerController *player = [MPMusicPlayerController systemMusicPlayer];
    BOOL isPlaying = (player.playbackState == MPMusicPlaybackStatePlaying);
    if (!isPlaying) {
        [[DIActivityManager sharedInstance] clearContentOfType:DIActivityTypeMusic];
    } else {
        [self updateFromCurrentItem];
    }
}

- (void)updateFromCurrentItem {
    MPMusicPlayerController *player = [MPMusicPlayerController systemMusicPlayer];
    MPMediaItem *item = player.nowPlayingItem;
    if (!item) {
        [[DIActivityManager sharedInstance] clearContentOfType:DIActivityTypeMusic];
        return;
    }
    
    NSString *title  = [item valueForProperty:MPMediaItemPropertyTitle] ?: @"Unknown";
    NSString *artist = [item valueForProperty:MPMediaItemPropertyArtist] ?: @"";
    MPMediaItemArtwork *artworkObj = [item valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *artwork = [artworkObj imageWithSize:CGSizeMake(68, 68)];
    
    NSDictionary *info = @{
        @"title": title,
        @"artist": artist,
        @"artwork": artwork ?: [NSNull null]
    };
    [self updateWithInfo:info];
}

- (void)updateWithInfo:(NSDictionary *)nowPlayingInfo {
    if (![DIPreferencesManager sharedInstance].showMusic) return;
    if (!nowPlayingInfo || nowPlayingInfo.count == 0) {
        [[DIActivityManager sharedInstance] clearContentOfType:DIActivityTypeMusic];
        return;
    }
    
    @try {
        NSString *title = nowPlayingInfo[@"kMRMediaRemoteNowPlayingInfoTitle"]
                       ?: nowPlayingInfo[MPMediaItemPropertyTitle]
                       ?: nowPlayingInfo[@"title"]
                       ?: @"";
        NSString *artist = nowPlayingInfo[@"kMRMediaRemoteNowPlayingInfoArtist"]
                        ?: nowPlayingInfo[MPMediaItemPropertyArtist]
                        ?: nowPlayingInfo[@"artist"]
                        ?: @"";
        
        if (title.length == 0 && artist.length == 0) {
            [[DIActivityManager sharedInstance] clearContentOfType:DIActivityTypeMusic];
            return;
        }
        
        DIActivityContent *content = [[DIActivityContent alloc] init];
        content.type      = DIActivityTypeMusic;
        content.isOngoing = YES;
        content.title     = (title.length > 0) ? title : @"Playing";
        content.subtitle  = artist;
        
        id artworkData = nowPlayingInfo[@"kMRMediaRemoteNowPlayingInfoArtworkData"];
        if ([artworkData isKindOfClass:[NSData class]]) {
            content.artwork = [UIImage imageWithData:(NSData *)artworkData];
        } else {
            id art = nowPlayingInfo[MPMediaItemPropertyArtwork] ?: nowPlayingInfo[@"artwork"];
            if ([art isKindOfClass:[MPMediaItemArtwork class]]) {
                content.artwork = [(MPMediaItemArtwork *)art imageWithSize:CGSizeMake(68, 68)];
            } else if ([art isKindOfClass:[UIImage class]]) {
                content.artwork = art;
            }
        }
        
        [[DIActivityManager sharedInstance] presentContent:content];
    } @catch (NSException *e) {
        NSLog(@"[DynamicIsland] Music provider error: %@", e);
    }
}

@end
