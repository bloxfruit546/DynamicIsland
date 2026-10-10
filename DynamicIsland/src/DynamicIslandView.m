#import "DynamicIslandView.h"
#import "DICompactView.h"
#import "DIExpandedView.h"
#import "DIAnimator.h"
#import "DIPreferencesManager.h"

// Layout constants for iPhone 5s (320pt wide, 568pt tall)
static const CGFloat kPillWidth      = 112.0f;
static const CGFloat kPillHeight     = 30.0f;
static const CGFloat kPillRadius     = 15.0f;
static const CGFloat kPillTopOffset  = 4.0f;   // From top of screen

static const CGFloat kExpandedWidth  = 296.0f;
static const CGFloat kExpandedHeight = 84.0f;
static const CGFloat kExpandedRadius = 20.0f;

@interface DynamicIslandView ()
@property (nonatomic, strong) DICompactView    *compactView;
@property (nonatomic, strong) DIExpandedView   *expandedView;
@property (nonatomic, assign) DIIslandState     islandState;
@property (nonatomic, weak)   UIView           *parentView;
@end

@implementation DynamicIslandView

- (instancetype)initWithSuperview:(UIView *)superview {
    CGFloat screenW = superview.bounds.size.width;
    if (screenW <= 0) screenW = [UIScreen mainScreen].bounds.size.width;
    
    CGRect initialFrame = CGRectMake(
        (screenW - kPillWidth) / 2.0f,
        kPillTopOffset,
        kPillWidth,
        kPillHeight
    );
    
    self = [super initWithFrame:initialFrame];
    if (self) {
        _parentView   = superview;
        _islandState  = DIIslandStateCompact;
        [self setupView];
        [self setupGestures];
        [DIActivityManager sharedInstance].delegate = self;
    }
    return self;
}

- (void)setupView {
    self.backgroundColor        = [UIColor blackColor];
    self.layer.cornerRadius     = kPillRadius;
    self.layer.masksToBounds    = NO;
    self.clipsToBounds          = NO;
    
    // Smooth shadow surrounding the island
    self.layer.shadowColor      = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity    = 0.45f;
    self.layer.shadowOffset     = CGSizeMake(0, 3);
    self.layer.shadowRadius     = 6;
    
    // Compact view
    _compactView = [[DICompactView alloc] initWithFrame:self.bounds];
    _compactView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_compactView];
    
    // Expanded view (hidden initially)
    _expandedView = [[DIExpandedView alloc] initWithFrame:self.bounds];
    _expandedView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _expandedView.alpha  = 0;
    _expandedView.hidden = YES;
    [self addSubview:_expandedView];
}

- (void)setupGestures {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(handleTap:)];
    [self addGestureRecognizer:tap];
    
    UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.4;
    [self addGestureRecognizer:longPress];
}

#pragma mark - Public API

- (void)showCompact {
    if (_islandState == DIIslandStateCompact) return;
    _islandState = DIIslandStateCompact;
    
    CGFloat screenW = _parentView ? _parentView.bounds.size.width : [UIScreen mainScreen].bounds.size.width;
    CGRect compactFrame = CGRectMake(
        (screenW - kPillWidth) / 2.0f,
        kPillTopOffset,
        kPillWidth,
        kPillHeight
    );
    
    [DIAnimator fadeOutView:_expandedView completion:^(BOOL f) {
        self.expandedView.hidden = YES;
        [self.expandedView clearContent];
    }];
    
    [DIAnimator animateView:self toFrame:compactFrame cornerRadius:kPillRadius completion:^(BOOL f) {
        self.compactView.alpha = 1;
    }];
}

- (void)showExpandedWithContent:(DIActivityContent *)content {
    _islandState = DIIslandStateExpanded;
    
    CGFloat screenW   = _parentView ? _parentView.bounds.size.width : [UIScreen mainScreen].bounds.size.width;
    CGFloat expHeight = kExpandedHeight;
    
    // Music needs slightly more height for artwork + controls
    if (content.type == DIActivityTypeMusic) {
        expHeight = 88.0f;
    }
    
    CGRect expandedFrame = CGRectMake(
        (screenW - kExpandedWidth) / 2.0f,
        kPillTopOffset,
        kExpandedWidth,
        expHeight
    );
    
    self.compactView.alpha = 0;
    
    _expandedView.frame  = CGRectMake(0, 0, kExpandedWidth, expHeight);
    _expandedView.hidden = NO;
    [_expandedView updateWithContent:content];
    
    [DIAnimator animateView:self toFrame:expandedFrame cornerRadius:kExpandedRadius completion:nil];
    [DIAnimator fadeInView:_expandedView delay:0.15];
    [DIAnimator pulseShadow:self];
}

- (void)hideIsland {
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
        self.transform = CGAffineTransformMakeScale(0.92f, 0.92f);
    }];
}

- (void)revealIsland {
    [UIView animateWithDuration:0.3
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.3
                        options:0
                     animations:^{
        self.alpha     = 1;
        self.transform = CGAffineTransformIdentity;
    } completion:nil];
}

#pragma mark - Gesture Handlers

- (void)handleTap:(UITapGestureRecognizer *)tap {
    [DIAnimator bounceTap:self];
    
    DIActivityContent *current = [DIActivityManager sharedInstance].currentContent;
    
    if (_islandState == DIIslandStateExpanded) {
        // If content has a bundle ID, launch that app on tap
        if (current && current.bundleIdentifier && current.bundleIdentifier.length > 0) {
            [self launchAppWithBundleID:current.bundleIdentifier];
        } else {
            [[DIActivityManager sharedInstance] collapseToCompact];
        }
    } else if (_islandState == DIIslandStateCompact) {
        if (current) {
            [[DIActivityManager sharedInstance] presentContent:current];
        }
    }
    
    // Haptic feedback
    if (@available(iOS 10, *)) {
        if ([DIPreferencesManager sharedInstance].hapticFeedback) {
            UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc]
                initWithStyle:UIImpactFeedbackStyleLight];
            [gen impactOccurred];
        }
    }
}

- (void)launchAppWithBundleID:(NSString *)bundleID {
    @try {
        UIApplication *app = [UIApplication sharedApplication];
        SEL launchSel = NSSelectorFromString(@"launchApplicationWithIdentifier:suspended:");
        if ([app respondsToSelector:launchSel]) {
            NSMethodSignature *sig = [app methodSignatureForSelector:launchSel];
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
            [inv setTarget:app];
            [inv setSelector:launchSel];
            [inv setArgument:&bundleID atIndex:2];
            BOOL suspended = NO;
            [inv setArgument:&suspended atIndex:3];
            [inv invoke];
        }
    } @catch (NSException *e) {
        NSLog(@"[DynamicIsland] launchApp error: %@", e);
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)press {
    if (press.state == UIGestureRecognizerStateBegan) {
        [DIAnimator bounceTap:self];
        if (_islandState == DIIslandStateCompact) {
            DIActivityContent *current = [DIActivityManager sharedInstance].currentContent;
            if (current) {
                [[DIActivityManager sharedInstance] presentContent:current];
            }
        }
    }
}

#pragma mark - DIActivityManagerDelegate

- (void)activityManager:(id)manager
      didUpdateContent:(DIActivityContent *)content
                 state:(DIIslandState)state {
    if (state == DIIslandStateExpanded) {
        [self showExpandedWithContent:content];
    } else {
        [self showCompact];
    }
}

- (void)activityManagerDidClearContent:(id)manager {
    [self showCompact];
}

@end
