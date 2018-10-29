//
//  GenericObject.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/6/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "GenericObject.h"

@implementation GenericObject

- (id)init {
    self = [super init];
    if (self) {
        _code = @"";
        _genericId = @"0";
        _parentId = @"0";
        _value = @"";
    }
    return self;
}

- (void)initWithData:(NSMutableArray *)data {
    _code = ([data valueForKey:@"Code"] && [data valueForKey:@"Code"] != [NSNull null]) ? [data valueForKey:@"Code"] : @"";
    _genericId = ([data valueForKey:@"Id"] && [data valueForKey:@"Id"] != [NSNull null]) ? [data valueForKey:@"Id"] : @"0";
    _parentId = ([data valueForKey:@"ParentId"] && [data valueForKey:@"ParentId"] != [NSNull null]) ? [data valueForKey:@"ParentId"] : @"0";
    _value = ([data valueForKey:@"Value"] && [data valueForKey:@"Value"] != [NSNull null]) ? [data valueForKey:@"Value"] : @"0";
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_code forKey:@"code"];
    [encoder encodeObject:_genericId forKey:@"genericId"];
    [encoder encodeObject:_parentId forKey:@"parentId"];
    [encoder encodeObject:_value forKey:@"value"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _code = [decoder decodeObjectForKey:@"code"];
        _genericId = [decoder decodeObjectForKey:@"genericId"];
        _parentId = [decoder decodeObjectForKey:@"parentId"];
        _value = [decoder decodeObjectForKey:@"value"];
    }
    return self;
}

- (NSString *)getServiceRelatedContent {
    return [NSString stringWithFormat:@"{\"Id\":\"%@\",\"Code\":\"%@\",\"ParentId\":\"%@\",\"Value\":\"%@\"}", _genericId, _code, _parentId, _value];
}

- (id)copyWithZone:(NSZone *)zone {
    GenericObject *another = [[GenericObject allocWithZone: zone] init];
    
    another.code = _code;
    another.genericId = _genericId;
    another.parentId = _parentId;
    another.value = _value;
    
    return another;
}

@end
