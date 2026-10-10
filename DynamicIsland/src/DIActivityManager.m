#import "DIActivityManager.h"
#import "DIPreferencesManager.h"

@implementation DIActivityContent
@end

@interface DIActivityManager ()
@property (nonatomic, strong) DIActivityContent *currentContent;
@property (nonatomic, assign) DIIslandState      currentState;
@property (nonatomic, strong) NSTimer           *collapseTimer;
@end

@implementation DIActivityManager

+ (instancetype)sharedInstance {
    static DIActivityManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentState   = DIIslandStateCompact;
        _currentContent = nil;
    }
    return self;
}

- (void)presentContent:(DIActivityContent *)content {
    if (!content) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collapseTimer invalidate];
        self.collapseTimer = nil;
        
        self.currentContent = content;
        self.currentState   = DIIslandStateExpanded;
        
        [self.delegate activityManager:self
                     didUpdateContent:content
                                state:DIIslandStateExpanded];
        
        // Auto-collapse only for transient events (not ongoing)
        if (!content.isOngoing) {
            NSTimeInterval delay = [DIPreferencesManager sharedInstance].autoCollapseDelay;
            if (delay <= 0) delay = 4.0;
            self.collapseTimer = [NSTimer scheduledTimerWithTimeInterval:delay
                                                                  target:self
                                                                selector:@selector(autoCollapse)
                                                                userInfo:nil
                                                                 repeats:NO];
        }
    });
}

- (void)clearContent {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collapseTimer invalidate];
        self.collapseTimer  = nil;
        self.currentContent = nil;
        self.currentState   = DIIslandStateCompact;
        [self.delegate activityManagerDidClearContent:self];
    });
}

- (void)clearContentOfType:(DIActivityType)type {
    if (self.currentContent && self.currentContent.type == type) {
        [self clearContent];
    }
}

- (void)collapseToCompact {
    [self clearContent];
}

- (void)autoCollapse {
    if (self.currentContent && !self.currentContent.isOngoing) {
        [self clearContent];
    }
}

@end
