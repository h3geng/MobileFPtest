//
//  ClaimOwner.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2018-02-21.
//  Copyright © 2018 FirstOnSite. All rights reserved.
//

#import "ClaimOwner.h"

@implementation ClaimOwner

- (id)init {
    self = [super init];
    if (self) {
        _address = [[Address alloc] init];
        _email2 = @"";
        _phone2 = @"";
        _phone2Ext = @"";
        _contactName = @"";
        _contactPhone = @"";
        _phone2Formatted = @"";
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_address forKey:@"address"];
    [encoder encodeObject:_email2 forKey:@"email2"];
    [encoder encodeObject:_phone2 forKey:@"phone2"];
    [encoder encodeObject:_phone2Ext forKey:@"phone2Ext"];
    [encoder encodeObject:_contactName forKey:@"contactName"];
    [encoder encodeObject:_contactPhone forKey:@"contactPhone"];
    [encoder encodeObject:_phone2Formatted forKey:@"phone2Formatted"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _address = [decoder decodeObjectForKey:@"address"];
        _email2 = [decoder decodeObjectForKey:@"email2"];
        _phone2 = [decoder decodeObjectForKey:@"phone2"];
        _phone2Ext = [decoder decodeObjectForKey:@"phone2Ext"];
        _contactName = [decoder decodeObjectForKey:@"contactName"];
        _contactPhone = [decoder decodeObjectForKey:@"contactPhone"];
        _phone2Formatted = [decoder decodeObjectForKey:@"phone2Formatted"];
    }
    return self;
}

- (void)initWithData:(NSMutableArray *)data {
    if (data) {
        [super initWithData:data];
        
        [_address initWithData:[data valueForKey:@"Address"]];
        _email2 = ([data valueForKey:@"Email2"] && [data valueForKey:@"Email2"] != [NSNull null]) ? [data valueForKey:@"Email2"] : @"";
        _phone2 = ([data valueForKey:@"Phone2"] && [data valueForKey:@"Phone2"] != [NSNull null]) ? [data valueForKey:@"Phone2"] : @"";
        _phone2Ext = ([data valueForKey:@"Phone2Ext"] && [data valueForKey:@"Phone2Ext"] != [NSNull null]) ? [data valueForKey:@"Phone2Ext"] : @"";
        _contactName = ([data valueForKey:@"ContactName"] && [data valueForKey:@"ContactName"] != [NSNull null]) ? [data valueForKey:@"ContactName"] : @"";
        _contactPhone = ([data valueForKey:@"ContactPhone"] && [data valueForKey:@"ContactPhone"] != [NSNull null]) ? [data valueForKey:@"ContactPhone"] : @"";
        
        // check for not provided
        if ([[UTIL trim:super.email] isEqual:@"not provided"]) {
            super.email = @"";
        }
        if ([[UTIL trim:_email2] isEqual:@"not provided"]) {
            _email2 = @"";
        }
        if ([[UTIL trim:_phone2] isEqual:@"not provided"]) {
            _phone2 = @"";
        }
        if ([[UTIL trim:_phone2Ext] isEqual:@"not provided"]) {
            _phone2Ext = @"";
        }
        if ([[UTIL trim:_contactName] isEqual:@"not provided"]) {
            _contactName = @"";
        }
        if ([[UTIL trim:_contactPhone] isEqual:@"not provided"]) {
            _contactPhone = @"";
        }
        
        if (![[UTIL trim:_phone2] isEqual:@""]) {
            _phone2Formatted = [UTIL formatPhone:_phone2];
            if (![[UTIL trim:_phone2Ext] isEqual:@""]) {
                _phone2Formatted = [NSString stringWithFormat:@"%@x%@", _phone2Formatted, [UTIL trim:_phone2Ext]];
            }
        }
    }
}

@end
