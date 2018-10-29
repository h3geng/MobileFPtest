//
//  Timeline.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/10/13.
//  Copyright (c) 2013 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Timeline : NSObject

@property NSString *dateAssigned;
@property NSString *dateClosed;
@property NSString *dateEstApproved;
@property NSString *dateEstimate;
@property NSString *dateInvoice;
@property NSString *dateLastRevision;
@property NSString *dateWorkComplete;
@property NSString *dateWorkStart;
@property NSString *phaseCode;

- (id)init;
- (void)initWithData:(NSMutableArray *)data;

@end
