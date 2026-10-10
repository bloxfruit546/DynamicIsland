#import "DIAnimator.h"

@implementation DIAnimator

+ (void)animateView:(UIView *)view
            toFrame:(CGRect)frame
       cornerRadius:(CGFloat)radius
         completion:(void(^)(BOOL finished))completion {
    
    [UIView animateWithDuration:0.45
                          delay:0
         usingSpringWithDamping:0.72
          initialSpringVelocity:0.3
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
        view.frame = frame;
        view.layer.cornerRadius = radius;
    } completion:completion];
}

+ (void)fadeInView:(UIView *)view delay:(NSTimeInterval)delay {
    view.alpha = 0;
    [UIView animateWithDuration:0.22
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        view.alpha = 1.0;
    } completion:nil];
}

+ (void)fadeOutView:(UIView *)view completion:(void(^)(BOOL finished))completion {
    [UIView animateWithDuration:0.18
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        view.alpha = 0;
    } completion:completion];
}

+ (void)pulseShadow:(UIView *)view {
    CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
    pulse.fromValue    = @(0.0f);
    pulse.toValue      = @(12.0f);
    pulse.duration     = 0.2;
    pulse.autoreverses = YES;
    pulse.repeatCount  = 1;
    view.layer.shadowColor   = [UIColor whiteColor].CGColor;
    view.layer.shadowOpacity = 0.35f;
    [view.layer addAnimation:pulse forKey:@"pulseShadow"];
}

+ (void)bounceTap:(UIView *)view {
    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        view.transform = CGAffineTransformMakeScale(0.96f, 0.96f);
    } completion:^(BOOL f) {
        [UIView animateWithDuration:0.15
             usingSpringWithDamping:0.5
              initialSpringVelocity:0.8
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
            view.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}

@end
