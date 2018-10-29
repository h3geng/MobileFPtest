//
//  Share.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-09-08.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Share : NSObject

@property bool sendEmail;
@property bool sendPushNotification;
@property NSMutableArray *contacts;
@property int regionId;
@property int claimId;
@property int noteId;

- (id)init;
- (void)send:(void(^)(NSMutableArray* result))completion;

@end
