//
//  Note.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/6/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Phase.h"
#import "Claim.h"

@interface Note : NSObject

@property int noteId;
@property int alertPM;
@property Claim *claim;
@property int clientAccess;
@property NSString *dateCreated;
@property NSString *dateRead;
@property NSString *departmentId;
@property Contact *enteredBy;
@property NSString *note;
@property Phase *phase;
@property int regionId;
@property int sendToXact;
@property int sendToXactSuccess;
@property int customerGatewayVisible;
@property Share *share;

- (id)init;
- (void)initWithData:(NSMutableArray *)data;
- (void)load:(void(^)(bool result))completion;

@end
