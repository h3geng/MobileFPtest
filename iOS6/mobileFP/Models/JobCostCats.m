//
//  JobCostCats.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/11/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "JobCostCats.h"

@implementation JobCostCats

/**
 * Gets the instance of self object.
 *
 * @return instance object.
 */
+ (JobCostCats *)getInstance {
    SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (GenericObject *)getJobCostCatById:(int)jobCostCatId {
    GenericObject *returnObject = [[GenericObject alloc] init];
    
    for (GenericObject *jobCostCat in self.items) {
        if ([jobCostCat.genericId intValue] == jobCostCatId) {
            returnObject = jobCostCat;
            break;
        }
    }
    
    return returnObject;
}

- (GenericObject *)getJobCostCatByName:(NSString *)jobCostCatName {
    GenericObject *returnObject = [[GenericObject alloc] init];
    
    for (GenericObject *jobCostCat in self.items) {
        if ([[NSString stringWithFormat:@"%@", jobCostCat.value] isEqual: jobCostCatName]) {
            returnObject = jobCostCat;
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
    
    [API getEquipmentCostCategories:USER.sessionId regionId:USER.regionId completion:^(NSMutableArray *result) {
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqualToString: @""]) {
            if ([result valueForKey:@"getEquipmentCostCategoriesResult"] && [result valueForKey:@"getEquipmentCostCategoriesResult"] != [NSNull null]) {
                NSMutableArray *responseData = [result valueForKey:@"getEquipmentCostCategoriesResult"];
                for (id class in responseData) {
                    GenericObject *go = [[GenericObject alloc] init];
                    [go initWithData:class];
                    
                    [self->_items addObject:go];
                }
            }
        }
    }];
}

@end
