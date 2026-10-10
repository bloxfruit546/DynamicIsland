#import "DIPreferencesManager.h"
#import <notify.h>

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    [[DIPreferencesManager sharedInstance] reloadPreferences];
}

@implementation DIPreferencesManager

+ (instancetype)sharedInstance {
    static DIPreferencesManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
        [shared reloadPreferences];
        
        // Listen to Darwin notifications from Settings app
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            NULL,
            PreferencesChangedCallback,
            CFSTR("com.dev.dynamicisland/ReloadPrefs"),
            NULL,
            CFNotificationSuspensionBehaviorCoalesce
        );
        
        // In-process fallback
        [[NSNotificationCenter defaultCenter] addObserver:shared
                                                 selector:@selector(reloadPreferences)
                                                     name:@"com.dev.dynamicisland/ReloadPrefs"
                                                   object:nil];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isEnabled = YES;
        _showNotifications = YES;
        _showMusic = YES;
        _showCalls = YES;
        _autoCollapseDelay = 4.0;
        _hapticFeedback = YES;
    }
    return self;
}

- (void)reloadPreferences {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:kDIPrefsPath];
    if (!prefs) return;
    
    if (prefs[@"isEnabled"] != nil)           self.isEnabled = [prefs[@"isEnabled"] boolValue];
    if (prefs[@"showNotifications"] != nil)   self.showNotifications = [prefs[@"showNotifications"] boolValue];
    if (prefs[@"showMusic"] != nil)           self.showMusic = [prefs[@"showMusic"] boolValue];
    if (prefs[@"showCalls"] != nil)           self.showCalls = [prefs[@"showCalls"] boolValue];
    if (prefs[@"autoCollapseDelay"] != nil)   self.autoCollapseDelay = [prefs[@"autoCollapseDelay"] doubleValue];
    if (prefs[@"hapticFeedback"] != nil)      self.hapticFeedback = [prefs[@"hapticFeedback"] boolValue];
    
    NSLog(@"[DynamicIsland] Preferences reloaded: enabled=%d, notifs=%d, music=%d, calls=%d",
          self.isEnabled, self.showNotifications, self.showMusic, self.showCalls);
}

- (void)dealloc {
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, CFSTR("com.dev.dynamicisland/ReloadPrefs"), NULL);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
