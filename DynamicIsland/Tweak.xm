#import <UIKit/UIKit.h>
#import "src/DIWindowController.h"
#import "src/DIActivityManager.h"
#import "src/DINotificationProvider.h"
#import "src/DIMusicProvider.h"
#import "src/DICallProvider.h"
#import "src/DIPreferencesManager.h"

// ─────────────────────────────────────────────────────────────
// Hook 1: SpringBoard – Initialize everything on SpringBoard launch
// ─────────────────────────────────────────────────────────────
%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    @try {
        if (![DIPreferencesManager sharedInstance].isEnabled) return;
        
        [[DIWindowController sharedInstance] setupWindow];
        [[DIMusicProvider sharedInstance] startMonitoring];
        [[DICallProvider sharedInstance] startMonitoring];
        
        NSLog(@"[DynamicIsland] Initialized successfully in SpringBoard");
    } @catch (NSException *e) {
        NSLog(@"[DynamicIsland] Init exception: %@", e);
    }
}

%end

// ─────────────────────────────────────────────────────────────
// Hook 2: SBNotificationBannerDestination – iOS 12 notifications
// ─────────────────────────────────────────────────────────────
%hook SBNotificationBannerDestination

- (void)postNotificationRequest:(id)request forCoalescedNotification:(id)coalesced {
    %orig;
    @try {
        if (![DIPreferencesManager sharedInstance].isEnabled) return;
        if (![DIPreferencesManager sharedInstance].showNotifications) return;
        
        [[DINotificationProvider sharedInstance] handleBannerRequest:request];
    } @catch (NSException *e) {
        NSLog(@"[DynamicIsland] SBNotificationBannerDestination exception: %@", e);
    }
}

%end

// ─────────────────────────────────────────────────────────────
// Hook 3: SBBannerController – Legacy / fallback banner hook
// ─────────────────────────────────────────────────────────────
%hook SBBannerController

- (void)observer:(id)observer
    addBannerWithRequest:(id)request
           forAssertion:(id)assertion {
    %orig;
    
    @try {
        if (![DIPreferencesManager sharedInstance].isEnabled) return;
        if (![DIPreferencesManager sharedInstance].showNotifications) return;
        
        [[DINotificationProvider sharedInstance] handleBannerRequest:request];
    } @catch (NSException *e) {
        NSLog(@"[DynamicIsland] SBBannerController exception: %@", e);
    }
}

%end

// ─────────────────────────────────────────────────────────────
// Hook 4: MPNowPlayingInfoCenter – Music updates
// ─────────────────────────────────────────────────────────────
%hook MPNowPlayingInfoCenter

- (void)setNowPlayingInfo:(NSDictionary *)nowPlayingInfo {
    %orig;
    
    @try {
        if (![DIPreferencesManager sharedInstance].isEnabled) return;
        if (![DIPreferencesManager sharedInstance].showMusic) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[DIMusicProvider sharedInstance] updateWithInfo:nowPlayingInfo];
        });
    } @catch (NSException *e) {
        NSLog(@"[DynamicIsland] NowPlaying hook exception: %@", e);
    }
}

%end

// ─────────────────────────────────────────────────────────────
// Hook 5: SBLockScreenManager – Hide island when lockscreen active
// ─────────────────────────────────────────────────────────────
%hook SBLockScreenManager

- (void)setIsUILocked:(BOOL)locked {
    %orig;
    @try {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[DIWindowController sharedInstance] setHidden:locked];
        });
    } @catch (NSException *e) {
        NSLog(@"[DynamicIsland] LockScreen hook exception: %@", e);
    }
}

%end

// ─────────────────────────────────────────────────────────────
// Constructor – safely initialize hooks
// ─────────────────────────────────────────────────────────────
%ctor {
    @autoreleasepool {
        NSLog(@"[DynamicIsland] Tweak dylib injected into %@",
              [[NSProcessInfo processInfo] processName]);
        %init;
    }
}
