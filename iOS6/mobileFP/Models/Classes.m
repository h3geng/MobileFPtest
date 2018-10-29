//
//  Classes.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/11/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "Classes.h"

@implementation Classes

/**
 * Gets the instance of self object.
 *
 * @return instance object.
 */
+ (Classes *)getInstance {
    SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (GenericObject *)getClassById:(int)classId {
    GenericObject *returnObject = [[GenericObject alloc] init];
    
    for (GenericObject *class in self.items) {
        if ([class.genericId intValue] == classId) {
            returnObject = class;
            break;
        }
    }
    
    return returnObject;
}

- (GenericObject *)getClassByName:(NSString *)className {
    GenericObject *returnObject = [[GenericObject alloc] init];
    
    for (GenericObject *class in self.items) {
        if ([[NSString stringWithFormat:@"%@", class.value] isEqual: className]) {
            returnObject = class;
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
    
    [API getClasses:USER.sessionId regionId:USER.regionId completion:^(NSMutableArray *result) {
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqualToString: @""]) {
            if ([result valueForKey:@"getClassesResult"] && [result valueForKey:@"getClassesResult"] != [NSNull null]) {
                NSMutableArray *responseData = [result valueForKey:@"getClassesResult"];
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
