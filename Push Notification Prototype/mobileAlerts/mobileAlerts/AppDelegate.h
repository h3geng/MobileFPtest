//
//  AppDelegate.h
//  mobileAlerts
//
//  Created by FOS Dev on 2013-09-05.
//  Copyright (c) 2013 FirstOnSite Restoration. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NotificationController * notificationController;
}

@property (strong, nonatomic) UIWindow *window;

@end
