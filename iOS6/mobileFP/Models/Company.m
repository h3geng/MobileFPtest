//
//  FPCompanyObject.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/10/13.
//  Copyright (c) 2013 First on Site. All rights reserved.
//

#import "Company.h"

@implementation Company

- (id)init {
    self = [super init];
    if (self) {
        _companyId = 0;
        _regionId = 0;
        _active = 0;
        _address = [[Address alloc] init];
        _approved = 0;
        _branches = [[NSMutableArray alloc] init];
        _cityId = @"";
        _code = @"";
        _companyType = @"";
        _contacts = [[NSMutableArray alloc] init];
        _email = @"";
        _fax = @"";
        _faxFormatted = @"";
        _fullName = @"";
        _globalId = @"";
        _phone = @"";
        _phoneFormatted = @"";
        _profile = @"";
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:_companyId forKey:@"companyId"];
    [encoder encodeInt:_regionId forKey:@"regionId"];
    [encoder encodeInt:_active forKey:@"active"];
    [encoder encodeObject:_address forKey:@"address"];
    [encoder encodeInt:_approved forKey:@"approved"];
    [encoder encodeObject:_branches forKey:@"branches"];
    [encoder encodeObject:_cityId forKey:@"cityId"];
    [encoder encodeObject:_code forKey:@"code"];
    [encoder encodeObject:_companyType forKey:@"companyType"];
    [encoder encodeObject:_contacts forKey:@"contacts"];
    [encoder encodeObject:_email forKey:@"email"];
    [encoder encodeObject:_fax forKey:@"fax"];
    [encoder encodeObject:_faxFormatted forKey:@"faxFormatted"];
    [encoder encodeObject:_fullName forKey:@"fullName"];
    [encoder encodeObject:_globalId forKey:@"globalId"];
    [encoder encodeObject:_phone forKey:@"phone"];
    [encoder encodeObject:_phoneFormatted forKey:@"phoneFormatted"];
    [encoder encodeObject:_profile forKey:@"profile"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _companyId = [decoder decodeIntForKey:@"companyId"];
        _regionId = [decoder decodeIntForKey:@"regionId"];
        _active = [decoder decodeIntForKey:@"active"];
        _address = [decoder decodeObjectForKey:@"address"];
        _approved = [decoder decodeIntForKey:@"approved"];
        _branches = [decoder decodeObjectForKey:@"branches"];
        _cityId = [decoder decodeObjectForKey:@"cityId"];
        _code = [decoder decodeObjectForKey:@"code"];
        _companyType = [decoder decodeObjectForKey:@"companyType"];
        _contacts = [decoder decodeObjectForKey:@"contacts"];
        _email = [decoder decodeObjectForKey:@"email"];
        _fax = [decoder decodeObjectForKey:@"fax"];
        _faxFormatted = [decoder decodeObjectForKey:@"faxFormatted"];
        _fullName = [decoder decodeObjectForKey:@"fullName"];
        _globalId = [decoder decodeObjectForKey:@"globalId"];
        _phone = [decoder decodeObjectForKey:@"phone"];
        _phoneFormatted = [decoder decodeObjectForKey:@"phoneFormatted"];
        _profile = [decoder decodeObjectForKey:@"profile"];
    }
    return self;
}

- (void)reload {
    [API reloadCompany:_companyId completion:^(NSMutableArray *result) {
        NSMutableArray *data = [result valueForKey:@"getCompanyResult"];
        [self initWithData:data];
    }];
}

- (void)initWithData:(NSMutableArray *)data {
    if (data) {
        _active = ([data valueForKey:@"Active"] && [data valueForKey:@"Active"] != [NSNull null]) ? [[data valueForKey:@"Active"] intValue] : 0;
        
        if (([data valueForKey:@"Address"] && [data valueForKey:@"Address"] != [NSNull null])) {
            [_address initWithData:[data valueForKey:@"Address"]];
        }
        
        _approved = ([data valueForKey:@"Approved"] && [data valueForKey:@"Approved"] != [NSNull null]) ? [[data valueForKey:@"Approved"] intValue] : 0;
        //todo _branches = [self createBranches:[data valueForKey:@"Branches"]];
        
        _cityId = ([data valueForKey:@"CityId"] && [data valueForKey:@"CityId"] != [NSNull null]) ? [data valueForKey:@"CityId"] : @"";
        _code = ([data valueForKey:@"Code"] && [data valueForKey:@"Code"] != [NSNull null]) ? [data valueForKey:@"Code"] : @"";
        _companyType = ([data valueForKey:@"CompanyType"] && [data valueForKey:@"CompanyType"] != [NSNull null]) ? [data valueForKey:@"CompanyType"] : @"";
        
        //todo _contacts = [self createContacts:[data valueForKey:@"Contacts"]];
        
        _email = ([data valueForKey:@"Email"] && [data valueForKey:@"Email"] != [NSNull null]) ? [data valueForKey:@"Email"] : @"";
        
        _fax = ([data valueForKey:@"Fax"] && [data valueForKey:@"Fax"] != [NSNull null]) ? [data valueForKey:@"Fax"] : @"";
        _faxFormatted = [UTIL formatPhone:_fax];
        
        _fullName = ([data valueForKey:@"FullName"] && [data valueForKey:@"FullName"] != [NSNull null]) ? [data valueForKey:@"FullName"] : @"";
        _globalId = ([data valueForKey:@"GlobalId"] && [data valueForKey:@"GlobalId"] != [NSNull null]) ? [data valueForKey:@"GlobalId"] : @"";
        _companyId = ([data valueForKey:@"Id"] && [data valueForKey:@"Id"] != [NSNull null]) ? [[data valueForKey:@"Id"] intValue] : 0;
        
        _phone = ([data valueForKey:@"Phone"] && [data valueForKey:@"Phone"] != [NSNull null]) ? [data valueForKey:@"Phone"] : @"";
        _phoneFormatted = [UTIL formatPhone:_phone];
        
        _profile = ([data valueForKey:@"Profile"] && [data valueForKey:@"Profile"] != [NSNull null]) ? [data valueForKey:@"Profile"] : @"";
        _regionId = ([data valueForKey:@"RegionId"] && [data valueForKey:@"RegionId"] != [NSNull null]) ? [[data valueForKey:@"RegionId"] intValue] : 0;
    }
}

@end
