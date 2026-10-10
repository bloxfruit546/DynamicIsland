#import "DICallProvider.h"
#import "DIActivityManager.h"
#import "DIPreferencesManager.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

@interface DICallProvider ()
@property (nonatomic, strong) CTCallCenter *callCenter;
@property (nonatomic, strong) NSTimer      *callTimer;
@property (nonatomic, assign) NSTimeInterval callStartTime;
@property (nonatomic, strong) NSString     *callerName;
@end

@implementation DICallProvider

+ (instancetype)sharedInstance {
    static DICallProvider *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (void)startMonitoring {
    // 1. TUCallCenter Notifications (TelephonyUtilities in SpringBoard)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTUCallNotification:)
                                                 name:@"TUCallCenterCallStatusChangedNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTUCallNotification:)
                                                 name:@"TUCallCenterVideoCallStatusChangedNotification"
                                               object:nil];
    
    // 2. CTCallCenter backup
    @try {
        _callCenter = [[CTCallCenter alloc] init];
        __weak typeof(self) weakSelf = self;
        _callCenter.callEventHandler = ^(CTCall *call) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf handleCTCall:call];
            });
        };
    } @catch (NSException *e) {
        NSLog(@"[DynamicIsland] CTCallCenter init exception: %@", e);
    }
}

- (void)stopMonitoring {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _callCenter.callEventHandler = nil;
    _callCenter = nil;
    [self stopCallTimer];
}

- (void)handleTUCallNotification:(NSNotification *)note {
    if (![DIPreferencesManager sharedInstance].showCalls) return;
    
    @try {
        Class TUCallCenterClass = NSClassFromString(@"TUCallCenter");
        if (!TUCallCenterClass || ![TUCallCenterClass respondsToSelector:@selector(sharedInstance)]) {
            return;
        }
        
        id center = [TUCallCenterClass performSelector:@selector(sharedInstance)];
        id incomingCall = [center respondsToSelector:@selector(incomingCall)] ? [center performSelector:@selector(incomingCall)] : nil;
        id activeCall = nil;
        if ([center respondsToSelector:@selector(currentCalls)]) {
            NSArray *calls = [center performSelector:@selector(currentCalls)];
            if (calls && [calls isKindOfClass:[NSArray class]] && calls.count > 0) {
                activeCall = calls.firstObject;
            }
        }
        
        if (incomingCall) {
            NSString *name = [self nameForCall:incomingCall];
            _callerName = name;
            [self showCallContent:@"Incoming Call" callerName:name];
        } else if (activeCall) {
            // Check status: 1 = active, 3 = incoming, 4 = disconnected
            NSInteger status = 1;
            if ([activeCall respondsToSelector:@selector(status)]) {
                NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[activeCall methodSignatureForSelector:@selector(status)]];
                [inv setTarget:activeCall];
                [inv setSelector:@selector(status)];
                [inv invoke];
                [inv getReturnValue:&status];
            }
            if (status == 1) { // Connected
                if (!_callTimer) {
                    _callStartTime = [NSDate date].timeIntervalSince1970;
                    [self startCallTimer];
                }
                NSString *name = [self nameForCall:activeCall];
                _callerName = name;
                [self showCallContent:@"Call Connected" callerName:name];
            } else if (status == 4 || status == 6) { // Disconnected
                [self stopCallTimer];
                [[DIActivityManager sharedInstance] clearContentOfType:DIActivityTypeCall];
            }
        } else {
            [self stopCallTimer];
            [[DIActivityManager sharedInstance] clearContentOfType:DIActivityTypeCall];
        }
    } @catch (NSException *e) {
        NSLog(@"[DynamicIsland] TUCall handler exception: %@", e);
    }
}

- (NSString *)nameForCall:(id)call {
    if (!call) return @"Unknown Caller";
    if ([call respondsToSelector:@selector(displayName)]) {
        NSString *name = [call performSelector:@selector(displayName)];
        if (name.length > 0) return name;
    }
    if ([call respondsToSelector:@selector(destinationID)]) {
        NSString *dest = [call performSelector:@selector(destinationID)];
        if (dest.length > 0) return dest;
    }
    return @"Call";
}

- (void)handleCTCall:(CTCall *)call {
    if (![DIPreferencesManager sharedInstance].showCalls) return;
    
    @try {
        NSString *state = call.callState;
        if ([state isEqualToString:CTCallStateIncoming] || [state isEqualToString:CTCallStateDialing]) {
            _callerName = call.callID ?: @"Unknown Caller";
            [self showCallContent:@"Incoming Call" callerName:_callerName];
        } else if ([state isEqualToString:CTCallStateConnected]) {
            _callStartTime = [NSDate date].timeIntervalSince1970;
            [self showCallContent:@"Mobile" callerName:_callerName ?: @"Call Connected"];
            [self startCallTimer];
        } else if ([state isEqualToString:CTCallStateDisconnected]) {
            [self stopCallTimer];
            [[DIActivityManager sharedInstance] clearContentOfType:DIActivityTypeCall];
        }
    } @catch (NSException *e) {
        NSLog(@"[DynamicIsland] CTCall handler exception: %@", e);
    }
}

- (void)showCallContent:(NSString *)status callerName:(NSString *)name {
    DIActivityContent *content = [[DIActivityContent alloc] init];
    content.type      = DIActivityTypeCall;
    content.isOngoing = YES;
    content.title     = (name.length > 0) ? name : @"Call";
    content.subtitle  = status;
    [[DIActivityManager sharedInstance] presentContent:content];
}

- (void)startCallTimer {
    [self stopCallTimer];
    _callTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(updateCallDuration)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stopCallTimer {
    [_callTimer invalidate];
    _callTimer = nil;
}

- (void)updateCallDuration {
    NSTimeInterval elapsed = [NSDate date].timeIntervalSince1970 - _callStartTime;
    NSInteger minutes = (NSInteger)(elapsed / 60);
    NSInteger seconds = (NSInteger)(elapsed) % 60;
    NSString *durationStr = [NSString stringWithFormat:@"%02ld:%02ld",
                             (long)minutes, (long)seconds];
    [self showCallContent:durationStr callerName:_callerName ?: @"Call"];
}

@end
