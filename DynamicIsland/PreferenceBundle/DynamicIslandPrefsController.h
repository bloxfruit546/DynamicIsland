#import <UIKit/UIKit.h>

#if __has_include(<Preferences/PSListController.h>)
#import <Preferences/PSListController.h>
#else
@interface PSViewController : UIViewController
@end

@interface PSListController : PSViewController {
    id _specifiers;
}
- (id)loadSpecifiersFromPlistName:(NSString *)name target:(id)target;
@property (nonatomic, retain) id specifiers;
@end
#endif

@interface DynamicIslandPrefsController : PSListController
@end
