//
//  PhaseScoreObject.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/10/13.
//  Copyright (c) 2013 First on Site. All rights reserved.
//

#import "PhaseScore.h"

@implementation PhaseScore

- (id)init {
    self = [super init];
    if (self) {
        _estimate = @"";
        _invoice = @"";
        _lastrev = @"";
        _overall = @"";
        _phaseCode = @"";
        _workAssignToStop = @"";
        _workStartToStop = @"";
        _isException = 0;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_estimate forKey:@"estimate"];
    [encoder encodeObject:_invoice forKey:@"invoice"];
    [encoder encodeObject:_lastrev forKey:@"lastrev"];
    [encoder encodeObject:_overall forKey:@"overall"];
    [encoder encodeObject:_phaseCode forKey:@"phaseCode"];
    [encoder encodeObject:_workAssignToStop forKey:@"workAssignToStop"];
    [encoder encodeObject:_workStartToStop forKey:@"workStartToStop"];
    [encoder encodeInt:_isException forKey:@"isException"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _estimate = [decoder decodeObjectForKey:@"estimate"];
        _invoice = [decoder decodeObjectForKey:@"invoice"];
        _lastrev = [decoder decodeObjectForKey:@"lastrev"];
        _overall = [decoder decodeObjectForKey:@"overall"];
        _phaseCode = [decoder decodeObjectForKey:@"phaseCode"];
        _workAssignToStop = [decoder decodeObjectForKey:@"workAssignToStop"];
        _workStartToStop = [decoder decodeObjectForKey:@"workStartToStop"];
        _isException = [decoder decodeIntForKey:@"isException"];
    }
    return self;
}

- (void)initWithData:(NSMutableArray *)data {
    if (data) {
        _estimate = ([data valueForKey:@"estimate"] && [data valueForKey:@"estimate"] != [NSNull null]) ? [data valueForKey:@"estimate"] : @"";
        _invoice = ([data valueForKey:@"invoice"] && [data valueForKey:@"invoice"] != [NSNull null]) ? [data valueForKey:@"invoice"] : @"";
        _isException = ([data valueForKey:@"isException"] && [data valueForKey:@"isException"] != [NSNull null]) ? [[data valueForKey:@"isException"] intValue] : 0;
        _lastrev = ([data valueForKey:@"lastrev"] && [data valueForKey:@"lastrev"] != [NSNull null]) ? [data valueForKey:@"lastrev"] : @"";
        _overall = ([data valueForKey:@"overall"] && [data valueForKey:@"overall"] != [NSNull null]) ? [data valueForKey:@"overall"] : @"";
        _phaseCode = ([data valueForKey:@"phaseCode"] && [data valueForKey:@"phaseCode"] != [NSNull null]) ? [data valueForKey:@"phaseCode"] : @"";
        _workAssignToStop = ([data valueForKey:@"workAssignToStop"] && [data valueForKey:@"workAssignToStop"] != [NSNull null]) ? [data valueForKey:@"workAssignToStop"] : @"";
        _workStartToStop = ([data valueForKey:@"workStartToStop"] && [data valueForKey:@"workStartToStop"] != [NSNull null]) ? [data valueForKey:@"workStartToStop"] : @"";
    }
}

@end
