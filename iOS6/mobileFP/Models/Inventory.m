//
//  Inventory.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/8/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "Inventory.h"

@implementation Inventory

- (id)init {
    self = [super init];
    if (self) {
        _inventoryId = 0;
        _assetTag = @"";
        _active = true;
        _vendor = @"";
        _jobCostCat = [[GenericObject alloc] init];
        _purchaseDate = nil;
        _purchasePrice = 0;
        _lifeCycle = @"";
        _branch = [[GenericObject alloc] init];
        _currentPhase = @"";
        _itemClass = @"";
        _itemModel = @"";
        _itemNumber = @"";
        _openTransaction = @"";
        _serialNumber = @"";
        _status = [[GenericObject alloc] init];
        _transitBranch = [[GenericObject alloc] init];
        _currentClaim = [[Claim alloc] init];
        _committed = true;
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"MM/dd/yyyy"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:_inventoryId forKey:@"inventoryId"];
    [encoder encodeObject:_assetTag forKey:@"assetTag"];
    [encoder encodeBool:_active forKey:@"active"];
    [encoder encodeObject:_vendor forKey:@"vendor"];
    [encoder encodeObject:_jobCostCat forKey:@"jobCostCat"];
    [encoder encodeObject:_purchaseDate forKey:@"purchaseDate"];
    [encoder encodeInt:_purchasePrice forKey:@"purchasePrice"];
    [encoder encodeObject:_lifeCycle forKey:@"lifeCycle"];
    [encoder encodeObject:_branch forKey:@"branch"];
    [encoder encodeObject:_currentPhase forKey:@"currentPhase"];
    [encoder encodeObject:_itemClass forKey:@"itemClass"];
    [encoder encodeObject:_itemModel forKey:@"itemModel"];
    [encoder encodeObject:_itemNumber forKey:@"itemNumber"];
    [encoder encodeObject:_openTransaction forKey:@"openTransaction"];
    [encoder encodeObject:_serialNumber forKey:@"serialNumber"];
    [encoder encodeObject:_status forKey:@"status"];
    [encoder encodeObject:_transitBranch forKey:@"transitBranch"];
    [encoder encodeObject:_currentClaim forKey:@"currentClaim"];
    [encoder encodeBool:_committed forKey:@"committed"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _inventoryId = [decoder decodeIntForKey:@"inventoryId"];
        _assetTag = [decoder decodeObjectForKey:@"assetTag"];
        _active = [decoder decodeBoolForKey:@"active"];
        _vendor = [decoder decodeObjectForKey:@"vendor"];
        _jobCostCat = [decoder decodeObjectForKey:@"jobCostCat"];
        _purchaseDate = [decoder decodeObjectForKey:@"purchaseDate"];
        _purchasePrice = [decoder decodeIntForKey:@"purchasePrice"];
        _lifeCycle = [decoder decodeObjectForKey:@"lifeCycle"];
        _branch = [decoder decodeObjectForKey:@"branch"];
        _currentPhase = [decoder decodeObjectForKey:@"currentPhase"];
        _itemClass = [decoder decodeObjectForKey:@"itemClass"];
        _itemModel = [decoder decodeObjectForKey:@"itemModel"];
        _itemNumber = [decoder decodeObjectForKey:@"itemNumber"];
        _openTransaction = [decoder decodeObjectForKey:@"openTransaction"];
        _serialNumber = [decoder decodeObjectForKey:@"serialNumber"];
        _status = [decoder decodeObjectForKey:@"status"];
        _transitBranch = [decoder decodeObjectForKey:@"transitBranch"];
        _currentClaim = [decoder decodeObjectForKey:@"currentClaim"];
        _committed = [decoder decodeBoolForKey:@"committed"];
    }
    return self;
}

- (void)initWithData:(NSMutableArray *)data {
    if ([data valueForKey:@"Id"] && [data valueForKey:@"Id"] != [NSNull null]) {
        _inventoryId = [[data valueForKey:@"Id"] intValue];
    }
    if ([data valueForKey:@"AssetTag"] && [data valueForKey:@"AssetTag"] != [NSNull null]) {
        _assetTag = [NSString stringWithFormat:@"%@", [data valueForKey:@"AssetTag"]];
    }
    if ([data valueForKey:@"Active"] && [data valueForKey:@"Active"] != [NSNull null]) {
        _active = [[data valueForKey:@"Active"] boolValue];
    }
    if ([data valueForKey:@"Vendor"] && [data valueForKey:@"Vendor"] != [NSNull null]) {
        _vendor = [data valueForKey:@"Vendor"];
    }
    if ([data valueForKey:@"JobCostCat"] && [data valueForKey:@"JobCostCat"] != [NSNull null]) {
        [_jobCostCat initWithData:(NSMutableArray *)[data valueForKey:@"JobCostCat"]];
    }
    if ([data valueForKey:@"PurchaseDate"] && [data valueForKey:@"PurchaseDate"] != [NSNull null]) {
        NSString *purchaseDateString = [data valueForKey:@"PurchaseDate"];
        if (![[UTIL trim:purchaseDateString] isEqual: @""]) {
            NSArray *dateTimeComponents = [purchaseDateString componentsSeparatedByString: @" "];
            NSArray *dateComponents = [dateTimeComponents[0] componentsSeparatedByString: @"/"];
            NSString *dateString = [NSString stringWithFormat:@"%@/%@/%@", dateComponents[0], dateComponents[1], dateComponents[2]];
            
            _purchaseDate = [_dateFormatter dateFromString:dateString];
        }
    }
    if ([data valueForKey:@"PurchasePrice"] && [data valueForKey:@"PurchasePrice"] != [NSNull null]) {
        _purchasePrice = [[data valueForKey:@"PurchasePrice"] floatValue];
    }
    if ([data valueForKey:@"LifeCycle"] && [data valueForKey:@"LifeCycle"] != [NSNull null]) {
        _lifeCycle = [data valueForKey:@"LifeCycle"];
    }
    if ([data valueForKey:@"Branch"] && [data valueForKey:@"Branch"] != [NSNull null]) {
        [_branch initWithData:[data valueForKey:@"Branch"]];
    }
    if ([data valueForKey:@"CurrentClaim"] && [data valueForKey:@"CurrentClaim"] != [NSNull null]) {
        NSMutableArray *currentClaim = [data valueForKey:@"CurrentClaim"];
        if ([currentClaim valueForKey:@"ClaimIndx"] && [currentClaim valueForKey:@"ClaimIndx"] != [NSNull null]) {
            _currentClaim.claimIndx = [[currentClaim valueForKey:@"ClaimIndx"] intValue];
            _currentClaim.claimNumber = [currentClaim valueForKey:@"ClaimNumber"];
        }
    }
    if ([data valueForKey:@"CurrentPhase"] && [data valueForKey:@"CurrentPhase"] != [NSNull null]) {
        NSMutableArray *phase = [data valueForKey:@"CurrentPhase"];
        if ([phase valueForKey:@"PhaseCode"] && [phase valueForKey:@"PhaseCode"] != [NSNull null]) {
            _currentPhase = [phase valueForKey:@"PhaseCode"];
        }
    }
    if ([data valueForKey:@"ItemClass"] && [data valueForKey:@"ItemClass"] != [NSNull null]) {
        GenericObject *go = [[GenericObject alloc] init];
        [go initWithData:[data valueForKey:@"ItemClass"]];
        _itemClass = go.value;
    }
    if ([data valueForKey:@"ItemModel"] && [data valueForKey:@"ItemModel"] != [NSNull null]) {
        GenericObject *go = [[GenericObject alloc] init];
        [go initWithData:[data valueForKey:@"ItemModel"]];
        _itemModel = go.value;
    }
    if ([data valueForKey:@"ItemNumber"] && [data valueForKey:@"ItemNumber"] != [NSNull null]) {
        _itemNumber = [data valueForKey:@"ItemNumber"];
    }
    if ([data valueForKey:@"OpenTransaction"] && [data valueForKey:@"OpenTransaction"] != [NSNull null]) {
        _openTransaction = [data valueForKey:@"OpenTransaction"];
    }
    if ([data valueForKey:@"SerialNumber"] && [data valueForKey:@"SerialNumber"] != [NSNull null]) {
        _serialNumber = [data valueForKey:@"SerialNumber"];
    }
    if ([data valueForKey:@"Status"] && [data valueForKey:@"Status"] != [NSNull null]) {
        [_status initWithData:[data valueForKey:@"Status"]];
    }
    if ([data valueForKey:@"TransitBranch"] && [data valueForKey:@"TransitBranch"] != [NSNull null]) {
        [_transitBranch initWithData:[data valueForKey:@"TransitBranch"]];
    } else {
        if ([data valueForKey:@"Branch"] && [data valueForKey:@"Branch"] != [NSNull null]) {
            [_transitBranch initWithData:[data valueForKey:@"Branch"]];
        }
    }
}

- (void)reload:(void(^)(bool result))completion {
    [API getItem:USER.sessionId regionId:USER.regionId inventoryId:_inventoryId completion:^(NSMutableArray *result) {
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqualToString: @""]) {
            [self initWithData:[result valueForKey:@"getItemResult"]];
            completion(true);
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
            completion(false);
        }
    }];
}

- (bool)validate {
    bool response = true;
    
    if (!_itemClass || [_itemClass isEqualToString:@""]) {
        response = false;
        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"invalid_item_class", [UTIL getLanguage], @"")];
    } else {
        if (!_itemModel || [_itemModel isEqualToString:@""]) {
            response = false;
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"invalid_item_model", [UTIL getLanguage], @"")];
        } else {
            NSString *tagRegex = @"^[0-9]{7}$";
            NSPredicate *tagTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", tagRegex];
            
            if (![tagTest evaluateWithObject:_assetTag]) {
                response = false;
                [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"invalid_asset_tag", [UTIL getLanguage], @"")];
            } else {
                if (!_branch || [_branch.value isEqualToString:@""]) {
                    response = false;
                    [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"invalid_home_branch", [UTIL getLanguage], @"")];
                } else {
                    if ([_status.value isEqualToString:@""]) {
                        response = false;
                        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"invalid_status", [UTIL getLanguage], @"")];
                    } else {
                        if (!_jobCostCat || [_jobCostCat.genericId isEqualToString:@"0"]) {
                            response = false;
                            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"invalid_job_cost_category", [UTIL getLanguage], @"")];
                        }
                    }
                }
            }
        }
    }
    
    return response;
}

- (void)save:(void(^)(bool result))completion {
    if ([self validate]) {
        if (!_purchasePrice) {
            _purchasePrice = 0;
        }
        if (!_lifeCycle) {
            _lifeCycle = @"0";
        }
        if ([_lifeCycle isEqual:@""]) {
            _lifeCycle = @"0";
        }
        
        [API saveItem:USER.sessionId regionId:USER.regionId location:LOCATION.lastSavedLocation serviceRelatedContent:[self getServiceRelatedContent] completion:^(NSMutableArray *result) {
            NSString *error = @"";
            if ([result valueForKey:@"error"]) {
                error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
            }
            
            if ([error isEqualToString: @""]) {
                NSMutableArray *responseData = [result valueForKey:@"saveItemResult"];
                if (![responseData isKindOfClass:[NSNull class]]) {
                    NSString *message = [responseData valueForKey:@"Message"];
                    
                    if (![message isEqual:[NSNull null]]) {
                        if (![message isEqual: @""]) {
                            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:message];
                            completion(false);
                        } else {
                            completion(true);
                        }
                    } else {
                        completion(true);
                    }
                } else {
                    completion(false);
                }
            } else {
                [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
                completion(false);
            }
        }];
    } else {
        completion(false);
    }
}

- (NSString *)getServiceRelatedContent {
    NSString *purchaseDateString = @"";
    if (!_purchaseDate) {
        purchaseDateString = @"";
    } else {
        purchaseDateString = [_dateFormatter stringFromDate:_purchaseDate];
    }
    
    NSString *data = [NSString stringWithFormat:@"{\"Id\":%d,\"AssetTag\":\"%@\",\"Active\":%d,\"Vendor\":\"%@\",\"JobCostCat\":%@,\"PurchaseDate\":\"%@\",\"PurchasePrice\":\"%f\",\"LifeCycle\":\"%@\",\"ItemNumber\":\"%@\",\"SerialNumber\":\"%@\",\"ItemClass\":%@,\"ItemModel\":%@,\"Condition\":{},\"Region\":{},\"TransitRegion\":{},\"Branch\":%@,\"TransitBranch\":%@,\"Status\":%@,\"CurrentClaim\":{},\"CurrentPhase\":{},\"OpenTransaction\":{}}", _inventoryId, _assetTag, _active, _vendor, [_jobCostCat getServiceRelatedContent], purchaseDateString, _purchasePrice, _lifeCycle, _itemNumber, _serialNumber, [[CLASSES getClassByName:_itemClass] getServiceRelatedContent], [[MODELS getModelByName:_itemModel] getServiceRelatedContent], [[BRANCHES getBranchByName:_branch.value] getServiceRelatedContent], [[BRANCHES getBranchByName:_transitBranch.value] getServiceRelatedContent], [_status getServiceRelatedContent]];
    
    return data;
}

- (void)copyFromInventory:(Inventory *)inventory {
    _assetTag = inventory.assetTag;
    _active = inventory.active;
    _vendor = inventory.vendor;
    _jobCostCat = inventory.jobCostCat;
    _purchaseDate = inventory.purchaseDate;
    _purchasePrice = inventory.purchasePrice;
    _lifeCycle = inventory.lifeCycle;
    _branch = inventory.branch;
    _currentPhase = inventory.currentPhase;
    _itemClass = inventory.itemClass;
    _itemModel = inventory.itemModel;
    _itemNumber = inventory.itemNumber;
    _openTransaction = inventory.openTransaction;
    _serialNumber = inventory.serialNumber;
    _status = inventory.status;
    _transitBranch = inventory.transitBranch;
    _currentClaim = inventory.currentClaim;
    _committed = inventory.committed;
}

@end
