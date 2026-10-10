#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kDIPrefsDomain @"com.dev.dynamicisland"
#define kDIPrefsPath @"/var/mobile/Library/Preferences/com.dev.dynamicisland.plist"

@interface DIPreferencesManager : NSObject

@property (nonatomic, assign) BOOL isEnabled;
@property (nonatomic, assign) BOOL showNotifications;
@property (nonatomic, assign) BOOL showMusic;
@property (nonatomic, assign) BOOL showCalls;
@property (nonatomic, assign) NSTimeInterval autoCollapseDelay;
@property (nonatomic, assign) BOOL hapticFeedback;

+ (instancetype)sharedInstance;
- (void)reloadPreferences;

@end
