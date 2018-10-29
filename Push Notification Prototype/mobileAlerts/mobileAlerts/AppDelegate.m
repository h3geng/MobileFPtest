//
//  AppDelegate.m
//  mobileAlerts
//
//  Created by FOS Dev on 2013-09-05.
//  Copyright (c) 2013 FirstOnSite Restoration. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

// Application is launched
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Set up push notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert)];
    notificationController = [[NotificationController alloc] init];
    
    // The below applies to situations where the app is launched from a push notification (the notification payload is contained within the launchOptions)
    if (launchOptions)
    {
        NSDictionary * dict = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
            if(dict)
            {
                NSLog(@"Launched from pushnotification");
                NSLog(@"Notification contents: %@", dict);
                ViewController *viewController = (ViewController *)self.window.rootViewController;
                [viewController.myLabel setText:[NSString stringWithFormat:@"%@", dict]];
                // I was getting unrecognized selector errors when I tried to pass the dictionary and
                // the label to this function
                //[notificationController addMessageFromRemoteNotification:dict toLabel:viewController.myLabel updateUI:true];
            }
    }
    
    // Override point for customization after application launch.
    return YES;
}

// The method below is called when the app is currently running (in the foreground) and the user receives a push notification.
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    ViewController *viewController = (ViewController *)self.window.rootViewController;
    NSLog(@"Recieved Push Notification; adding to label: %@", viewController.myLabel);
    NSLog(@"Notification Contents: %@", userInfo);
    [viewController.myLabel setText:[NSString stringWithFormat:@"%@", userInfo]];
    // I was getting unrecognized selector errors when I tried to pass the dictionary and
    // the label to this function
    //[notificationController addMessageFromRemoteNotification:userInfo toLabel:viewController.myLabel updateUI:true];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"My device token is: %@", deviceToken);
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

@end