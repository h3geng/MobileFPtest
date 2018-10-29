//
//  KpiObject.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/10/13.
//  Copyright (c) 2013 First on Site. All rights reserved.
//

#import "Kpi.h"

@implementation Kpi

- (id)init {
    self = [super init];
    if (self) {
        _actuals = [[Actual alloc] init];
        _claimIndx = 0;
        _scoreType = 0;
        _scores = [[Score alloc] init];
        _targets = @"";
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_actuals forKey:@"actuals"];
    [encoder encodeInt:_claimIndx forKey:@"claimIndx"];
    [encoder encodeInt:_scoreType forKey:@"scoreType"];
    [encoder encodeObject:_scores forKey:@"scores"];
    [encoder encodeObject:_targets forKey:@"targets"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _actuals = [decoder decodeObjectForKey:@"actuals"];
        _claimIndx = [decoder decodeIntForKey:@"claimIndx"];
        _scoreType = [decoder decodeIntForKey:@"scoreType"];
        _scores = [decoder decodeObjectForKey:@"scores"];
        _targets = [decoder decodeObjectForKey:@"targets"];
    }
    return self;
}

- (void)initWithData:(NSMutableArray *)data {
    if (data) {
        if ([data valueForKey:@"actuals"] && [data valueForKey:@"actuals"] != [NSNull null]) {
            [_actuals initWithData:[data valueForKey:@"actuals"]];
        }
        
        _claimIndx = ([data valueForKey:@"claimIndx"] && [data valueForKey:@"claimIndx"] != [NSNull null]) ? [[data valueForKey:@"claimIndx"] intValue] : 0;
        _scoreType = ([data valueForKey:@"scoreType"] && [data valueForKey:@"scoreType"] != [NSNull null]) ? [[data valueForKey:@"scoreType"] intValue] : 0;
        
        if ([data valueForKey:@"scores"] && [data valueForKey:@"scores"] != [NSNull null]) {
            [_scores initWithData:[data valueForKey:@"scores"]];
        }
        
        _targets = ([data valueForKey:@"targets"] && [data valueForKey:@"targets"] != [NSNull null]) ? [data valueForKey:@"targets"] : @"";
    }
}

@end
