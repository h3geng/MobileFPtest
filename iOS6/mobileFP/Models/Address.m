//
//  Address.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/10/13.
//  Copyright (c) 2013 FirstOnSite. All rights reserved.
//

#import "Address.h"

@implementation Address

- (id)init {
    self = [super init];
    if (self) {
        _address = @"";
        _city = @"";
        _country = @"";
        _lat = @"";
        _lon = @"";
        _postal = @"";
        _province = @"";
        _fullAddress = @"";
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_address forKey:@"address"];
    [encoder encodeObject:_city forKey:@"city"];
    [encoder encodeObject:_country forKey:@"country"];
    [encoder encodeObject:_lat forKey:@"lat"];
    [encoder encodeObject:_lon forKey:@"lon"];
    [encoder encodeObject:_postal forKey:@"postal"];
    [encoder encodeObject:_province forKey:@"province"];
    [encoder encodeObject:_fullAddress forKey:@"fullAddress"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _address = [decoder decodeObjectForKey:@"address"];
        _city = [decoder decodeObjectForKey:@"city"];
        _country = [decoder decodeObjectForKey:@"country"];
        _lat = [decoder decodeObjectForKey:@"lat"];
        _lon = [decoder decodeObjectForKey:@"lon"];
        _postal = [decoder decodeObjectForKey:@"postal"];
        _province = [decoder decodeObjectForKey:@"province"];
        _fullAddress = [decoder decodeObjectForKey:@"fullAddress"];
    }
    return self;
}

- (void)initWithData:(NSMutableArray *)data {
    if (data) {
        _address = ([data valueForKey:@"Address"] && [data valueForKey:@"Address"] != [NSNull null]) ? [data valueForKey:@"Address"] : @"";
        _city = ([data valueForKey:@"City"] && [data valueForKey:@"City"] != [NSNull null]) ? [data valueForKey:@"City"] : @"";
        _country = ([data valueForKey:@"Country"] != [NSNull null]) ? [data valueForKey:@"Country"] : @"";
        _lat = ([data valueForKey:@"Lat"] && [data valueForKey:@"Lat"] != [NSNull null]) ? [data valueForKey:@"Lat"] : @"";
        _lon = ([data valueForKey:@"Lon"] && [data valueForKey:@"Lon"] != [NSNull null]) ? [data valueForKey:@"Lon"] : @"";
        _postal = ([data valueForKey:@"Postal"] && [data valueForKey:@"Postal"] != [NSNull null]) ? [data valueForKey:@"Postal"] : @"";
        _province = ([data valueForKey:@"Province"] && [data valueForKey:@"Province"] != [NSNull null]) ? [data valueForKey:@"Province"] : @"";
        
        [self prepareFullAddress];
    }
}

- (void)prepareFullAddress {
    @try {
        if (![[UTIL trim:_address] isEqual: @""]) {
            if (![_fullAddress isEqual: @""]) {
                _fullAddress = [_fullAddress stringByAppendingFormat:@"%@", @", "];
            }
            _fullAddress = [_fullAddress stringByAppendingFormat:@"%@", [UTIL trim:_address]];
        }
        if (![[UTIL trim:_city] isEqual: @""]) {
            if (![_fullAddress isEqual: @""]) {
                _fullAddress = [_fullAddress stringByAppendingFormat:@"%@", @", "];
            }
            _fullAddress = [_fullAddress stringByAppendingFormat:@"%@", [UTIL trim:_city]];
        }
        if (![[UTIL trim:_province] isEqual: @""]) {
            if (![_fullAddress isEqual: @""]) {
                _fullAddress = [_fullAddress stringByAppendingFormat:@"%@", @", "];
            }
            _fullAddress = [_fullAddress stringByAppendingFormat:@"%@", [UTIL trim:_province]];
        }
        
        if ([[UTIL trim:_fullAddress] isEqual: @""]) {
            _fullAddress = NSLocalizedStringFromTable(@"no_address", [UTIL getLanguage], @"");
        }
    }
    @catch (NSException *exception) {
        _fullAddress = @"";
    }
    @finally {
        //{"Invalid object name 'FOS_XactSyncTest.dbo.XactSync_ClaimTrakLink'."}
    }
}

@end
