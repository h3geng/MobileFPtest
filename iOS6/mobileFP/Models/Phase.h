//
//  Phase.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/10/13.
//  Copyright (c) 2013 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Contact.h"

@interface Phase : NSObject

@property Contact *cM;
@property NSMutableArray *inventoryList;
@property NSString *openDate;
@property Contact *pA;
@property Contact *pM;
@property NSString *phaseCode;
@property NSString *phaseDesc;
@property NSString *status;
@property NSString *xACode;
@property NSString *est;
@property int phaseIndx;

- (id)init;
- (void)initWithData:(NSMutableArray *)data;

@end
