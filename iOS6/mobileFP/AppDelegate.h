//
//  AppDelegate.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 9/27/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *strDeviceToken;
@property (strong, nonatomic) NSDictionary *launchOptions;
@property (strong, nonatomic) NSDictionary *receivedPushNotification;
@property UIGestureRecognizer *tapper;

- (void)logout;

- (UIViewController *)getCurrentScreen;
- (UIViewController *)getPreviousScreen;

@end

