#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface DIMusicProvider : NSObject

+ (instancetype)sharedInstance;
- (void)startMonitoring;
- (void)stopMonitoring;
- (void)updateWithInfo:(NSDictionary *)nowPlayingInfo;

@end
