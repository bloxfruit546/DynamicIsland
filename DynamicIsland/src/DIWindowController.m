#import "DIWindowController.h"
#import "DynamicIslandView.h"

// Custom UIWindow that passes touches through empty areas
@interface DIPillWindow : UIWindow
@end

@implementation DIPillWindow

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    // If the hit is the window itself or root VC view → transparent (pass through)
    if (hit == self || hit == self.rootViewController.view) {
        return nil;
    }
    return hit;
}

@end

// Transparent root view controller
@interface DIRootViewController : UIViewController
@end

@implementation DIRootViewController

- (void)loadView {
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.userInteractionEnabled = YES;
}

- (BOOL)prefersStatusBarHidden { return NO; }
- (UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleLightContent; }

@end

// Main controller
@interface DIWindowController ()
@property (nonatomic, strong) DIPillWindow        *window;
@property (nonatomic, strong) DynamicIslandView   *islandView;
@end

@implementation DIWindowController

+ (instancetype)sharedInstance {
    static DIWindowController *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (void)setupWindow {
    dispatch_async(dispatch_get_main_queue(), ^{
        @try {
            CGRect screenBounds = [UIScreen mainScreen].bounds;
            
            self.window = [[DIPillWindow alloc] initWithFrame:screenBounds];
            self.window.windowLevel       = UIWindowLevelStatusBar + 200;
            self.window.backgroundColor   = [UIColor clearColor];
            self.window.userInteractionEnabled = YES;
            self.window.hidden            = NO;
            
            DIRootViewController *rootVC = [[DIRootViewController alloc] init];
            self.window.rootViewController = rootVC;
            
            self.islandView = [[DynamicIslandView alloc] initWithSuperview:rootVC.view];
            [rootVC.view addSubview:self.islandView];
            
            [self.window makeKeyAndVisible];
            
            NSLog(@"[DynamicIsland] Window setup complete");
        } @catch (NSException *e) {
            NSLog(@"[DynamicIsland] setupWindow exception: %@", e);
        }
    });
}

- (void)setHidden:(BOOL)hidden {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (hidden) {
            [self.islandView hideIsland];
        } else {
            [self.islandView revealIsland];
        }
    });
}

@end
