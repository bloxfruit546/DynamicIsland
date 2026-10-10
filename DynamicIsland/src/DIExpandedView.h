#import <UIKit/UIKit.h>
#import "DIActivityManager.h"

@interface DIExpandedView : UIView

- (void)updateWithContent:(DIActivityContent *)content;
- (void)clearContent;

@end
