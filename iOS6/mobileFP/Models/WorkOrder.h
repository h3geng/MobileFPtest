//
//  WorkOrder.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 1/7/15.
//  Copyright (c) 2015 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WorkOrder : NSObject

@property int workOrderId;
@property NSString *comment;
@property int order;
@property GenericObject *phase;
@property GenericObject *vendor;

- (id)init;
- (void)initWithData:(NSMutableArray *)data;

@end
