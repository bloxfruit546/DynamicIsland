#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DIActivityType) {
    DIActivityTypeNone         = 0,
    DIActivityTypeNotification = 1,
    DIActivityTypeMusic        = 2,
    DIActivityTypeCall         = 3,
};

typedef NS_ENUM(NSInteger, DIIslandState) {
    DIIslandStateHidden   = -1,
    DIIslandStateCompact  =  0,
    DIIslandStateExpanded =  1,
};

@interface DIActivityContent : NSObject

@property (nonatomic, assign) DIActivityType type;
@property (nonatomic, copy)   NSString  *title;
@property (nonatomic, copy)   NSString  *subtitle;
@property (nonatomic, copy)   NSString  *detail;
@property (nonatomic, strong) UIImage   *icon;
@property (nonatomic, strong) UIImage   *artwork;
@property (nonatomic, copy)   NSString  *bundleIdentifier;
@property (nonatomic, assign) BOOL       isOngoing;
@property (nonatomic, assign) NSTimeInterval duration;

@end

@protocol DIActivityManagerDelegate <NSObject>
- (void)activityManager:(id)manager
      didUpdateContent:(DIActivityContent *)content
                 state:(DIIslandState)state;
- (void)activityManagerDidClearContent:(id)manager;
@end

@interface DIActivityManager : NSObject

@property (nonatomic, weak)     id<DIActivityManagerDelegate> delegate;
@property (nonatomic, readonly) DIIslandState      currentState;
@property (nonatomic, readonly) DIActivityContent *currentContent;

+ (instancetype)sharedInstance;
- (void)presentContent:(DIActivityContent *)content;
- (void)clearContent;
- (void)clearContentOfType:(DIActivityType)type;
- (void)collapseToCompact;

@end
