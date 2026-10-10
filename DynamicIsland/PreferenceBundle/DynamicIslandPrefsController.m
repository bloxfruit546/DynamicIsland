#import "DynamicIslandPrefsController.h"
#import <notify.h>

@implementation DynamicIslandPrefsController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

- (void)respring {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"Respring"
                         message:@"Respring để áp dụng thay đổi?"
                  preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Respring"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction *a) {
        notify_post("com.apple.language.changed");
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Huỷ"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

// Called when any preference changes
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // Notify tweak to reload prefs
    notify_post("com.dev.dynamicisland/ReloadPrefs");
}

@end
