//
//  Address.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/10/13.
//  Copyright (c) 2013 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Address : NSObject

@property NSString *address;
@property NSString *city;
@property NSString *country;
@property NSString *lat;
@property NSString *lon;
@property NSString *postal;
@property NSString *province;
@property NSString *fullAddress;

- (id)init;
- (void)initWithData:(NSMutableArray *)data;
- (void)prepareFullAddress;

@end
