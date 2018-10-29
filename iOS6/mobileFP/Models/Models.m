//
//  Models.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/11/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "Models.h"

@implementation Models

/**
 * Gets the instance of self object.
 *
 * @return instance object.
 */
+ (Models *)getInstance {
    SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (GenericObject *)getModelById:(int)modelId {
    GenericObject *returnObject = [[GenericObject alloc] init];
    
    for (GenericObject *model in self.items) {
        if ([model.genericId intValue] == modelId) {
            returnObject = model;
            break;
        }
    }
    
    return returnObject;
}

- (GenericObject *)getModelByName:(NSString *)modelName {
    GenericObject *returnObject = [[GenericObject alloc] init];
    
    for (GenericObject *model in self.items) {
        if ([[NSString stringWithFormat:@"%@", model.value] isEqual: modelName]) {
            returnObject = model;
            break;
        }
    }
    
    return returnObject;
}

- (NSMutableArray *)getModelsByClassId:(int)classId {
    NSMutableArray *response = [[NSMutableArray alloc] init];
    
    for (GenericObject *model in self.items) {
        if ([model.parentId intValue] == classId) {
            [response addObject:model];
        }
    }
    return response;
}

- (NSMutableArray *)items {
    if (!_items) {
        [self loadItems];
    }
    
    return _items;
}

- (void)loadItems {
    _items = [[NSMutableArray alloc] init];
    
    [API getModels:USER.sessionId regionId:USER.regionId classIndex:0 completion:^(NSMutableArray *result) {
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqualToString: @""]) {
            if ([result valueForKey:@"getModelsResult"] && [result valueForKey:@"getModelsResult"] != [NSNull null]) {
                NSMutableArray *responseData = [result valueForKey:@"getModelsResult"];
                for (id model in responseData) {
                    GenericObject *go = [[GenericObject alloc] init];
                    [go initWithData:model];
                    
                    [self->_items addObject:go];
                }
            }
        }
    }];
}

@end
