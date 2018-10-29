//
//  Claim.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 9/27/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "Claim.h"
#import "Phase.h"

@implementation Claim

- (id)init {
    self = [super init];
    if (self) {
        _claimIndx = 0;
        _addressString = @"";
        _adjCompany = [[Company alloc] init];
        _adjuster = [[Contact alloc] init];
        _branch = [[GenericObject alloc] init];
        _broker = @"";
        _city = @"";
        _claimNumber = @"";
        _contactList = [[NSMutableArray alloc] init];
        _dateJobOpen = @"";
        _insClaim = @"";
        _insPolicy = @"";
        _insurer = [[Company alloc] init];
        _inventoryList = [[NSMutableArray alloc] init];
        _kPI = [[Kpi alloc] init];
        _location = nil;
        _lossType = @"";
        _lossDescription = @"";
        _phaseList = [[NSMutableArray alloc] init];
        _postal = @"";
        _projectManager = @"";
        _projectName = @"";
        _propertyManager = @"";
        _province = @"";
        _regionId = 0;
        _transactionPhase = @"";
        _address = [[Address alloc] init];
        _chats = [[NSMutableArray alloc] init];
        _lastMessage = [[FosMessage alloc] init];
        _claimOwner = [[ClaimOwner alloc] init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:_claimIndx forKey:@"claimIndx"];
    [encoder encodeObject:_addressString forKey:@"addressString"];
    [encoder encodeObject:_adjCompany forKey:@"adjCompany"];
    [encoder encodeObject:_adjuster forKey:@"adjuster"];
    [encoder encodeObject:_branch forKey:@"branch"];
    [encoder encodeObject:_broker forKey:@"broker"];
    [encoder encodeObject:_city forKey:@"city"];
    [encoder encodeObject:_claimNumber forKey:@"claimNumber"];
    [encoder encodeObject:_contactList forKey:@"contactList"];
    [encoder encodeObject:_dateJobOpen forKey:@"dateJobOpen"];
    [encoder encodeObject:_insClaim forKey:@"insClaim"];
    [encoder encodeObject:_insPolicy forKey:@"insPolicy"];
    [encoder encodeObject:_insurer forKey:@"insurer"];
    [encoder encodeObject:_inventoryList forKey:@"inventoryList"];
    [encoder encodeObject:_kPI forKey:@"kPI"];
    [encoder encodeObject:_location forKey:@"location"];
    [encoder encodeObject:_lossType forKey:@"lossType"];
    [encoder encodeObject:_lossDescription forKey:@"lossDescription"];
    [encoder encodeObject:_phaseList forKey:@"phaseList"];
    [encoder encodeObject:_postal forKey:@"postal"];
    [encoder encodeObject:_projectManager forKey:@"projectManager"];
    [encoder encodeObject:_projectName forKey:@"projectName"];
    [encoder encodeObject:_propertyManager forKey:@"propertyManager"];
    [encoder encodeObject:_province forKey:@"province"];
    [encoder encodeInt:_regionId forKey:@"regionId"];
    [encoder encodeObject:_transactionPhase forKey:@"transactionPhase"];
    [encoder encodeObject:_address forKey:@"address"];
    [encoder encodeObject:_chats forKey:@"chats"];
    [encoder encodeObject:_claimOwner forKey:@"claimOwner"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _claimIndx = [decoder decodeIntForKey:@"claimIndx"];
        _addressString = [decoder decodeObjectForKey:@"addressString"];
        _adjCompany = [decoder decodeObjectForKey:@"adjCompany"];
        _adjuster = [decoder decodeObjectForKey:@"adjuster"];
        _branch = [decoder decodeObjectForKey:@"branch"];
        _broker = [decoder decodeObjectForKey:@"broker"];
        _city = [decoder decodeObjectForKey:@"city"];
        _claimNumber = [decoder decodeObjectForKey:@"claimNumber"];
        _contactList = [decoder decodeObjectForKey:@"contactList"];
        _dateJobOpen = [decoder decodeObjectForKey:@"dateJobOpen"];
        _insClaim = [decoder decodeObjectForKey:@"insClaim"];
        _insPolicy = [decoder decodeObjectForKey:@"insPolicy"];
        _insurer = [decoder decodeObjectForKey:@"insurer"];
        _inventoryList = [decoder decodeObjectForKey:@"inventoryList"];
        _kPI = [decoder decodeObjectForKey:@"kPI"];
        _location = [decoder decodeObjectForKey:@"location"];
        _lossType = [decoder decodeObjectForKey:@"lossType"];
        _lossDescription = [decoder decodeObjectForKey:@"lossDescription"];
        _phaseList = [decoder decodeObjectForKey:@"phaseList"];
        _postal = [decoder decodeObjectForKey:@"postal"];
        _projectManager = [decoder decodeObjectForKey:@"projectManager"];
        _projectName = [decoder decodeObjectForKey:@"projectName"];
        _propertyManager = [decoder decodeObjectForKey:@"propertyManager"];
        _province = [decoder decodeObjectForKey:@"province"];
        _regionId = [decoder decodeIntForKey:@"regionId"];
        _transactionPhase = [decoder decodeObjectForKey:@"transactionPhase"];
        _address = [decoder decodeObjectForKey:@"address"];
        _chats = [decoder decodeObjectForKey:@"chats"];
        _claimOwner = [decoder decodeObjectForKey:@"claimOwner"];
    }
    return self;
}

- (void)load:(void(^)(bool result))completion {
    [API getJob:USER.sessionId regionId:USER.regionId claimIndex:_claimIndx completion:^(NSMutableArray *result) {
        NSString *error = ([result valueForKey:@"error"]) ? [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]] : @"";
        
        if ([error isEqualToString: @""] && [[result valueForKey:@"getJobResult"] valueForKey:@"ClaimIndx"]) {
            NSMutableArray *responseData = [result valueForKey:@"getJobResult"];
            
            if (![responseData isKindOfClass:[NSNull class]]) {
                self->_addressString = [responseData valueForKey:@"Address"];
                
                self->_adjCompany = [[Company alloc] init];
                [self->_adjCompany initWithData:[responseData valueForKey:@"AdjCompany"]];
                
                self->_adjuster = [[Contact alloc] init];
                [self->_adjuster initWithData:[responseData valueForKey:@"Adjuster"]];
                
                [self->_branch initWithData:[responseData valueForKey:@"Branch"]];
                
                self->_broker = [responseData valueForKey:@"Broker"];
                self->_city = [responseData valueForKey:@"City"];
                self->_claimIndx = [[responseData valueForKey:@"ClaimIndx"] intValue];
                self->_claimNumber = [responseData valueForKey:@"ClaimNumber"];
                
                self->_contactList = [[NSMutableArray alloc] init];
                if ([responseData valueForKey:@"ContactList"] && [responseData valueForKey:@"ContactList"] != [NSNull null]) {
                    self->_contactList = [self createContactsList:[responseData valueForKey:@"ContactList"]];
                }
                
                self->_dateJobOpen = [responseData valueForKey:@"DateJobOpen"];
                self->_insClaim = [responseData valueForKey:@"InsClaim"];
                self->_insPolicy = [responseData valueForKey:@"InsPolicy"];
                
                self->_insurer = [[Company alloc] init];
                [self->_insurer initWithData:[responseData valueForKey:@"Insurer"]];
                
                self->_inventoryList = [[NSMutableArray alloc] init];
                if ([responseData valueForKey:@"InventoryList"] && [responseData valueForKey:@"InventoryList"] != [NSNull null]) {
                    self->_inventoryList = [self createInventoryList:[responseData valueForKey:@"InventoryList"]];
                }
                
                self->_kPI = [[Kpi alloc] init];
                [self->_kPI initWithData:[responseData valueForKey:@"KPI"]];
                
                self->_location = [[CLLocation alloc] initWithLatitude:[[responseData valueForKey:@"Lat"] doubleValue] longitude:[[responseData valueForKey:@"Lon"] doubleValue]];
                self->_lossType = @"";
                if ([responseData valueForKey:@"LossType"] && [responseData valueForKey:@"LossType"] != [NSNull null]) {
                    self->_lossType = [responseData valueForKey:@"LossType"];
                }
                self->_lossDescription = @"";
                if ([responseData valueForKey:@"LossDescription"] && [responseData valueForKey:@"LossDescription"] != [NSNull null]) {
                    self->_lossDescription = [responseData valueForKey:@"LossDescription"];
                }
                
                self->_phaseList = [[NSMutableArray alloc] init];
                if ([responseData valueForKey:@"PhaseList"] && [responseData valueForKey:@"PhaseList"] != [NSNull null]) {
                    self->_phaseList = [self createPhaseList:[responseData valueForKey:@"PhaseList"]];
                }
                
                self->_postal = [responseData valueForKey:@"Postal"];
                self->_projectManager = [responseData valueForKey:@"ProjectManager"];
                self->_projectName = [responseData valueForKey:@"ProjectName"];
                self->_propertyManager = [responseData valueForKey:@"PropertyManager"];
                self->_province = [responseData valueForKey:@"Province"];
                self->_regionId = [[responseData valueForKey:@"RegionId"] intValue];
                
                self->_address.address = self->_addressString;
                self->_address.city = self->_city;
                self->_address.lat = [NSString stringWithFormat:@"%f", self->_location.coordinate.latitude];
                self->_address.lon = [NSString stringWithFormat:@"%f", self->_location.coordinate.longitude];
                self->_address.postal = self->_postal;
                self->_address.province = self->_province;
                
                [self->_address prepareFullAddress];
                
                [self->_claimOwner initWithData:[responseData valueForKey:@"Owner"]];
                
                completion(true);
            } else {
                completion(false);
            }
        } else {
            completion(false);
        }
    }];
}

- (void)reloadInventory {
    [API getJob:USER.sessionId regionId:USER.regionId claimIndex:_claimIndx completion:^(NSMutableArray *result) {
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqualToString: @""]) {
            NSMutableArray *responseData = [result valueForKey:@"getJobResult"];
            if ([responseData valueForKey:@"InventoryList"] && [responseData valueForKey:@"InventoryList"] != [NSNull null]) {
                self->_inventoryList = [self createInventoryList:[responseData valueForKey:@"InventoryList"]];
            }
        }
    }];
}

-(NSMutableArray *)findObject:(NSMutableArray *)data type:(NSString *)type {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"phaseCode == %@", type];
    NSMutableArray *filtered = data;
    [filtered filterUsingPredicate:predicate];
    
    return filtered;
}

- (bool)checkExists:(NSObject *)inventory {
    bool exists = false;
    
    for (Inventory *obj in _inventoryList) {
        Inventory *current = (Inventory *)inventory;
        if (current.inventoryId == obj.inventoryId) {
            exists = true;
            break;
        }
    }
    return exists;
}

- (NSMutableArray *)createContactsList:(NSMutableArray *)data {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSMutableArray *item in data) {
        Contact *contactObject = [[Contact alloc] init];
        contactObject.title = [item valueForKey:@"ContactType"] ? [item valueForKey:@"ContactType"] : @"";
        contactObject.fullName = [item valueForKey:@"FullName"] ? [item valueForKey:@"FullName"] : @"";
        contactObject.email = [item valueForKey:@"Email"] ? [item valueForKey:@"Email"] : @"";
        contactObject.forProduction = [item valueForKey:@"ForProduction"] ? ([[item valueForKey:@"ForProduction"] boolValue]) : false;
        
        [array addObject:contactObject];
    }
    
    return array;
}

- (NSMutableArray *)createInventoryList:(NSMutableArray *)data {
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    for (id inv in data) {
        Inventory *temp = [[Inventory alloc] init];
        [temp initWithData:inv];
        temp.committed = true;
        [array addObject:temp];
    }
    return array;
}

- (NSMutableArray *)createPhaseList:(NSMutableArray *)data {
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    for (id phase in data) {
        Phase *temp = [[Phase alloc] init];
        [temp initWithData:phase];
        [array addObject:temp];
    }
    
    return array;
}

- (void)loadChats {
    [API projectChats:USER.sessionId regionId:_regionId claimIndx:_claimIndx completion:^(NSMutableArray *result) {
        self->_chats = [[NSMutableArray alloc] init];
        
        for (id item in [result valueForKey:@"get_MessagesResult"]) {
            FosChat *chat = [[FosChat alloc] init];
            [chat initWithData:item];
            
            [self->_chats addObject:chat];
        }
        
        [API projectLastMessage:USER.sessionId regionId:self->_regionId claimIndx:self->_claimIndx completion:^(NSMutableArray *result) {
            if ([result valueForKey:@"get_LastMessageResult"]) {
                [self->_lastMessage initWithData:[result valueForKey:@"get_LastMessageResult"]];
            }
        }];
    }];
}

@end
