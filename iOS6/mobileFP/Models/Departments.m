//
//  Departments.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/13/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "Departments.h"

@implementation Departments

/**
 * Gets the instance of self object.
 *
 * @return instance object.
 */
+ (Departments *)getInstance {
    SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (GenericObject *)getDepartmentById:(int)departmentId {
    GenericObject *returnObject = [[GenericObject alloc] init];
    
    for (GenericObject *department in self.items) {
        if ([department.genericId intValue] == departmentId) {
            returnObject = department;
            break;
        }
    }
    
    return returnObject;
}

- (GenericObject *)getDepartmentByName:(NSString *)departmentName {
    GenericObject *returnObject = [[GenericObject alloc] init];
    
    for (GenericObject *department in self.items) {
        if ([[NSString stringWithFormat:@"%@", department.value] isEqual: departmentName]) {
            returnObject = department;
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
    
    [API getNoteDepartment:USER.sessionId regionId:USER.regionId completion:^(NSMutableArray *result) {
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqualToString: @""]) {
            if ([result valueForKey:@"d"] && [result valueForKey:@"d"] != [NSNull null]) {
                NSMutableArray *responseData = [result valueForKey:@"d"];
                for (id department in responseData) {
                    GenericObject *go = [[GenericObject alloc] init];
                    go.genericId = [department valueForKey:@"Id"];
                    go.value = [department valueForKey:@"Value"];
                    [self->_items addObject:go];
                }
            }
        }
    }];
}

@end
