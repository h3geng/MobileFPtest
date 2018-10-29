//
//  Company.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/10/13.
//  Copyright (c) 2013 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Address.h"

@interface Company : NSObject

@property int companyId;
@property int regionId;
@property int active;
@property Address *address;
@property int approved;
@property NSMutableArray *branches;
@property NSString *cityId;
@property NSString *code;
@property NSString *companyType;
@property NSMutableArray *contacts;
@property NSString *email;
@property NSString *fax;
@property NSString *faxFormatted;
@property NSString *fullName;
@property NSString *globalId;
@property NSString *phone;
@property NSString *phoneFormatted;
@property NSString *profile;

- (id)init;
- (void)reload;
- (void)initWithData:(NSMutableArray *)data;

@end
