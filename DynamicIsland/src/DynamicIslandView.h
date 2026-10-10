#import <UIKit/UIKit.h>
#import "DIActivityManager.h"

@interface DynamicIslandView : UIView <DIActivityManagerDelegate>

@property (nonatomic, readonly) DIIslandState islandState;

- (instancetype)initWithSuperview:(UIView *)superview;
- (void)showCompact;
- (void)showExpandedWithContent:(DIActivityContent *)content;
- (void)hideIsland;
- (void)revealIsland;

@end
