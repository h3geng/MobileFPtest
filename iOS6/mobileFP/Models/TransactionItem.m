//
//  TransactionItem.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/9/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "TransactionItem.h"

@implementation TransactionItem

- (id)init {
    self = [super init];
    if (self) {
        _inventory = [[Inventory alloc] init];
        _parentObject = [[NSObject alloc] init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_inventory forKey:@"inventory"];
    [encoder encodeObject:_parentObject forKey:@"parentObject"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _inventory = [decoder decodeObjectForKey:@"inventory"];
        _parentObject = [decoder decodeObjectForKey:@"parentObject"];
    }
    return self;
}

@end
