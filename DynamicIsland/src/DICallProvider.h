#import <Foundation/Foundation.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

@interface DICallProvider : NSObject

+ (instancetype)sharedInstance;
- (void)startMonitoring;
- (void)stopMonitoring;

@end
