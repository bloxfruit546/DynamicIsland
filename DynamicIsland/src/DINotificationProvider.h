#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DINotificationProvider : NSObject

+ (instancetype)sharedInstance;
- (void)handleBannerRequest:(id)request;

@end
