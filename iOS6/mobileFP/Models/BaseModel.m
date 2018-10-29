//
//  BaseModel.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-03-21.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import <objc/runtime.h>
#import "BaseModel.h"

@implementation BaseModel

- (NSDictionary *)dictionaryReflectFromAttributes {
    @autoreleasepool {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        unsigned int count = 0;
        objc_property_t *attributes = class_copyPropertyList([self class], &count);
        objc_property_t property;
        NSString *key, *value;
        
        for (int i = 0; i < count; i++) {
            property = attributes[i];
            key = [NSString stringWithUTF8String:property_getName(property)];
            value = [self valueForKey:key];
            [dict setObject:(value ? value : @"") forKey:key];
        }
        
        free(attributes);
        attributes = nil;
        
        return dict;
    }
}

@end
