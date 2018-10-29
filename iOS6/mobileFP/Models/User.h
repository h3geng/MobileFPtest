//
//  User.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/7/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "GenericObject.h"
#import "UserDetail.h"

@interface User : NSObject

@property NSString *name;
@property NSString *loginUsername;
@property NSString *username;
@property NSString *password;
@property GenericObject *department;
@property NSString *departmentId;
@property NSString *sessionId;
@property NSString *userId;
@property NSString *expires;
@property NSString *message;
@property GenericObject *ctUser;
@property GenericObject *region;
@property int regionId;
@property bool isCM;
@property bool isPM;
@property bool isProduction;
@property bool isCT;
@property NSMutableArray *appConfig;
@property NSMutableArray *appCredentials;
@property GenericObject *branch;
@property NSString *deviceToken;
@property UserDetail *userDetail;

@property bool onCall;
@property NSMutableArray *onCallBranches;

+ (User *)getInstance;
- (id)init;
- (void)login:(NSString *)username password:(NSString *)password region:(int)region location:(CLLocation *)loc completion:(void(^)(NSMutableArray* result))completion;
- (void)load:(void(^)(NSMutableArray* result))completion;
- (void)logout;
- (void)registerForNotifications;
- (bool)sessionExists;

@end
