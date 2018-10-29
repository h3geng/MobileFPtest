//
//  TimesheetEntry.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2016-03-22.
//  Copyright © 2016 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimesheetEntry : NSObject

@property int entryId;
@property GenericObject *item;
@property NSDate *dateTimeFrom;
@property NSDate *dateTimeTo;
@property NSString *details;
@property NSString *notes;
@property Claim *claim;
@property int phaseIndx;
@property Phase *phase;

- (id)init;
- (void)initWithData:(NSMutableArray *)data categories:(NSMutableArray *)categories;

@end
