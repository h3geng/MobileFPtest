//
//  User.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/7/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "User.h"

@implementation User

/**
 * Gets the instance of self object.
 *
 * @return instance object.
 */
+ (User *)getInstance {
    SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id)init {
    self = [super init];
    if (self) {
        _name = @"";
        _loginUsername = @"";
        _username = @"";
        _password = @"";
        _department = [[GenericObject alloc] init];
        _departmentId = @"";
        _sessionId = @"";
        _userId = @"";
        _expires = @"";
        _message = @"";
        _ctUser = [[GenericObject alloc] init];
        _region = [[GenericObject alloc] init];
        _regionId = 0;
        _isCM = false;
        _isPM = false;
        _isProduction = false;
        _isCT = false;
        _appConfig = [[NSMutableArray alloc] init];
        _appCredentials = [[NSMutableArray alloc] init];
        _branch = [[GenericObject alloc] init];
        _deviceToken = @"";
        _onCall = false;
        _onCallBranches = [[NSMutableArray alloc] init];
        _userDetail = [[UserDetail alloc] init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_loginUsername forKey:@"loginUsername"];
    [encoder encodeObject:_username forKey:@"username"];
    [encoder encodeObject:_password forKey:@"password"];
    [encoder encodeObject:_department forKey:@"department"];
    [encoder encodeObject:_departmentId forKey:@"departmentId"];
    [encoder encodeObject:_sessionId forKey:@"sessionId"];
    [encoder encodeObject:_userId forKey:@"userId"];
    [encoder encodeObject:_expires forKey:@"expires"];
    [encoder encodeObject:_message forKey:@"message"];
    [encoder encodeObject:_ctUser forKey:@"ctUser"];
    [encoder encodeObject:_region forKey:@"region"];
    [encoder encodeInt:_regionId forKey:@"regionId"];
    [encoder encodeBool:_isCM forKey:@"isCM"];
    [encoder encodeBool:_isPM forKey:@"isPM"];
    [encoder encodeBool:_isProduction forKey:@"isProduction"];
    [encoder encodeBool:_isCT forKey:@"isCT"];
    [encoder encodeObject:_appConfig forKey:@"appConfig"];
    [encoder encodeObject:_appCredentials forKey:@"appCredentials"];
    [encoder encodeObject:_branch forKey:@"branch"];
    [encoder encodeObject:_deviceToken forKey:@"deviceToken"];
    [encoder encodeBool:_onCall forKey:@"onCall"];
    [encoder encodeObject:_onCallBranches forKey:@"onCallBranches"];
    [encoder encodeObject:_userDetail forKey:@"userDetail"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _name = [decoder decodeObjectForKey:@"name"];
        _loginUsername = [decoder decodeObjectForKey:@"loginUsername"];
        _username = [decoder decodeObjectForKey:@"username"];
        _password = [decoder decodeObjectForKey:@"password"];
        _department = [decoder decodeObjectForKey:@"department"];
        _departmentId = [decoder decodeObjectForKey:@"departmentId"];
        _sessionId = [decoder decodeObjectForKey:@"sessionId"];
        _userId = [decoder decodeObjectForKey:@"userId"];
        _expires = [decoder decodeObjectForKey:@"expires"];
        _message = [decoder decodeObjectForKey:@"message"];
        _ctUser = [decoder decodeObjectForKey:@"ctUser"];
        _region = [decoder decodeObjectForKey:@"region"];
        _regionId = [decoder decodeIntForKey:@"regionId"];
        _isCM = [decoder decodeBoolForKey:@"isCM"];
        _isPM = [decoder decodeBoolForKey:@"isPM"];
        _isProduction = [decoder decodeBoolForKey:@"isProduction"];
        _isCT = [decoder decodeBoolForKey:@"isCT"];
        _appConfig = [decoder decodeObjectForKey:@"appConfig"];
        _appCredentials = [decoder decodeObjectForKey:@"appCredentials"];
        _branch = [decoder decodeObjectForKey:@"branch"];
        _deviceToken = [decoder decodeObjectForKey:@"deviceToken"];
        _onCall = [decoder decodeBoolForKey:@"onCall"];
        _onCallBranches = [decoder decodeObjectForKey:@"onCallBranches"];
        _userDetail = [decoder decodeObjectForKey:@"userDetail"];
    }
    return self;
}

- (void)login:(NSString *)username password:(NSString *)password region:(int)region location:(CLLocation *)loc completion:(void(^)(NSMutableArray* result))completion {
    LOCATION.lastSavedLocation = (loc) ? loc : nil;
    [API loginWithUserName:username password:password regionId:region location:loc completion:^(NSMutableArray *result) {
        NSString *error = ([result valueForKey:@"error"] && [result valueForKey:@"error"] != [NSNull null]) ? [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]] : @"";
        
        if ([error isEqualToString: @""]) {
            NSMutableArray *responseData = [result valueForKey:@"LoginResult"];
            
            self->_loginUsername = username;
            self->_appConfig = [responseData valueForKey:@"AppConfig"];
            self->_appCredentials = [responseData valueForKey:@"AppCredentials"];
            
            if ([responseData valueForKey:@"Branch"] && [responseData valueForKey:@"Branch"] != [NSNull null]) {
                [self->_branch initWithData:[responseData valueForKey:@"Branch"]];
            }
            
            [self->_department initWithData:[responseData valueForKey:@"Department"]];
            self->_departmentId = [responseData valueForKey:@"DepartmentId"];
            self->_expires = [responseData valueForKey:@"Expires"];
            self->_message = [responseData valueForKey:@"Message"];
            self->_name = [responseData valueForKey:@"Name"];
            self->_regionId = [[responseData valueForKey:@"RegionId"] intValue];
            self->_sessionId = [responseData valueForKey:@"SessionId"];
            self->_userId = [responseData valueForKey:@"UserId"];
            self->_username = [responseData valueForKey:@"Username"];
            self->_isCM = [[responseData valueForKey:@"isCM"] boolValue];
            self->_isPM = [[responseData valueForKey:@"isPM"] boolValue];
            self->_isProduction = [[responseData valueForKey:@"isProduction"] boolValue];
            self->_isCT = [[responseData valueForKey:@"isCT"] boolValue];
            self->_onCall = [[responseData valueForKey:@"onCall"] boolValue];
            
            [self->_userDetail initWithData:[responseData valueForKey:@"UserDetail"]];
            //_isProduction = true; // used for test purposes
        }
        
        completion(result);
    }];
}

- (void)load:(void(^)(NSMutableArray* result))completion {
    [API loadUser:USER.sessionId userGUID:_userId completion:^(NSMutableArray *result) {
        if (result) {
            NSString *error = ([result valueForKey:@"error"] && [result valueForKey:@"error"] != [NSNull null]) ? [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]] : @"";
            
            if ([error isEqualToString: @""]) {
                NSMutableArray *responseData = [result valueForKey:@"loadUserResult"];
                
                if (responseData) {
                    self->_name = [responseData valueForKey:@"FullName"];
                    self->_onCall = [[responseData valueForKey:@"OnCall"] boolValue];
                    [self->_userDetail initWithData:responseData];
                } else {
                    result = nil;
                }
            }
        }
        
        completion(result);
    }];
}

- (bool)sessionExists {
    return (_sessionId && ![_sessionId isEqual: @""]) ? true : false;
}

- (void)logout {
    /*[API unregisterNotify:_sessionId userGUID:_userId deviceToken:_deviceToken completion:^(NSMutableArray *result) {
        [NSUserDefaults setAutologin:NO];
        [NSUserDefaults setPassword:nil];
        [NSUserDefaults setRegionId:nil];
        [NSUserDefaults setRegionCode:nil];
        [NSUserDefaults setRegionvalue:nil];
        [NSUserDefaults setCTuser:nil];
        [NSUserDefaults synchronize];
    }];*/
}

- (void)registerForNotifications {
    [API registerNotify:_sessionId userGUID:_userId deviceToken:_deviceToken completion:^(NSMutableArray *result) {
        if ([result valueForKey:@"error"]) {
            NSString *error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
            NSLog(@"Error: %@", error);
        }
    }];
}

@end
