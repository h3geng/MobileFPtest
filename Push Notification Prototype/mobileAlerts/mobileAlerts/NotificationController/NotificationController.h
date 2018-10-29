//
//  NotificationController.h
//  mobileAlerts
//
//  Created by FOS Dev on 2013-09-24.
//  Copyright (c) 2013 FirstOnSite Restoration. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationController : NSObject{
    
}

-(void) addMessageFromRemoteNotification:(NSDictionary *)userInfo toLabel:(UILabel*)label updateUI:(BOOL)updateUI;
@end
