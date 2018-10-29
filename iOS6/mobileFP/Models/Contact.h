//
//  Contact.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/10/13.
//  Copyright (c) 2013 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Company.h"

@interface Contact : NSObject

@property GenericObject *branch;
@property NSString *cell;
@property NSString *cellFormatted;
@property Company *company;
@property NSString *contactType;
@property NSString *email;
@property NSString *fullName;
@property NSString *contactId;
@property NSString *phone;
@property NSString *phoneFormatted;
@property NSString *region;
@property NSString *title;
@property bool forProduction;

- (id)init;
- (void)initWithData:(NSMutableArray *)data;

@end
