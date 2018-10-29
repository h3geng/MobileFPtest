//
//  Claim.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 9/27/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Company.h"
#import "Contact.h"
#import "Location.h"
#import "Kpi.h"
#import "FosChat.h"
#import "ClaimOwner.h"

@interface Claim : NSObject

@property int claimIndx;
@property NSString *addressString;
@property Company *adjCompany;
@property Contact *adjuster;
@property GenericObject *branch;
@property NSString *broker;
@property NSString *city;
@property NSString *claimNumber;
@property NSMutableArray *contactList;
@property NSString *dateJobOpen;
@property NSString *insClaim;
@property NSString *insPolicy;
@property Company *insurer;
@property NSMutableArray *inventoryList;
@property Kpi *kPI;
@property CLLocation *location;
@property NSString *lossType;
@property NSString *lossDescription;
@property NSMutableArray *phaseList;
@property NSString *postal;
@property NSString *projectManager;
@property NSString *projectName;
@property NSString *propertyManager;
@property NSString *province;
@property int regionId;
@property NSString *transactionPhase;
@property Address *address;
@property NSMutableArray *chats;
@property FosMessage *lastMessage;
@property ClaimOwner *claimOwner;

- (id)init;
- (void)load:(void(^)(bool result))completion;
- (NSMutableArray *)createContactsList:(NSMutableArray *)data;
- (NSMutableArray *)createInventoryList:(NSMutableArray *)data;
- (NSMutableArray *)createPhaseList:(NSMutableArray *)data;
- (bool)checkExists:(NSObject *)inventory;
- (void)reloadInventory;
- (void)loadChats;

@end
