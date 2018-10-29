//
//  Transactions.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/9/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Inventory.h"
#import "TransactionItem.h"
#import "Phase.h"

@interface Transactions : NSObject

@property (nonatomic, strong) NSMutableArray *items;

+ (Transactions *)getInstance;

- (NSMutableArray *)itemsForType:(int)transactionType parent:(GenericObject *)parent;
- (bool)checkExists:(Inventory *)inventory;
- (void)append:(Inventory *)inventory parentObject:(NSObject *)parentObject;
- (void)removeInventory:(int)inventoryId;
- (void)clean;

- (void)commitInventory:(NSObject *)parentObject inventory:(Inventory *)inventory;

- (NSMutableArray *)transitItems;
- (void)transitClean;
- (NSMutableArray *)returnItems;
- (void)returnClean;
- (NSMutableArray *)branchItems:(NSString *)branchCode;
- (void)branchClean:(NSString *)branchCode;
- (NSMutableArray *)claimItems:(int)claimId;
- (void)claimClean:(int)claimId;

- (void)commitAll:(int)type completion:(void(^)(NSMutableArray* result))completion;
- (void)commit:(NSObject *)parentObject completion:(void(^)(NSMutableArray* result))completion;

- (Inventory *)findInventory:(int)inventoryId;

@end
