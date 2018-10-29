//
//  Inventory.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/8/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericObject.h"
#import "Claim.h"

@interface Inventory : NSObject

@property int inventoryId;
@property NSString *assetTag;
@property bool active;
@property NSString *vendor;
@property GenericObject *jobCostCat;
@property NSDate *purchaseDate;
@property double purchasePrice;
@property NSString *lifeCycle;
@property GenericObject *branch;
@property NSString *currentPhase;
@property NSString *itemClass;
@property NSString *itemModel;
@property NSString *itemNumber;
@property NSString *openTransaction;
@property NSString *serialNumber;
@property GenericObject *status;
@property GenericObject *transitBranch;
@property Claim *currentClaim;
@property bool committed;

@property NSDateFormatter *dateFormatter;

- (id)init;
- (void)initWithData:(NSMutableArray *)data;
- (void)reload:(void(^)(bool result))completion;
- (bool)validate;
- (void)save:(void(^)(bool result))completion;

- (void)copyFromInventory:(Inventory *)inventory;

@end
