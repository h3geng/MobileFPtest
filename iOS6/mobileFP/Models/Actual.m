//
//  Actual.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/10/13.
//  Copyright (c) 2013 FirstOnSite. All rights reserved.
//

#import "Actual.h"
#import "Timeline.h"

@implementation Actual

- (id)init {
    self = [super init];
    if (self) {
        _dateCalledIn = @"";
        _dateComplete = @"";
        _dateCustContact = @"";
        _dateSiteInspect = @"";
        _phaseTimelines = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_dateCalledIn forKey:@"dateCalledIn"];
    [encoder encodeObject:_dateComplete forKey:@"dateComplete"];
    [encoder encodeObject:_dateCustContact forKey:@"dateCustContact"];
    [encoder encodeObject:_dateSiteInspect forKey:@"dateSiteInspect"];
    [encoder encodeObject:_phaseTimelines forKey:@"phaseTimelines"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _dateCalledIn = [decoder decodeObjectForKey:@"dateCalledIn"];
        _dateComplete = [decoder decodeObjectForKey:@"dateComplete"];
        _dateCustContact = [decoder decodeObjectForKey:@"dateCustContact"];
        _dateSiteInspect = [decoder decodeObjectForKey:@"dateSiteInspect"];
        _phaseTimelines = [decoder decodeObjectForKey:@"phaseTimelines"];
    }
    return self;
}

- (void)initWithData:(NSMutableArray *)data {
    if (data) {
        _dateCalledIn = ([data valueForKey:@"dateCalledIn"] && [data valueForKey:@"dateCalledIn"] != [NSNull null]) ? [data valueForKey:@"dateCalledIn"] : @"";
        _dateComplete = ([data valueForKey:@"dateComplete"] && [data valueForKey:@"dateComplete"] != [NSNull null]) ? [data valueForKey:@"dateComplete"] : @"";
        _dateCustContact = ([data valueForKey:@"dateCustContact"] && [data valueForKey:@"dateCustContact"] != [NSNull null]) ? [data valueForKey:@"dateCustContact"] : @"";
        _dateSiteInspect = ([data valueForKey:@"dateSiteInspect"] && [data valueForKey:@"dateSiteInspect"] != [NSNull null]) ? [data valueForKey:@"dateSiteInspect"] : @"";
        
        if ([data valueForKey:@"phaseTimelines"] && [data valueForKey:@"phaseTimelines"] != [NSNull null]) {
            _phaseTimelines = [self createPhaseTimelines:[data valueForKey:@"phaseTimelines"]];
        }
    }
}

- (NSMutableArray *)createPhaseTimelines:(NSMutableArray *)data {
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    for (id item in data) {
        Timeline *tl = [[Timeline alloc] init];
        [tl initWithData:item];
        
        [array addObject:tl];
    }
    
    return array;
}

@end
