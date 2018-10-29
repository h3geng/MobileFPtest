//
//  Note.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/6/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "Note.h"

@implementation Note

- (id)init {
    self = [super init];
    if (self) {
        _noteId = 0;
        _alertPM = 0;
        _claim = [[Claim alloc] init];
        _clientAccess = 0;
        _dateCreated = @"";
        _dateRead = @"";
        _departmentId = @"";
        _enteredBy = [[Contact alloc] init];
        _note = @"";
        _phase = [[Phase alloc] init];
        _regionId = 0;
        _sendToXact = 0;
        _sendToXactSuccess = 0;
        _customerGatewayVisible = 0;
        _share = [[Share alloc] init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:_noteId forKey:@"noteId"];
    [encoder encodeInt:_alertPM forKey:@"alertPM"];
    [encoder encodeObject:_claim forKey:@"claim"];
    [encoder encodeInt:_clientAccess forKey:@"clientAccess"];
    [encoder encodeObject:_dateCreated forKey:@"dateCreated"];
    [encoder encodeObject:_dateRead forKey:@"dateRead"];
    [encoder encodeObject:_departmentId forKey:@"departmentId"];
    [encoder encodeObject:_enteredBy forKey:@"enteredBy"];
    [encoder encodeObject:_note forKey:@"note"];
    [encoder encodeObject:_phase forKey:@"phase"];
    [encoder encodeInt:_regionId forKey:@"regionId"];
    [encoder encodeInt:_sendToXact forKey:@"sendToXact"];
    [encoder encodeInt:_sendToXactSuccess forKey:@"sendToXactSuccess"];
    [encoder encodeInt:_customerGatewayVisible forKey:@"customerGatewayVisible"];
    [encoder encodeObject:_share forKey:@"share"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _noteId = [decoder decodeIntForKey:@"noteId"];
        _alertPM = [decoder decodeIntForKey:@"alertPM"];
        _claim = [decoder decodeObjectForKey:@"claim"];
        _clientAccess = [decoder decodeIntForKey:@"clientAccess"];
        _dateCreated = [decoder decodeObjectForKey:@"dateCreated"];
        _dateRead = [decoder decodeObjectForKey:@"dateRead"];
        _departmentId = [decoder decodeObjectForKey:@"departmentId"];
        _enteredBy = [decoder decodeObjectForKey:@"enteredBy"];
        _note = [decoder decodeObjectForKey:@"note"];
        _phase = [decoder decodeObjectForKey:@"phase"];
        _regionId = [decoder decodeIntForKey:@"regionId"];
        _sendToXact = [decoder decodeIntForKey:@"sendToXact"];
        _sendToXactSuccess = [decoder decodeIntForKey:@"sendToXactSuccess"];
        _customerGatewayVisible = [decoder decodeIntForKey:@"customerGatewayVisible"];
        _share = [decoder decodeObjectForKey:@"share"];
    }
    return self;
}

- (void)initWithData:(NSMutableArray *)data {
    if (data) {
        _noteId = ([data valueForKey:@"Id"] && [data valueForKey:@"Id"] != [NSNull null]) ? [[data valueForKey:@"Id"] intValue] : 0;
        _alertPM = ([data valueForKey:@"alertPM"] && [data valueForKey:@"alertPM"] != [NSNull null]) ? [[data valueForKey:@"alertPM"] intValue] : 0;
        
        NSMutableArray *claimObject = [data valueForKey:@"claim"];
        if (claimObject && [claimObject valueForKey:@"ClaimIndx"] && [claimObject valueForKey:@"ClaimIndx"] != [NSNull null]) {
            _claim.claimIndx = [[claimObject valueForKey:@"ClaimIndx"] intValue];
            //todo [_claim load];
        }
        
        _clientAccess = ([data valueForKey:@"clientAccess"] && [data valueForKey:@"clientAccess"] != [NSNull null]) ? [[data valueForKey:@"clientAccess"] intValue] : 0;
        _dateCreated = ([data valueForKey:@"dateCreated"] && [data valueForKey:@"dateCreated"] != [NSNull null]) ? [UTIL formatDate:[data valueForKey:@"dateCreated"]] : @"";
        _dateRead = ([data valueForKey:@"dateRead"] && [data valueForKey:@"dateRead"] != [NSNull null]) ? [data valueForKey:@"dateRead"] : @"";
        _departmentId = ([data valueForKey:@"departmentId"] && [data valueForKey:@"departmentId"] != [NSNull null]) ? [data valueForKey:@"departmentId"] : @"";
        
        if ([data valueForKey:@"enteredBy"] && [data valueForKey:@"enteredBy"] != [NSNull null]) {
            [_enteredBy initWithData:[data valueForKey:@"enteredBy"]];
        }
        
        _note = ([data valueForKey:@"note"] && [data valueForKey:@"note"] != [NSNull null]) ? [data valueForKey:@"note"] : @"";
        _note = [_note stringByReplacingOccurrencesOfString: @"<br>" withString: @"\n"];
        
        NSMutableArray *phase = [data valueForKey:@"phase"];
        _phase.cM = ([phase valueForKey:@"note"] && [phase valueForKey:@"note"] != [NSNull null]) ? [phase valueForKey:@"CM"] : @"";
        if ([phase valueForKey:@"InventoryList"] && [phase valueForKey:@"InventoryList"] != [NSNull null]) {
            _phase.inventoryList = [self createInventoryList:[phase valueForKey:@"InventoryList"]];
        }
        _phase.openDate = ([phase valueForKey:@"OpenDate"] && [phase valueForKey:@"OpenDate"] != [NSNull null]) ? [phase valueForKey:@"OpenDate"] : @"";
        _phase.pA = ([phase valueForKey:@"PA"] && [phase valueForKey:@"PA"] != [NSNull null]) ? [phase valueForKey:@"PA"] : @"";
        _phase.pM = ([phase valueForKey:@"PM"] && [phase valueForKey:@"PM"] != [NSNull null]) ? [phase valueForKey:@"PM"] : @"";
        _phase.phaseCode = ([phase valueForKey:@"PhaseCode"] && [phase valueForKey:@"PhaseCode"] != [NSNull null]) ? [phase valueForKey:@"PhaseCode"] : @"";
        _phase.phaseDesc = ([phase valueForKey:@"PhaseDesc"] && [phase valueForKey:@"PhaseDesc"] != [NSNull null]) ? [phase valueForKey:@"PhaseDesc"] : @"";
        _phase.phaseIndx = ([phase valueForKey:@"PhaseIndx"] && [phase valueForKey:@"PhaseIndx"] != [NSNull null]) ? [[phase valueForKey:@"PhaseIndx"] intValue] : 0;
        _phase.status = ([phase valueForKey:@"Status"] && [phase valueForKey:@"Status"] != [NSNull null]) ? [phase valueForKey:@"Status"] : @"";
        _phase.xACode = ([phase valueForKey:@"XACode"] && [phase valueForKey:@"XACode"] != [NSNull null]) ? [phase valueForKey:@"XACode"] : @"";
        
        _regionId = ([data valueForKey:@"regionId"] && [data valueForKey:@"regionId"] != [NSNull null]) ? [[data valueForKey:@"regionId"] intValue] : 0;
        _sendToXact = ([data valueForKey:@"sendToXact"] && [data valueForKey:@"sendToXact"] != [NSNull null]) ? [[data valueForKey:@"sendToXact"] intValue] : 0;
        _sendToXactSuccess = ([data valueForKey:@"sendToXactSuccess"] && [data valueForKey:@"sendToXactSuccess"] != [NSNull null]) ? [[data valueForKey:@"sendToXactSuccess"] intValue] : 0;
        
        _customerGatewayVisible = ([data valueForKey:@"customerGatewayVisible"] && [data valueForKey:@"customerGatewayVisible"] != [NSNull null]) ? [[data valueForKey:@"customerGatewayVisible"] intValue] : 1;
    }
}

- (NSMutableArray *)createInventoryList:(NSMutableArray *)data {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (id inv in data) {
        Inventory *item = [[Inventory alloc] init];
        item.assetTag = ([inv valueForKey:@"AssetTag"] && [inv valueForKey:@"AssetTag"] != [NSNull null]) ? [inv valueForKey:@"AssetTag"] : @"";
        if ([inv valueForKey:@"Branch"] && [inv valueForKey:@"Branch"] != [NSNull null]) {
            [item.branch initWithData:[inv valueForKey:@"Branch"]];
        }
        item.currentClaim = ([inv valueForKey:@"CurrentClaim"] && [inv valueForKey:@"CurrentClaim"] != [NSNull null]) ? [inv valueForKey:@"CurrentClaim"] : @"";
        
        NSMutableArray *tempPhase = [data valueForKey:@"CurrentPhase"];
        item.currentPhase = ([tempPhase valueForKey:@"PhaseCode"] && [tempPhase valueForKey:@"PhaseCode"] != [NSNull null]) ? [tempPhase valueForKey:@"PhaseCode"] : @"";
        item.inventoryId = ([inv valueForKey:@"Id"] && [inv valueForKey:@"Id"] != [NSNull null]) ? [[inv valueForKey:@"Id"] intValue] : 0;
        item.itemClass = ([inv valueForKey:@"ItemClass"] && [inv valueForKey:@"ItemClass"] != [NSNull null]) ? [inv valueForKey:@"ItemClass"] : @"";
        item.itemModel = ([inv valueForKey:@"ItemModel"] && [inv valueForKey:@"ItemModel"] != [NSNull null]) ? [inv valueForKey:@"ItemModel"] : @"";
        item.itemNumber = ([inv valueForKey:@"ItemNumber"] && [inv valueForKey:@"ItemNumber"] != [NSNull null]) ? [inv valueForKey:@"ItemNumber"] : @"";
        item.openTransaction = ([inv valueForKey:@"OpenTransaction"] && [inv valueForKey:@"OpenTransaction"] != [NSNull null]) ? [inv valueForKey:@"OpenTransaction"] : @"";
        item.serialNumber = ([inv valueForKey:@"SerialNumber"] && [inv valueForKey:@"SerialNumber"] != [NSNull null]) ? [inv valueForKey:@"SerialNumber"] : @"";
        if ([inv valueForKey:@"Status"] && [inv valueForKey:@"Status"] != [NSNull null]) {
            [item.status initWithData:[inv valueForKey:@"Status"]];
        }
        if ([inv valueForKey:@"TransitBranch"] && [inv valueForKey:@"TransitBranch"] != [NSNull null]) {
            [item.transitBranch initWithData:[inv valueForKey:@"TransitBranch"]];
        }
        
        [array addObject:item];
    }
    
    return array;
}

- (void)load:(void(^)(bool result))completion {
    [API getNoteDetails:USER.sessionId regionId:_regionId claimId:_claim.claimIndx noteId:_noteId completion:^(NSMutableArray *result) {
        NSString *error = ([result valueForKey:@"error"]) ? [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]] : @"";
        
        if ([error isEqualToString: @""]) {
            NSMutableArray *responseData = [result valueForKey:@"getNoteDetailsResult"];
            [self initWithData:responseData];
        }
        
        completion(true);
    }];
}

@end
