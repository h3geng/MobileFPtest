//
//  Transactions.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/9/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "Transactions.h"

@implementation Transactions

/**
 * Gets the instance of self object.
 *
 * @return instance object.
 */
+ (Transactions *)getInstance {
    SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (NSMutableArray *)items {
    [self refreshItems];
    
    return _items;
}

- (NSMutableArray *)itemsForType:(int)transactionType parent:(GenericObject *)parent {
    [self refreshItems];
    
    NSMutableArray *response = [[NSMutableArray alloc] init];
    for (TransactionItem *item in _items) {
        GenericObject *go = (GenericObject *)item.parentObject;
        switch (transactionType) {
            case 1:
                if ([go.code isEqual: @"transit"]) {
                    [response addObject:item];
                }
                break;
            case 2:
                if ([go.code isEqual: @"claim"] && (([go.value isEqual:parent.genericId] && [go.parentId isEqual:parent.parentId]) || [parent.genericId isEqual:@"0"])) {
                    [response addObject:item];
                }
                break;
            case 3:
                if ([go.code isEqual: @"return"]) {
                    [response addObject:item];
                }
                break;
            case 4:
                if ((![go.code isEqual: @"transit"] && ![go.code isEqual: @"claim"] && ![go.code isEqual: @"return"]) && ([go.code isEqual:parent.code] || [parent.code isEqual:@""])) {
                    [response addObject:item];
                }
                break;
        }
    }
    
    return response;
}

- (void)refreshItems {
    _items = [[NSMutableArray alloc] init];
    
    id transactions = [USER_DEFAULTS objectForKey:@"transactions"];
    if (transactions) {
        NSMutableArray *cached = (NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithData:transactions];
        for (TransactionItem *item in cached) {
            [_items addObject:item];
        }
    }
}

- (bool)checkExists:(Inventory *)inventory {
    bool response = false;
    
    for (TransactionItem *item in _items) {
        if (item.inventory.inventoryId == inventory.inventoryId) {
            response = true;
            break;
        }
    }
    
    return response;
}

- (void)append:(Inventory *)inventory parentObject:(NSObject *)parentObject {
    if ([self checkExists:inventory]) {
        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"you_already_have_this_item", [UTIL getLanguage], @"")];
    } else {
        TransactionItem *item = [[TransactionItem alloc] init];
        item.inventory = inventory;
        item.parentObject = parentObject;
        
        id transactions = [USER_DEFAULTS objectForKey:@"transactions"];
        NSMutableArray *cached;
        if (!transactions) {
            cached = [[NSMutableArray alloc] init];
        } else {
            cached = (NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithData:transactions];
        }
        if (!cached) {
            cached = [[NSMutableArray alloc] init];
        }
        [cached addObject:item];
        
        [USER_DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:cached] forKey:@"transactions"];
        [USER_DEFAULTS synchronize];
        
        [self refreshItems];
    }
}

- (void)removeInventory:(int)inventoryId {
    NSMutableArray *transactions = [[NSMutableArray alloc] init];
    
    for (TransactionItem *item in _items) {
        if (item.inventory.inventoryId != inventoryId) {
            [transactions addObject:item];
        }
    }
    
    [USER_DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:transactions] forKey:@"transactions"];
    [USER_DEFAULTS synchronize];
    
    [self refreshItems];
}

- (void)clean {
    NSMutableArray *transactions = [[NSMutableArray alloc] init];
    
    [USER_DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:transactions] forKey:@"transactions"];
    [USER_DEFAULTS synchronize];
    
    [self refreshItems];
}

- (void)commitInventory:(NSObject *)parentObject inventory:(Inventory *)inventory {
    int newStatus = 0;
    int branchId = 0;
    int claimIndx = 0;
    int phaseIndx = 0;
    
    if ([parentObject isKindOfClass:[Claim class]]) {
        Claim *commtItem = (Claim *)parentObject;
        newStatus = 2;
        claimIndx = commtItem.claimIndx;
        if (![commtItem.transactionPhase  isEqual: @""]) {
            for (Phase *po in commtItem.phaseList) {
                if ([po.phaseCode isEqual: commtItem.transactionPhase]) {
                    phaseIndx = po.phaseIndx;
                    break;
                }
            }
        }
    }
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    if ([parentObject isKindOfClass:[GenericObject class]]) {
        GenericObject *commtItem = (GenericObject *)parentObject;
        
        if ([commtItem.code isEqual: @"transit"]) {
            newStatus = 7;
        } else {
            if ([commtItem.code isEqual: @"return"]) {
                newStatus = 1;
            } else {
                newStatus = 6;
                branchId = [commtItem.genericId intValue];
            }
        }
    }
    
    // populate transaction list
    NSString *transactionList = @"[";
    
    NSString *mask = @"{\"regionId\":%d,\"branchId\":\"%d\",\"userId\":\"%@\",\"deliveredById\":\"%@\",\"itemId\":%d,\"longitude\":%f,\"latitude\":%f,\"statusId\":%d,\"deviceDate\":\"%@\",\"returnDate\":\"%@\"}";
    if (claimIndx != 0) {
        mask = @"{\"regionId\":%d,\"branchId\":\"%d\",\"userId\":\"%@\",\"deliveredById\":\"%@\",\"itemId\":%d,\"longitude\":%f,\"latitude\":%f,\"statusId\":%d,\"claimIndx\":%d,\"phaseIndx\":%d,\"deviceDate\":\"%@\"}";
    }
    
    if (branchId != 0) {
        transactionList = [transactionList stringByAppendingString:[NSString stringWithFormat:mask, USER.regionId, branchId, USER.userId, USER.userId, inventory.inventoryId, LOCATION.lastSavedLocation.coordinate.longitude, LOCATION.lastSavedLocation.coordinate.latitude, newStatus, [dateFormatter stringFromDate:currentDate], [NSNull null]]];
    } else {
        if (claimIndx != 0) {
            transactionList = [transactionList stringByAppendingString:[NSString stringWithFormat:mask, USER.regionId, inventory.branch.genericId, USER.userId, USER.userId, inventory.inventoryId, LOCATION.lastSavedLocation.coordinate.longitude, LOCATION.lastSavedLocation.coordinate.latitude, newStatus, claimIndx, phaseIndx, [dateFormatter stringFromDate:currentDate]]];
        }else {
            transactionList = [transactionList stringByAppendingString:[NSString stringWithFormat:mask, USER.regionId, inventory.branch.genericId, USER.userId, USER.userId, inventory.inventoryId, LOCATION.lastSavedLocation.coordinate.longitude, LOCATION.lastSavedLocation.coordinate.latitude, newStatus, [dateFormatter stringFromDate:currentDate], [dateFormatter stringFromDate:currentDate]]];
        }
    }
    
    transactionList = [transactionList stringByAppendingString:@"]"];
    
    [API updateStatus:USER.sessionId transactionList:transactionList completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSString *error = @"";
        if ([result valueForKey:@"Message"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"Message"]];
        }
        
        if ([error isEqualToString: @""]) {
            NSMutableArray *responseData = [result valueForKey:@"updateStatusResult"];
            NSMutableArray *responseResults = [responseData valueForKey:@"Results"];
            if ([responseResults count] > 0) {
                NSArray *errorMessage = (NSArray *)[responseResults valueForKey:@"Message"];
                [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:[errorMessage objectAtIndex:0]];
            }
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
        }
        
        [self removeInventory:inventory.inventoryId];
    }];
}

- (void)commitAll:(int)type completion:(void(^)(NSMutableArray* result))completion {
    NSMutableArray *responseItems = [[NSMutableArray alloc] init];
    
    int newStatus = 0;
    int branchId = 0;
    int claimIndx = 0;
    NSString *phaseIndx;
    
    NSMutableArray *itemsToCommit = [[NSMutableArray alloc] init];
    NSMutableArray *items = _items;
    switch (type) {
        case 0:
            items = [self transitItems];
            break;
        case 1:
            items = [self branchItems:@""];
            break;
        case 2:
            items = [self claimItems:0];
            break;
        case 3:
            items = [self returnItems];
            break;
    }
    
    for (TransactionItem *item in items) {
        newStatus = 0;
        branchId = 0;
        claimIndx = 0;
        phaseIndx = @"";
        
        if ([item.parentObject isKindOfClass:[Claim class]]) {
            Claim *transItem = (Claim *)item.parentObject;
            [itemsToCommit addObject:item.inventory];
            
            newStatus = 2;
            claimIndx = transItem.claimIndx;
            phaseIndx = transItem.transactionPhase;
        }
        
        if ([item.parentObject isKindOfClass:[GenericObject class]]) {
            GenericObject *transItem = (GenericObject *)item.parentObject;
            [itemsToCommit addObject:item.inventory];
            
            if ([transItem.code isEqual: @"transit"]) {
                newStatus = 7;
            } else {
                if ([transItem.code isEqual: @"return"]) {
                    newStatus = 1;
                } else {
                    if ([transItem.code isEqual: @"claim"]) {
                        newStatus = 2;
                        claimIndx = [transItem.value intValue];
                        phaseIndx = transItem.parentId;
                    } else {
                        newStatus = 6;
                        branchId = [transItem.genericId intValue];
                    }
                }
            }
        }
    }
    
    NSString *transactionList = @"[";
    GenericObject *userBranch = (GenericObject *)[BRANCHES getBranchByName:USER.branch.value];
    
    for (Inventory *item in itemsToCommit) {
        if (![transactionList isEqual: @"["]) {
            transactionList = [transactionList stringByAppendingString:@","];
        }
        
        NSString *mask = @"{\"regionId\":%d,\"branchId\":%d,\"userId\":\"%@\",\"deliveredById\":\"%@\",\"itemId\":%d,\"longitude\":\"%f\",\"latitude\":\"%f\",\"statusId\":%d}";
        if (claimIndx != 0) {
            mask = @"{\"regionId\":%d,\"branchId\":%@,\"userId\":\"%@\",\"deliveredById\":\"%@\",\"itemId\":%d,\"longitude\":\"%f\",\"latitude\":\"%f\",\"statusId\":%d,\"claimIndx\":%d,\"phaseIndx\":%@}";
        }
        
        if (branchId != 0) {
            transactionList = [transactionList stringByAppendingString:[NSString stringWithFormat:mask, USER.regionId, branchId, USER.userId, USER.userId, item.inventoryId, LOCATION.lastSavedLocation.coordinate.longitude, LOCATION.lastSavedLocation.coordinate.latitude, newStatus]];
        } else {
            if (claimIndx != 0) {
                transactionList = [transactionList stringByAppendingString:[NSString stringWithFormat:mask, USER.regionId, userBranch.genericId, USER.userId, USER.userId, item.inventoryId, LOCATION.lastSavedLocation.coordinate.longitude, LOCATION.lastSavedLocation.coordinate.latitude, newStatus, claimIndx, phaseIndx]];
            } else {
                transactionList = [transactionList stringByAppendingString:[NSString stringWithFormat:mask, USER.regionId, userBranch.genericId, USER.userId, USER.userId, item.inventoryId, LOCATION.lastSavedLocation.coordinate.longitude, LOCATION.lastSavedLocation.coordinate.latitude, newStatus]];
            }
        }
    }
    
    transactionList = [transactionList stringByAppendingString:@"]"];
    
    [API updateStatus:USER.sessionId transactionList:transactionList completion:^(NSMutableArray *result) {
        NSString *error = @"";
        if ([result valueForKey:@"Message"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"Message"]];
        }
        
        if ([error isEqualToString: @""]) {
            NSMutableArray *responseData = [result valueForKey:@"updateStatusResult"];
            
            if ([responseData count] > 0) {
                NSMutableArray *responseResults = [responseData valueForKey:@"Results"];
                if ([responseData valueForKey:@"Message"] != [NSNull null]) {
                    if (![[responseData valueForKey:@"Message"] isEqualToString:@""]) {
                        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:[responseData valueForKey:@"Message"]];
                    }
                }
                
                for (id resp in responseResults) {
                    GenericObject *obj = [[GenericObject alloc] init];
                    obj.genericId = [resp valueForKey:@"itemId"];
                    if ([resp valueForKey:@"Message"] != [NSNull null]) {
                        obj.value = [resp valueForKey:@"Message"];
                    } else {
                        obj.value = @"";
                    }
                    [responseItems addObject:obj];
                }
                
                if (responseResults.count == 0) {
                    [self clean];
                }
            } else {
                [self clean];
            }
        } else {
            GenericObject *obj = [[GenericObject alloc] init];
            obj.genericId = 0;
            obj.value = error;
            [responseItems addObject:obj];
            
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
        }
        
        completion(responseItems);
    }];
}

- (void)commit:(NSObject *)parentObject completion:(void(^)(NSMutableArray* result))completion {
    NSMutableArray *responseItems = [[NSMutableArray alloc] init];
    
    int newStatus = 0;
    int branchId = 0;
    int claimIndx = 0;
    NSString *phaseIndx;
    
    NSMutableArray *itemsToCommit = [[NSMutableArray alloc] init];
    
    for (TransactionItem *item in self.items) {
        newStatus = 0;
        branchId = 0;
        claimIndx = 0;
        phaseIndx = @"";
        
        if ([item.parentObject class] == [parentObject class]) {
            if ([parentObject isKindOfClass:[Claim class]]) {
                Claim *transItem = (Claim *)item.parentObject;
                Claim *commtItem = (Claim *)parentObject;
                
                if (transItem.claimIndx == commtItem.claimIndx) {
                    [itemsToCommit addObject:item.inventory];
                }
                
                newStatus = 2;
                claimIndx = transItem.claimIndx;
                phaseIndx = ((Inventory *)item.inventory).currentPhase;
                
                for (Phase *po in transItem.phaseList) {
                    if ([po.phaseCode  isEqual: phaseIndx]) {
                        phaseIndx = [NSString stringWithFormat:@"%d", po.phaseIndx];
                        break;
                    }
                }
            }
            
            if ([parentObject isKindOfClass:[GenericObject class]]) {
                GenericObject *transItem = (GenericObject *)item.parentObject;
                GenericObject *commtItem = (GenericObject *)parentObject;
                
                if ([transItem.code isEqual:commtItem.code] && [transItem.value isEqual:commtItem.value]) {
                    [itemsToCommit addObject:item.inventory];
                }
                
                if ([transItem.code isEqual: @"transit"]) {
                    newStatus = 7;
                }else {
                    if ([transItem.code isEqual: @"return"]) {
                        newStatus = 1;
                    }else {
                        if ([transItem.code isEqual: @"claim"]) {
                            newStatus = 2;
                            claimIndx = [transItem.value intValue];
                            phaseIndx = transItem.parentId;
                        } else {
                            newStatus = 6;
                            branchId = [transItem.genericId intValue];
                        }
                    }
                }
            }
        }
    }
    
    NSString *transactionList = @"[";
    
    //GenericObject *userBranch = (GenericObject *)[self.branches getBranchByName:self.user.branch.value];
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    for (Inventory *item in itemsToCommit) {
        if (![transactionList isEqual: @"["]) {
            transactionList = [transactionList stringByAppendingString:@","];
        }
        
        NSString *mask = @"{\"regionId\":%d,\"branchId\":%@,\"userId\":\"%@\",\"deliveredById\":\"%@\",\"itemId\":%d,\"longitude\":%f,\"latitude\":%f,\"statusId\":%d,\"deviceDate\":\"%@\"}";
        if (claimIndx != 0) {
            mask = @"{\"regionId\":%d,\"branchId\":%@,\"userId\":\"%@\",\"deliveredById\":\"%@\",\"itemId\":%d,\"longitude\":%f,\"latitude\":%f,\"statusId\":%d,\"claimIndx\":%d,\"phaseIndx\":\"%@\",\"deviceDate\":\"%@\"}";
        }
        
        if (branchId != 0) {
            transactionList = [transactionList stringByAppendingString:[NSString stringWithFormat:mask, USER.regionId, [NSString stringWithFormat:@"%d", branchId], USER.userId, USER.userId, item.inventoryId, LOCATION.lastSavedLocation.coordinate.longitude, LOCATION.lastSavedLocation.coordinate.latitude, newStatus, [dateFormatter stringFromDate:currentDate]]];
        }else {
            
            if (claimIndx != 0) {
                transactionList = [transactionList stringByAppendingString:[NSString stringWithFormat:mask, USER.regionId, item.branch.genericId, USER.userId, USER.userId, item.inventoryId, LOCATION.lastSavedLocation.coordinate.longitude, LOCATION.lastSavedLocation.coordinate.latitude, newStatus, claimIndx, phaseIndx, [dateFormatter stringFromDate:currentDate]]];
            }else {
                transactionList = [transactionList stringByAppendingString:[NSString stringWithFormat:mask, USER.regionId, item.branch.genericId, USER.userId, USER.userId, item.inventoryId, LOCATION.lastSavedLocation.coordinate.longitude, LOCATION.lastSavedLocation.coordinate.latitude, newStatus, [dateFormatter stringFromDate:currentDate]]];
            }
        }
    }
    
    transactionList = [transactionList stringByAppendingString:@"]"];
    
    [API updateStatus:USER.sessionId transactionList:transactionList completion:^(NSMutableArray *result) {
        NSString *error = @"";
        if ([result valueForKey:@"Message"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"Message"]];
        }
        
        if ([error isEqualToString: @""]) {
            NSMutableArray *responseData = [result valueForKey:@"updateStatusResult"];
            
            if ([responseData count] > 0) {
                NSMutableArray *responseResults = [responseData valueForKey:@"Results"];
                
                for (id resp in responseResults) {
                    GenericObject *obj = [[GenericObject alloc] init];
                    obj.genericId = [resp valueForKey:@"itemId"];
                    if ([resp valueForKey:@"Message"] != [NSNull null]) {
                        obj.value = [resp valueForKey:@"Message"];
                    } else {
                        obj.value = @"";
                    }
                    [responseItems addObject:obj];
                }
            }
        } else {
            GenericObject *obj = [[GenericObject alloc] init];
            obj.genericId = 0;
            obj.value = error;
            [responseItems addObject:obj];
            
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
        }
        
        // clean by parent
        if ([parentObject isKindOfClass:[Claim class]]) {
            Claim *commtItem = (Claim *)parentObject;
            
            [self claimClean:commtItem.claimIndx];
        } else {
            if ([parentObject isKindOfClass:[GenericObject class]]) {
                GenericObject *transItem = (GenericObject *)parentObject;
                
                if ([transItem.code isEqual: @"transit"]) {
                    [self transitClean];
                } else {
                    if ([transItem.code isEqual: @"return"]) {
                        [self returnClean];
                    } else {
                        if ([transItem.code isEqual: @"claim"]) {
                            [self claimClean:[transItem.value intValue]];
                        } else {
                            [self branchClean:transItem.code];
                        }
                    }
                }
            }
        }
        
        completion(responseItems);
    }];
}

- (NSMutableArray *)transitItems {
    NSMutableArray *responseItems = [[NSMutableArray alloc] init];
    
    for (id item in self.items) {
        TransactionItem *tio = (TransactionItem *)item;
        if ([tio.parentObject isKindOfClass:[GenericObject class]]) {
            GenericObject *obj = (GenericObject *)tio.parentObject;
            if ([obj.code isEqual: @"transit"]) {
                [responseItems addObject:tio];
            }
        }
    }
    
    return responseItems;
}

- (void)transitClean {
    NSMutableArray *toRemove = [[NSMutableArray alloc] init];
    
    for (id item in self.items) {
        TransactionItem *tio = (TransactionItem *)item;
        if ([tio.parentObject isKindOfClass:[GenericObject class]]) {
            GenericObject *obj = (GenericObject *)tio.parentObject;
            if ([obj.code isEqual: @"transit"]) {
                [toRemove addObject:item];
            }
        }
    }
    
    [_items removeObjectsInArray:toRemove];
    
    [USER_DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:_items] forKey:@"transactions"];
    [USER_DEFAULTS synchronize];
    
    [self refreshItems];
}

- (NSMutableArray *)returnItems {
    NSMutableArray *responseItems = [[NSMutableArray alloc] init];
    
    for (id item in self.items) {
        TransactionItem *tio = (TransactionItem *)item;
        if ([tio.parentObject isKindOfClass:[GenericObject class]]) {
            GenericObject *obj = (GenericObject *)tio.parentObject;
            if ([obj.code isEqual: @"return"]) {
                [responseItems addObject:tio];
            }
        }
    }
    
    return responseItems;
}

- (void)returnClean {
    NSMutableArray *toRemove = [[NSMutableArray alloc] init];
    
    for (id item in self.items) {
        TransactionItem *tio = (TransactionItem *)item;
        if ([tio.parentObject isKindOfClass:[GenericObject class]]) {
            GenericObject *obj = (GenericObject *)tio.parentObject;
            if ([obj.code isEqual: @"return"]) {
                [toRemove addObject:item];
            }
        }
    }
    
    [_items removeObjectsInArray:toRemove];
    
    [USER_DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:_items] forKey:@"transactions"];
    [USER_DEFAULTS synchronize];
    
    [self refreshItems];
}

- (NSMutableArray *)branchItems:(NSString *)branchCode {
    NSMutableArray *responseItems = [[NSMutableArray alloc] init];
    
    for (TransactionItem *item in _items) {
        if ([item.parentObject isKindOfClass:[GenericObject class]]) {
            GenericObject *obj = (GenericObject *)item.parentObject;
            if ([obj.code isEqual: branchCode]) {
                [responseItems addObject:item];
            }
            
            if ([branchCode isEqual: @"branch"] || (![obj.code isEqual: @"transit"] && ![obj.code isEqual: @"return"] && ![obj.code isEqual: @"claim"] && [branchCode isEqualToString:@""])) {
                [responseItems addObject:item];
            }
        }
    }
    
    return responseItems;
}

- (void)branchClean:(NSString *)branchCode {
    NSMutableArray *toRemove = [[NSMutableArray alloc] init];
    
    for (TransactionItem *item in _items) {
        if ([item.parentObject isKindOfClass:[GenericObject class]]) {
            GenericObject *obj = (GenericObject *)item.parentObject;
            if ([obj.code isEqual: branchCode]) {
                [toRemove addObject:item];
            }
            
            if ([branchCode isEqual: @"branch"] || (![obj.code isEqual: @"transit"] && ![obj.code isEqual: @"return"] && ![obj.code isEqual: @"claim"] && [branchCode isEqualToString:@""])) {
                [toRemove addObject:item];
            }
        }
    }
    
    [_items removeObjectsInArray:toRemove];
    
    [USER_DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:_items] forKey:@"transactions"];
    [USER_DEFAULTS synchronize];
    
    [self refreshItems];
}

- (NSMutableArray *)claimItems:(int)claimId {
    NSMutableArray *responseItems = [[NSMutableArray alloc] init];
    
    for (id item in self.items) {
        TransactionItem *transactionItem = (TransactionItem *)item;
        if ([transactionItem.parentObject isKindOfClass:[GenericObject class]]) {
            GenericObject *obj = (GenericObject *)transactionItem.parentObject;
            
            if ([obj.code isEqual: @"claim"] && ([obj.value intValue] == claimId || claimId == 0)) {
                [responseItems addObject:transactionItem];
            }
        }
    }
    
    return responseItems;
}

- (void)claimClean:(int)claimId {
    NSMutableArray *toRemove = [[NSMutableArray alloc] init];
    
    for (TransactionItem *item in _items) {
        if ([item.parentObject isKindOfClass:[Claim class]]) {
            Claim *obj = (Claim *)item.parentObject;
            if (obj.claimIndx == claimId || claimId == 0) {
                [toRemove addObject:item];
            }
        }
        if ([item.parentObject isKindOfClass:[GenericObject class]]) {
            GenericObject *obj = (GenericObject *)item.parentObject;
            if ([obj.code isEqualToString:@"claim"] && ([obj.value integerValue] == claimId || claimId == 0)) {
                [toRemove addObject:item];
            }
        }
    }
    
    [_items removeObjectsInArray:toRemove];
    
    [USER_DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:_items] forKey:@"transactions"];
    [USER_DEFAULTS synchronize];
    
    [self refreshItems];
}

- (Inventory *)findInventory:(int)inventoryId {
    Inventory *response = [[Inventory alloc] init];
    
    for (TransactionItem *item in _items) {
        if (item.inventory.inventoryId == inventoryId) {
            response = item.inventory;
        }
    }
    
    return response;
}

@end
