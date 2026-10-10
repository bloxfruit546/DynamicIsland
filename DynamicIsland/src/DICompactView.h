#import <UIKit/UIKit.h>

@interface DICompactView : UIView

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel     *statusLabel;

- (void)showIcon:(UIImage *)icon statusText:(NSString *)text;
- (void)showDefault;

@end
