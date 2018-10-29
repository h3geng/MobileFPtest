//
//  Timeline.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/10/13.
//  Copyright (c) 2013 FirstOnSite. All rights reserved.
//

#import "Timeline.h"

@implementation Timeline

- (id)init {
    self = [super init];
    if (self) {
        _dateAssigned = @"";
        _dateClosed = @"";
        _dateEstApproved = @"";
        _dateEstimate = @"";
        _dateInvoice = @"";
        _dateLastRevision = @"";
        _dateWorkComplete = @"";
        _dateWorkStart = @"";
        _phaseCode = @"";
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_dateAssigned forKey:@"dateAssigned"];
    [encoder encodeObject:_dateClosed forKey:@"dateClosed"];
    [encoder encodeObject:_dateEstApproved forKey:@"dateEstApproved"];
    [encoder encodeObject:_dateEstimate forKey:@"dateEstimate"];
    [encoder encodeObject:_dateInvoice forKey:@"dateInvoice"];
    [encoder encodeObject:_dateLastRevision forKey:@"dateLastRevision"];
    [encoder encodeObject:_dateWorkComplete forKey:@"dateWorkComplete"];
    [encoder encodeObject:_dateWorkStart forKey:@"dateWorkStart"];
    [encoder encodeObject:_phaseCode forKey:@"phaseCode"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _dateAssigned = [decoder decodeObjectForKey:@"dateAssigned"];
        _dateClosed = [decoder decodeObjectForKey:@"dateClosed"];
        _dateEstApproved = [decoder decodeObjectForKey:@"dateEstApproved"];
        _dateEstimate = [decoder decodeObjectForKey:@"dateEstimate"];
        _dateInvoice = [decoder decodeObjectForKey:@"dateInvoice"];
        _dateLastRevision = [decoder decodeObjectForKey:@"dateLastRevision"];
        _dateWorkComplete = [decoder decodeObjectForKey:@"dateWorkComplete"];
        _dateWorkStart = [decoder decodeObjectForKey:@"dateWorkStart"];
        _phaseCode = [decoder decodeObjectForKey:@"phaseCode"];
    }
    return self;
}

- (void)initWithData:(NSMutableArray *)data {
    if (data) {
        _dateAssigned = ([data valueForKey:@"dateAssigned"] && [data valueForKey:@"dateAssigned"] != [NSNull null]) ? [data valueForKey:@"dateAssigned"] : @"";
        _dateClosed = ([data valueForKey:@"dateClosed"] && [data valueForKey:@"dateClosed"] != [NSNull null]) ? [data valueForKey:@"dateClosed"] : @"";
        _dateEstApproved = ([data valueForKey:@"dateEstApproved"] && [data valueForKey:@"dateEstApproved"] != [NSNull null]) ? [data valueForKey:@"dateEstApproved"] : @"";
        _dateEstimate = ([data valueForKey:@"dateEstimate"] && [data valueForKey:@"dateEstimate"] != [NSNull null]) ? [data valueForKey:@"dateEstimate"] : @"";
        _dateInvoice = ([data valueForKey:@"dateInvoice"] && [data valueForKey:@"dateInvoice"] != [NSNull null]) ? [data valueForKey:@"dateInvoice"] : @"";
        _dateLastRevision = ([data valueForKey:@"dateLastRevision"] && [data valueForKey:@"dateLastRevision"] != [NSNull null]) ? [data valueForKey:@"dateLastRevision"] : @"";
        _dateWorkComplete = ([data valueForKey:@"dateWorkComplete"] && [data valueForKey:@"dateWorkComplete"] != [NSNull null]) ? [data valueForKey:@"dateWorkComplete"] : @"";
        _dateWorkStart = ([data valueForKey:@"dateWorkStart"] && [data valueForKey:@"dateWorkStart"] != [NSNull null]) ? [data valueForKey:@"dateWorkStart"] : @"";
        _phaseCode = ([data valueForKey:@"phaseCode"] && [data valueForKey:@"phaseCode"] != [NSNull null]) ? [data valueForKey:@"phaseCode"] : @"";
    }
}

@end
