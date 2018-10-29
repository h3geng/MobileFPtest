//
//  Statuses.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/11/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "Statuses.h"

@implementation Statuses

/**
 * Gets the instance of self object.
 *
 * @return instance object.
 */
+ (Statuses *)getInstance {
    SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (GenericObject *)getStatusById:(int)statusId {
    GenericObject *returnObject = [[GenericObject alloc] init];
    
    for (GenericObject *status in self.items) {
        if ([status.genericId intValue] == statusId) {
            returnObject = status;
            break;
        }
    }
    
    return returnObject;
}

- (GenericObject *)getStatusByName:(NSString *)statusName {
    GenericObject *returnObject = [[GenericObject alloc] init];
    
    for (GenericObject *status in self.items) {
        if ([[NSString stringWithFormat:@"%@", status.value] isEqual: statusName]) {
            returnObject = status;
            break;
        }
    }
    
    return returnObject;
}

- (NSMutableArray *)items {
    if (!_items) {
        [self loadItems];
    }
    
    return _items;
}

- (void)loadItems {
    _items = [[NSMutableArray alloc] init];
    
    [API getStatusList:USER.sessionId regionId:USER.regionId completion:^(NSMutableArray *result) {
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqualToString: @""]) {
            if ([result valueForKey:@"getStatusListResult"] && [result valueForKey:@"getStatusListResult"] != [NSNull null]) {
                NSMutableArray *responseData = [result valueForKey:@"getStatusListResult"];
                for (id class in responseData) {
                    GenericObject *go = [[GenericObject alloc] init];
                    [go initWithData:class];
                    
                    [self->_items addObject:go];
                }
            }
        }
    }];
}

- (NSMutableArray *)restrictedItems {
    NSMutableArray *response = [[NSMutableArray alloc] init];
    
    if (!_items) {
        [self loadItems];
    }
    
    for (GenericObject *status in self.items) {
        if ([status.value isEqual: @"Available"] || [status.value isEqual: @"Missing"] || [status.value isEqual: @"Being Repaired"]) {
            [response addObject:status];
        }
    }
    
    return response;
}

@end
