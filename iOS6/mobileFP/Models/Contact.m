//
//  ContactObject.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/10/13.
//  Copyright (c) 2013 First on Site. All rights reserved.
//

#import "Contact.h"

@implementation Contact

- (id)init {
    self = [super init];
    if (self) {
        _branch = [[GenericObject alloc] init];
        _cell = @"";
        _cellFormatted = @"";
        _company = [[Company alloc] init];
        _contactType = @"";
        _email = @"";
        _fullName = @"";
        _contactId = @"0";
        _phone = @"";
        _phoneFormatted = @"";
        _region = @"";
        _title = @"";
        _forProduction = false;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_branch forKey:@"branch"];
    [encoder encodeObject:_cell forKey:@"cell"];
    [encoder encodeObject:_cellFormatted forKey:@"cellFormatted"];
    [encoder encodeObject:_company forKey:@"company"];
    [encoder encodeObject:_contactType forKey:@"contactType"];
    [encoder encodeObject:_email forKey:@"email"];
    [encoder encodeObject:_fullName forKey:@"fullName"];
    [encoder encodeObject:_contactId forKey:@"contactId"];
    [encoder encodeObject:_phone forKey:@"phone"];
    [encoder encodeObject:_phoneFormatted forKey:@"phoneFormatted"];
    [encoder encodeObject:_region forKey:@"region"];
    [encoder encodeObject:_title forKey:@"title"];
    [encoder encodeBool:_forProduction forKey:@"forProduction"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _branch = [decoder decodeObjectForKey:@"branch"];
        _cell = [decoder decodeObjectForKey:@"cell"];
        _cellFormatted = [decoder decodeObjectForKey:@"cellFormatted"];
        _company = [decoder decodeObjectForKey:@"company"];
        _contactType = [decoder decodeObjectForKey:@"contactType"];
        _email = [decoder decodeObjectForKey:@"email"];
        _fullName = [decoder decodeObjectForKey:@"fullName"];
        _contactId = [decoder decodeObjectForKey:@"contactId"];
        _phone = [decoder decodeObjectForKey:@"phone"];
        _phoneFormatted = [decoder decodeObjectForKey:@"phoneFormatted"];
        _region = [decoder decodeObjectForKey:@"region"];
        _title = [decoder decodeObjectForKey:@"title"];
        _forProduction = [decoder decodeBoolForKey:@"forProduction"];
    }
    return self;
}

- (void)initWithData:(NSMutableArray *)data {
    if (data) {
        _branch = [[GenericObject alloc] init];
        if ([data valueForKey:@"Branch"] && [data valueForKey:@"Branch"] != [NSNull null]) {
            [_branch initWithData:[data valueForKey:@"Branch"]];
        }
        _company = [[Company alloc] init];
        if ([data valueForKey:@"Company"] && [data valueForKey:@"Company"] != [NSNull null]) {
            [_company initWithData:[data valueForKey:@"Company"]];
        }
        _cell = ([data valueForKey:@"Cell"] && [data valueForKey:@"Cell"] != [NSNull null]) ? [data valueForKey:@"Cell"] : @"";
        _cellFormatted = [UTIL formatPhone:_cell];
        _contactType = ([data valueForKey:@"ContactType"] && [data valueForKey:@"ContactType"] != [NSNull null]) ? [data valueForKey:@"ContactType"] : @"";
        _email = ([data valueForKey:@"Email"] && [data valueForKey:@"Email"] != [NSNull null]) ? [data valueForKey:@"Email"] : @"";
        _fullName = ([data valueForKey:@"FullName"] && [data valueForKey:@"FullName"] != [NSNull null]) ? [data valueForKey:@"FullName"] : @"";
        _contactId = ([data valueForKey:@"Id"] && [data valueForKey:@"Id"] != [NSNull null]) ? [data valueForKey:@"Id"] : @"";
        _phone = ([data valueForKey:@"Phone"] && [data valueForKey:@"Phone"] != [NSNull null]) ? [data valueForKey:@"Phone"] : @"";
        _phoneFormatted = [UTIL formatPhone:_phone];
        _region = ([data valueForKey:@"Region"] && [data valueForKey:@"Region"] != [NSNull null]) ? [data valueForKey:@"Region"] : @"";
        _title = ([data valueForKey:@"Title"] && [data valueForKey:@"Title"] != [NSNull null]) ? [data valueForKey:@"Title"] : @"";
        _forProduction = ([data valueForKey:@"ForProduction"] && [data valueForKey:@"ForProduction"] != [NSNull null]) ? [[data valueForKey:@"ForProduction"] boolValue] : false;
    }
}

@end
