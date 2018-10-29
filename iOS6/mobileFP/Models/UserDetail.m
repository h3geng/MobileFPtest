//
//  UserDetail.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-09-29.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import "UserDetail.h"

@implementation UserDetail

- (id)init {
    self = [super init];
    if (self) {
        _address1 = @"";
        _address2 = @"";
        _city = @"";
        _province = @"";
        _postal = @"";
        _country = @"";
        _areaCode = @"";
        _phone = @"";
        _areaCodeCell = @"";
        _phoneCell = @"";
        _fullname = @"";
        _username = @"";
        _picture = @"";
        _thumbnail = @"";
        _payroll = @"";
        _department = @"";
        _branch = @"";
        _region = @"";
        _onCall = false;
        _canManageEmployeePhotos = false;
        _canManageEmployeeOnCall = false;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_address1 forKey:@"address1"];
    [encoder encodeObject:_address2 forKey:@"address2"];
    [encoder encodeObject:_city forKey:@"city"];
    [encoder encodeObject:_province forKey:@"province"];
    [encoder encodeObject:_postal forKey:@"postal"];
    [encoder encodeObject:_country forKey:@"country"];
    [encoder encodeObject:_areaCode forKey:@"areaCode"];
    [encoder encodeObject:_phone forKey:@"phone"];
    [encoder encodeObject:_areaCodeCell forKey:@"areaCodeCell"];
    [encoder encodeObject:_phoneCell forKey:@"phoneCell"];
    [encoder encodeObject:_username forKey:@"username"];
    [encoder encodeObject:_fullname forKey:@"fullname"];
    [encoder encodeObject:_picture forKey:@"picture"];
    [encoder encodeObject:_thumbnail forKey:@"thumbnail"];
    [encoder encodeObject:_payroll forKey:@"payroll"];
    [encoder encodeObject:_department forKey:@"department"];
    [encoder encodeObject:_branch forKey:@"branch"];
    [encoder encodeObject:_region forKey:@"region"];
    [encoder encodeBool:_onCall forKey:@"onCall"];
    [encoder encodeBool:_canManageEmployeePhotos forKey:@"canManageEmployeePhotos"];
    [encoder encodeBool:_canManageEmployeeOnCall forKey:@"canManageEmployeeOnCall"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _address1 = [decoder decodeObjectForKey:@"address1"];
        _address2 = [decoder decodeObjectForKey:@"address2"];
        _city = [decoder decodeObjectForKey:@"city"];
        _province = [decoder decodeObjectForKey:@"province"];
        _postal = [decoder decodeObjectForKey:@"postal"];
        _country = [decoder decodeObjectForKey:@"country"];
        _areaCode = [decoder decodeObjectForKey:@"areaCode"];
        _phone = [decoder decodeObjectForKey:@"phone"];
        _areaCodeCell = [decoder decodeObjectForKey:@"areaCodeCell"];
        _phoneCell = [decoder decodeObjectForKey:@"phoneCell"];
        _username = [decoder decodeObjectForKey:@"username"];
        _fullname = [decoder decodeObjectForKey:@"fullname"];
        _picture = [decoder decodeObjectForKey:@"picture"];
        _thumbnail = [decoder decodeObjectForKey:@"thumbnail"];
        _payroll = [decoder decodeObjectForKey:@"payroll"];
        _department = [decoder decodeObjectForKey:@"department"];
        _branch = [decoder decodeObjectForKey:@"branch"];
        _region = [decoder decodeObjectForKey:@"region"];
        _onCall = [decoder decodeBoolForKey:@"onCall"];
        _canManageEmployeePhotos = [decoder decodeBoolForKey:@"canManageEmployeePhotos"];
        _canManageEmployeeOnCall = [decoder decodeBoolForKey:@"canManageEmployeeOnCall"];
    }
    return self;
}

- (void)initWithData:(NSMutableArray *)data {
    if (data) {
        _address1 = ([data valueForKey:@"Address1"] && [data valueForKey:@"Address1"] != [NSNull null]) ? [data valueForKey:@"Address1"] : @"";
        _address2 = ([data valueForKey:@"Address2"] && [data valueForKey:@"Address2"] != [NSNull null]) ? [data valueForKey:@"Address2"] : @"";
        _city = ([data valueForKey:@"City"] && [data valueForKey:@"City"] != [NSNull null]) ? [data valueForKey:@"City"] : @"";
        _province = ([data valueForKey:@"Province"] && [data valueForKey:@"Province"] != [NSNull null]) ? [data valueForKey:@"Province"] : @"";
        _postal = ([data valueForKey:@"Postal"] && [data valueForKey:@"Postal"] != [NSNull null]) ? [data valueForKey:@"Postal"] : @"";
        _country = ([data valueForKey:@"Country"] && [data valueForKey:@"Country"] != [NSNull null]) ? [data valueForKey:@"Country"] : @"";
        _areaCode = ([data valueForKey:@"AreaCode"] && [data valueForKey:@"AreaCode"] != [NSNull null]) ? [data valueForKey:@"AreaCode"] : @"";
        _phone = ([data valueForKey:@"Phone"] && [data valueForKey:@"Phone"] != [NSNull null]) ? [data valueForKey:@"Phone"] : @"";
        _areaCodeCell = ([data valueForKey:@"AreaCodeCell"] && [data valueForKey:@"AreaCodeCell"] != [NSNull null]) ? [data valueForKey:@"AreaCodeCell"] : @"";
        _phoneCell = ([data valueForKey:@"PhoneCell"] && [data valueForKey:@"PhoneCell"] != [NSNull null]) ? [data valueForKey:@"PhoneCell"] : @"";
        _username = ([data valueForKey:@"Username"] && [data valueForKey:@"Username"] != [NSNull null]) ? [data valueForKey:@"Username"] : @"";
        _fullname = ([data valueForKey:@"FullName"] && [data valueForKey:@"FullName"] != [NSNull null]) ? [data valueForKey:@"FullName"] : @"";
        _picture = ([data valueForKey:@"Picture"] && [data valueForKey:@"Picture"] != [NSNull null]) ? [data valueForKey:@"Picture"] : @"";
        _thumbnail = ([data valueForKey:@"Picture"] && [data valueForKey:@"Picture"] != [NSNull null]) ? [data valueForKey:@"Picture"] : @"";
        _payroll = ([data valueForKey:@"Payroll"] && [data valueForKey:@"Payroll"] != [NSNull null]) ? [data valueForKey:@"Payroll"] : @"";
        _department = ([data valueForKey:@"Department"] && [data valueForKey:@"Department"] != [NSNull null]) ? [data valueForKey:@"Department"] : @"";
        _branch = ([data valueForKey:@"Branch"] && [data valueForKey:@"Branch"] != [NSNull null]) ? [data valueForKey:@"Branch"] : @"";
        _region = ([data valueForKey:@"Region"] && [data valueForKey:@"Region"] != [NSNull null]) ? [data valueForKey:@"Region"] : @"";
        _onCall = ([data valueForKey:@"OnCall"] && [data valueForKey:@"OnCall"] != [NSNull null]) ? [[data valueForKey:@"OnCall"] boolValue] : false;
        _canManageEmployeePhotos = ([data valueForKey:@"CanManageEmployeePhotos"] && [data valueForKey:@"CanManageEmployeePhotos"] != [NSNull null]) ? [[data valueForKey:@"CanManageEmployeePhotos"] boolValue] : false;
        _canManageEmployeeOnCall = ([data valueForKey:@"CanManageEmployeeOnCall"] && [data valueForKey:@"CanManageEmployeeOnCall"] != [NSNull null]) ? [[data valueForKey:@"CanManageEmployeeOnCall"] boolValue] : false;
    }
}

- (void)update:(NSString *)userGUID completion:(void(^)(NSMutableArray* result))completion {
    [API updateUserDetail:USER.sessionId userGUID:userGUID phone:_phoneCell completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)updatePicture:(NSString *)userGUID completion:(void(^)(NSMutableArray* result))completion {
    [API updateUserPicture:USER.sessionId userGUID:userGUID picture:_picture thumbnail:_thumbnail completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)deletePicture:(NSString *)userGUID completion:(void(^)(NSMutableArray* result))completion {
    [API deleteUserPicture:USER.sessionId userGUID:userGUID completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

@end
