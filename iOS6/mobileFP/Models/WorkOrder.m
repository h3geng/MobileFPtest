//
//  WorkOrder.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 1/7/15.
//  Copyright (c) 2015 FirstOnSite. All rights reserved.
//

#import "WorkOrder.h"

@implementation WorkOrder

- (id)init {
    self = [super init];
    if (self) {
        _workOrderId = 0;
        _comment = @"";
        _order = 0;
        _phase = [[GenericObject alloc] init];
        _vendor = [[GenericObject alloc] init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:_workOrderId forKey:@"workOrderId"];
    [encoder encodeObject:_comment forKey:@"comment"];
    [encoder encodeInt:_order forKey:@"order"];
    [encoder encodeObject:_phase forKey:@"phase"];
    [encoder encodeObject:_vendor forKey:@"vendor"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _workOrderId = [decoder decodeIntForKey:@"workOrderId"];
        _comment = [decoder decodeObjectForKey:@"comment"];
        _order = [decoder decodeIntForKey:@"order"];
        _phase = [decoder decodeObjectForKey:@"phase"];
        _vendor = [decoder decodeObjectForKey:@"vendor"];
    }
    return self;
}

- (void)initWithData:(NSMutableArray *)data {
    if ([data valueForKey:@"WorkOrderId"] && [data valueForKey:@"WorkOrderId"] != [NSNull null]) {
        _workOrderId = [[data valueForKey:@"WorkOrderId"] intValue];
    }
    if ([data valueForKey:@"Comment"] && [data valueForKey:@"Comment"] != [NSNull null]) {
        _comment = [data valueForKey:@"Comment"];
    }
    if ([data valueForKey:@"Order"] && [data valueForKey:@"Order"] != [NSNull null]) {
        _order = [[data valueForKey:@"Order"] intValue];
    }
    if ([data valueForKey:@"Phase"] && [data valueForKey:@"Phase"] != [NSNull null]) {
        _phase = [[GenericObject alloc] init];
        [_phase initWithData:[data valueForKey:@"Phase"]];
    }
    if ([data valueForKey:@"Vendor"] && [data valueForKey:@"Vendor"] != [NSNull null]) {
        _vendor = [[GenericObject alloc] init];
        [_vendor initWithData:[data valueForKey:@"Vendor"]];
    }
}

@end
