//
//  UserDetail.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-09-29.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDetail : NSObject

@property NSString *address1;
@property NSString *address2;
@property NSString *city;
@property NSString *province;
@property NSString *postal;
@property NSString *country;
@property NSString *areaCode;
@property NSString *phone;
@property NSString *areaCodeCell;
@property NSString *phoneCell;
@property NSString *username;
@property NSString *fullname;
@property NSString *picture;
@property NSString *thumbnail;
@property NSString *payroll;
@property NSString *department;
@property NSString *branch;
@property NSString *region;
@property bool onCall;
@property bool canManageEmployeePhotos;
@property bool canManageEmployeeOnCall;

- (id)init;
- (void)initWithData:(NSMutableArray *)data;
- (void)update:(NSString *)userGUID completion:(void(^)(NSMutableArray* result))completion;
- (void)updatePicture:(NSString *)userGUID completion:(void(^)(NSMutableArray* result))completion;
- (void)deletePicture:(NSString *)userGUID completion:(void(^)(NSMutableArray* result))completion;

@end
