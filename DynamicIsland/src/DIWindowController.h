#import <UIKit/UIKit.h>

@interface DIWindowController : NSObject

+ (instancetype)sharedInstance;
- (void)setupWindow;
- (void)setHidden:(BOOL)hidden;

@end
