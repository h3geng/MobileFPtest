//
//  Score.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/10/13.
//  Copyright (c) 2013 FirstOnSite. All rights reserved.
//

#import "Score.h"
#import "PhaseScore.h"

@implementation Score

- (id)init {
    self = [super init];
    if (self) {
        _custContact = @"";
        _isException = 0;
        _overall = @"";
        _phaseScores = [[NSMutableArray alloc] init];
        _siteInspect = @"";
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_custContact forKey:@"custContact"];
    [encoder encodeInt:_isException forKey:@"isException"];
    [encoder encodeObject:_overall forKey:@"overall"];
    [encoder encodeObject:_phaseScores forKey:@"phaseScores"];
    [encoder encodeObject:_siteInspect forKey:@"siteInspect"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _custContact = [decoder decodeObjectForKey:@"custContact"];
        _isException = [decoder decodeIntForKey:@"isException"];
        _overall = [decoder decodeObjectForKey:@"overall"];
        _phaseScores = [decoder decodeObjectForKey:@"phaseScores"];
        _siteInspect = [decoder decodeObjectForKey:@"siteInspect"];
    }
    return self;
}

- (void)initWithData:(NSMutableArray *)data {
    if (data) {
        _custContact = ([data valueForKey:@"custContact"] && [data valueForKey:@"custContact"] != [NSNull null]) ? [data valueForKey:@"custContact"] : @"";
        _isException = ([data valueForKey:@"isException"] && [data valueForKey:@"isException"] != [NSNull null]) ? [[data valueForKey:@"isException"] intValue] : 0;
        _overall = ([data valueForKey:@"overall"] && [data valueForKey:@"overall"] != [NSNull null]) ? [data valueForKey:@"overall"] : @"";
        _siteInspect = ([data valueForKey:@"siteInspect"] && [data valueForKey:@"siteInspect"] != [NSNull null]) ? [data valueForKey:@"siteInspect"] : @"";
        
        if ([data valueForKey:@"phaseScores"] && [data valueForKey:@"phaseScores"] != [NSNull null]) {
            _phaseScores = [self createPhaseScores:[data valueForKey:@"phaseScores"]];
        }
    }
}

- (NSMutableArray *)createPhaseScores:(NSMutableArray *)data {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (id item in data) {
        PhaseScore *ps = [[PhaseScore alloc] init];
        [ps initWithData:item];
        
        [array addObject:ps];
    }
    
    return array;
}

@end
