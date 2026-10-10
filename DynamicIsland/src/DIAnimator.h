#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface DIAnimator : NSObject

+ (void)animateView:(UIView *)view
            toFrame:(CGRect)frame
       cornerRadius:(CGFloat)radius
         completion:(void(^)(BOOL finished))completion;

+ (void)fadeInView:(UIView *)view delay:(NSTimeInterval)delay;
+ (void)fadeOutView:(UIView *)view completion:(void(^)(BOOL finished))completion;
+ (void)pulseShadow:(UIView *)view;
+ (void)bounceTap:(UIView *)view;

@end
