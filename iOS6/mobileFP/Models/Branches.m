//
//  Branches.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/9/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "Branches.h"

@implementation Branches

/**
 * Gets the instance of self object.
 *
 * @return instance object.
 */
+ (Branches *)getInstance {
    SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (GenericObject *)getBranchById:(int)branchId {
    GenericObject *returnObject = [[GenericObject alloc] init];
    
    for (GenericObject *branch in self.items) {
        if ([branch.genericId intValue] == branchId) {
            returnObject = branch;
            break;
        }
    }
    
    return returnObject;
}

- (GenericObject *)getBranchByCode:(NSString *)branchCode {
    GenericObject *returnObject = [[GenericObject alloc] init];
    
    for (GenericObject *branch in self.items) {
        if ([[NSString stringWithFormat:@"%@", branch.code] isEqual: branchCode]) {
            returnObject = branch;
            break;
        }
    }
    
    return returnObject;
}

- (GenericObject *)getBranchByName:(NSString *)branchName {
    GenericObject *returnObject = [[GenericObject alloc] init];
    
    for (GenericObject *branch in self.items) {
        if ([[NSString stringWithFormat:@"%@", branch.value] isEqual: branchName]) {
            returnObject = branch;
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
    
    [API getBranches:USER.sessionId regionId:USER.regionId completion:^(NSMutableArray *result) {
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqualToString: @""]) {
            NSMutableArray *responseData = [result valueForKey:@"getBranchesResult"];
            if (![responseData isEqual:[NSNull null]]) {
                for (id branch in responseData) {
                    GenericObject *go = [[GenericObject alloc] init];
                    go.genericId = [branch valueForKey:@"Id"];
                    go.code = [NSString stringWithFormat:@"%@", [branch valueForKey:@"Code"]];
                    go.value = [NSString stringWithFormat:@"%@", [branch valueForKey:@"Value"]];
                    go.parentId = [NSString stringWithFormat:@"%@", [branch valueForKey:@"ParentId"]];
                    [self->_items addObject:go];
                }
            }
        }
    }];
}

@end
