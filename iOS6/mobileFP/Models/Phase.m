//
//  Phase.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/10/13.
//  Copyright (c) 2013 FirstOnSite. All rights reserved.
//

#import "Phase.h"

@implementation Phase

- (id)init {
    self = [super init];
    if (self) {
        _cM = [[Contact alloc] init];
        _inventoryList = [[NSMutableArray alloc] init];
        _openDate = @"";
        _pA = [[Contact alloc] init];
        _pM = [[Contact alloc] init];
        _phaseCode = @"";
        _phaseDesc = @"";
        _phaseIndx = 0;
        _status = @"";
        _xACode = @"";
        _est = @"";
    }
    return self;
}

- (void)initWithData:(NSMutableArray *)data {
    if (data) {
        if (([data valueForKey:@"CM"] && [data valueForKey:@"CM"] != [NSNull null])) {
            [_cM initWithData:[data valueForKey:@"CM"]];
        }
        _inventoryList = ([data valueForKey:@"InventoryList"] && [data valueForKey:@"InventoryList"] != [NSNull null]) ? [self createInventoryList:[data valueForKey:@"InventoryList"]] : [[NSMutableArray alloc] init];
        _openDate = ([data valueForKey:@"OpenDate"] && [data valueForKey:@"OpenDate"] != [NSNull null]) ? [data valueForKey:@"OpenDate"] : @"";
        if (([data valueForKey:@"PA"] && [data valueForKey:@"PA"] != [NSNull null])) {
            [_pA initWithData:[data valueForKey:@"PA"]];
        }
        if (([data valueForKey:@"PM"] && [data valueForKey:@"PM"] != [NSNull null])) {
            [_pM initWithData:[data valueForKey:@"PM"]];
        }
        _phaseCode = ([data valueForKey:@"PhaseCode"] && [data valueForKey:@"PhaseCode"] != [NSNull null]) ? [data valueForKey:@"PhaseCode"] : @"";
        _phaseDesc = ([data valueForKey:@"PhaseDesc"] && [data valueForKey:@"PhaseDesc"] != [NSNull null]) ? [data valueForKey:@"PhaseDesc"] : @"";
        _phaseIndx = ([data valueForKey:@"PhaseIndx"] && [data valueForKey:@"PhaseIndx"] != [NSNull null]) ? [[data valueForKey:@"PhaseIndx"] intValue] : 0;
        _status = ([data valueForKey:@"Status"] && [data valueForKey:@"Status"] != [NSNull null]) ? [data valueForKey:@"Status"] : @"";
        _xACode = ([data valueForKey:@"XACode"] && [data valueForKey:@"XACode"] != [NSNull null]) ? [data valueForKey:@"XACode"] : @"";
    }
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_cM forKey:@"cM"];
    [encoder encodeObject:_inventoryList forKey:@"inventoryList"];
    [encoder encodeObject:_openDate forKey:@"openDate"];
    [encoder encodeObject:_pA forKey:@"pA"];
    [encoder encodeObject:_pM forKey:@"pM"];
    [encoder encodeObject:_phaseCode forKey:@"phaseCode"];
    [encoder encodeObject:_phaseDesc forKey:@"phaseDesc"];
    [encoder encodeInt:_phaseIndx forKey:@"phaseIndx"];
    [encoder encodeObject:_status forKey:@"status"];
    [encoder encodeObject:_xACode forKey:@"xACode"];
    [encoder encodeObject:_est forKey:@"est"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _cM = [decoder decodeObjectForKey:@"cM"];
        _inventoryList = [decoder decodeObjectForKey:@"inventoryList"];
        _openDate = [decoder decodeObjectForKey:@"openDate"];
        _pA = [decoder decodeObjectForKey:@"pA"];
        _pM = [decoder decodeObjectForKey:@"pM"];
        _phaseCode = [decoder decodeObjectForKey:@"phaseCode"];
        _phaseDesc = [decoder decodeObjectForKey:@"phaseDesc"];
        _phaseIndx = [decoder decodeIntForKey:@"phaseIndx"];
        _status = [decoder decodeObjectForKey:@"status"];
        _xACode = [decoder decodeObjectForKey:@"xACode"];
        _est = [decoder decodeObjectForKey:@"est"];
    }
    return self;
}

- (NSMutableArray *)createInventoryList:(NSMutableArray *)data {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (id inv in data) {
        Inventory *temp = [[Inventory alloc] init];
        [temp initWithData:inv];
        [array addObject:temp];
    }
    
    return array;
}

@end
