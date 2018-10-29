//
//  NotificationController.m
//  mobileAlerts
//
//  Created by FOS Dev on 2013-09-24.
//  Copyright (c) 2013 FirstOnSite Restoration. All rights reserved.
//

#import "NotificationController.h"

@implementation NotificationController

-(void)addMessageFromRemoteNotification:(NSDictionary *)userInfo withLabel:(UILabel *)label updateUI:(BOOL)updateUI
{
    NSLog(@"Adding message to label %@", label);
    [label setText:[NSString stringWithFormat:@"%@", userInfo]];
    
}


@end
