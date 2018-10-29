//
//  AppDelegate.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 9/27/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "AppDelegate.h"
#import "PayPalMobile.h"
#import "LoginViewController.h"
#import "PinViewController.h"

@import Firebase;

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [FIRApp configure];
    
    // Location services
    [LOCATION checkLocationService];
    
    // Add a tap gesture to hide the opened keybaord if user taps outiside of the keyboard's layout
    _tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    _tapper.cancelsTouchesInView = NO;
    [self.window addGestureRecognizer:_tapper];
    
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : PAYPAL_CLIENT_ID_FOR_PRODUCTION, PayPalEnvironmentSandbox : PAYPAL_CLIENT_ID_FOR_SANDBOX}];
    
    [self registerForRemoteNotification];
    
    _launchOptions = launchOptions;
    
    if ([[UTIL getLanguage] isEqual:@""]) {
        NSString *langID = [[NSLocale preferredLanguages] objectAtIndex:0];
        if ([[langID substringToIndex:2] isEqual:@"fr"]) {
            [UTIL setLanguage:@"fr"];
        } else {
            [UTIL setLanguage:@"en"];
        }
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // check system language
    if ([[UTIL getLanguage] isEqual:@""]) {
        NSString *langID = [[NSLocale preferredLanguages] objectAtIndex:0];
        if ([[langID substringToIndex:2] isEqual:@"fr"]) {
            [UTIL setLanguage:@"fr"];
        } else {
            [UTIL setLanguage:@"en"];
        }
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [LOCATION checkLocationService];
    [UTIL checkForUpdate];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma --mark Gesture Recognizer Delegate Functionality
- (void)handleSingleTap:(UITapGestureRecognizer *) sender {
    //UIViewController *current = [self getCurrentScreen];
    //if (![current isKindOfClass:[PinViewController class]] && ![current isKindOfClass:[ChatViewController class]]) {
        [self.window endEditing:YES];
    //}
}

- (void)logout {
    [ALERT promptWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"do_you_want_to_logout", [UTIL getLanguage], @"") completion:^(BOOL granted) {
        if (granted) {
            USER.deviceToken = @"";
            USER.ctUser = nil;
            USER.region = nil;
            USER.password = @"";
            
            UINavigationController *mainNavigation = (UINavigationController *)self.window.rootViewController;
            UIViewController *destController = (UIViewController*)[mainNavigation.viewControllers objectAtIndex:0];
            
            if ([destController isKindOfClass:[LoginViewController class]]) {
                if ([USER_DEFAULTS objectForKey:@"autologin"]) {
                    bool autoLogin = [[USER_DEFAULTS objectForKey:@"autologin"] boolValue];
                    if (!autoLogin) {
                        LoginViewController *loginViewController = (LoginViewController *)destController;
                        [loginViewController.passwordTextField setText:@""];
                    }
                }
            }
            
            [mainNavigation popToViewController:destController animated:YES];
        }
    }];
}

- (UIViewController *)getCurrentScreen {
    UINavigationController *mainNavigation = (UINavigationController *)self.window.rootViewController;
    UIViewController *destController = [mainNavigation.viewControllers objectAtIndex:0];
    if (mainNavigation.viewControllers.count > 1) {
        UITabBarController *mainTabBar = (UITabBarController*)[mainNavigation.viewControllers objectAtIndex:1];
        destController = [((UINavigationController *)[mainTabBar selectedViewController]).viewControllers lastObject];
    }
    
    return destController;
}

- (UIViewController *)getPreviousScreen {
    UINavigationController *mainNavigation = (UINavigationController *)self.window.rootViewController;
    UITabBarController *mainTabBar = (UITabBarController*)[mainNavigation.viewControllers objectAtIndex:1];
    NSArray *controllers = ((UINavigationController *)[mainTabBar selectedViewController]).viewControllers;
    UIViewController *destController = [controllers lastObject];
    
    UIViewController *prevController = destController;
    if (controllers.count >= 2) {
        prevController = [controllers objectAtIndex:([controllers count] - 2)];
    }
    
    return prevController;
}

#pragma mark - Remote Notification Delegate // <= iOS 9.x

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *strDevicetoken = [[NSString alloc]initWithFormat:@"%@",[[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""]];
    _strDeviceToken = strDevicetoken;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [UTIL processAppOptions:userInfo];
    _receivedPushNotification = userInfo;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"%@ = %@", NSStringFromSelector(_cmd), error);
    NSLog(@"Error = %@",error);
}

#pragma mark - UNUserNotificationCenter Delegate // >= iOS 10

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    NSLog(@"User Info = %@",notification.request.content.userInfo);
    
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    NSLog(@"%@", response.notification.request.content.categoryIdentifier);
    if ([response.notification.request.content.categoryIdentifier isEqualToString:@"NOTE_SHARE"]) {
        [UTIL processAppOptions:response.notification.request.content.userInfo];
        _receivedPushNotification = response.notification.request.content.userInfo;
    }
}

#pragma mark - Class Methods

/**
 Notification Registration
 */
- (void)registerForRemoteNotification {
    if (SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        
        /*UNNotificationAction *viewAction = [UNNotificationAction actionWithIdentifier:@"VIEW_ACTION" title:@"View" options:UNNotificationActionOptionNone];
        UNNotificationAction *dismissAction = [UNNotificationAction actionWithIdentifier:@"DISMISS_ACTION" title:@"Dismiss" options:UNNotificationActionOptionForeground];
        UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"NOTE_SHARE" actions:@[viewAction, dismissAction] intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
        [center setNotificationCategories:[NSSet setWithObjects:category, nil]];*/
        
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
            }
        }];
    } else {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

@end
