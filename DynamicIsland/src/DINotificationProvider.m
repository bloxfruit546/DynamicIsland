#import "DINotificationProvider.h"
#import "DIActivityManager.h"
#import "DIPreferencesManager.h"

@implementation DINotificationProvider

+ (instancetype)sharedInstance {
    static DINotificationProvider *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (void)handleBannerRequest:(id)request {
    if (![DIPreferencesManager sharedInstance].showNotifications) return;
    
    @try {
        DIActivityContent *content = [[DIActivityContent alloc] init];
        content.type      = DIActivityTypeNotification;
        content.isOngoing = NO;
        
        NSString *bundleID = nil;
        NSString *title = nil;
        NSString *message = nil;
        UIImage  *icon = nil;
        
        // Path A: NCNotificationRequest (iOS 12 SBNotificationBannerDestination)
        if ([request respondsToSelector:@selector(sectionIdentifier)]) {
            bundleID = [request performSelector:@selector(sectionIdentifier)];
        }
        
        if ([request respondsToSelector:@selector(content)]) {
            id ncContent = [request performSelector:@selector(content)];
            if (ncContent) {
                if ([ncContent respondsToSelector:@selector(title)]) {
                    title = [ncContent performSelector:@selector(title)];
                }
                if ([ncContent respondsToSelector:@selector(message)]) {
                    message = [ncContent performSelector:@selector(message)];
                }
                if ([ncContent respondsToSelector:@selector(icon)]) {
                    icon = [ncContent performSelector:@selector(icon)];
                }
            }
        }
        
        // Path B: BBBulletin / SBBannerRequest fallback
        if (!title && !message) {
            id bulletin = nil;
            if ([request respondsToSelector:@selector(bulletin)]) {
                bulletin = [request performSelector:@selector(bulletin)];
            } else if ([request respondsToSelector:@selector(bulletinRequest)]) {
                bulletin = [request performSelector:@selector(bulletinRequest)];
            }
            
            if (bulletin) {
                if ([bulletin respondsToSelector:@selector(title)]) {
                    title = [bulletin performSelector:@selector(title)];
                }
                if ([bulletin respondsToSelector:@selector(message)]) {
                    message = [bulletin performSelector:@selector(message)];
                }
                if (!bundleID && [bulletin respondsToSelector:@selector(sectionID)]) {
                    bundleID = [bulletin performSelector:@selector(sectionID)];
                }
            }
        }
        
        if (!bundleID && [request respondsToSelector:@selector(sectionID)]) {
            bundleID = [request performSelector:@selector(sectionID)];
        }
        
        content.bundleIdentifier = bundleID ?: @"";
        content.title            = (title && title.length > 0) ? title : @"Notification";
        content.detail           = message ?: @"";
        content.subtitle         = [self appNameForBundleID:bundleID];
        
        if (!icon && bundleID) {
            icon = [self appIconForBundleID:bundleID];
        }
        content.icon = icon;
        
        [[DIActivityManager sharedInstance] presentContent:content];
    } @catch (NSException *e) {
        NSLog(@"[DynamicIsland] Notification error: %@", e);
    }
}

- (NSString *)appNameForBundleID:(NSString *)bundleID {
    if (!bundleID || bundleID.length == 0) return @"";
    @try {
        Class SBApplicationController = NSClassFromString(@"SBApplicationController");
        if (SBApplicationController && [SBApplicationController respondsToSelector:@selector(sharedInstance)]) {
            id controller = [SBApplicationController performSelector:@selector(sharedInstance)];
            if ([controller respondsToSelector:@selector(applicationWithBundleIdentifier:)]) {
                id app = [controller performSelector:@selector(applicationWithBundleIdentifier:) withObject:bundleID];
                if (app && [app respondsToSelector:@selector(displayName)]) {
                    NSString *name = [app performSelector:@selector(displayName)];
                    if (name.length > 0) return name;
                }
            }
        }
        
        NSBundle *bundle = [NSBundle bundleWithIdentifier:bundleID];
        if (bundle) {
            NSString *name = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
            if (!name) name = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
            if (name.length > 0) return name;
        }
        
        NSArray *parts = [bundleID componentsSeparatedByString:@"."];
        if (parts.count > 0) {
            return parts.lastObject.capitalizedString;
        }
    } @catch (NSException *e) {
        NSLog(@"[DynamicIsland] appName error: %@", e);
    }
    return bundleID ?: @"";
}

- (UIImage *)appIconForBundleID:(NSString *)bundleID {
    if (!bundleID || bundleID.length == 0) return nil;
    @try {
        SEL iconSel = NSSelectorFromString(@"_applicationIconImageForBundleIdentifier:format:scale:");
        if ([UIImage respondsToSelector:iconSel]) {
            CGFloat scale = [UIScreen mainScreen].scale;
            NSMethodSignature *sig = [UIImage methodSignatureForSelector:iconSel];
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
            [inv setTarget:[UIImage class]];
            [inv setSelector:iconSel];
            [inv setArgument:&bundleID atIndex:2];
            int format = 0; // 0 = Small/Spotlight icon, 2 = SpringBoard icon
            [inv setArgument:&format atIndex:3];
            [inv setArgument:&scale atIndex:4];
            [inv invoke];
            __unsafe_unretained UIImage *result = nil;
            [inv getReturnValue:&result];
            if (result) return result;
        }
    } @catch (NSException *e) {
        NSLog(@"[DynamicIsland] appIcon error: %@", e);
    }
    return nil;
}

@end
