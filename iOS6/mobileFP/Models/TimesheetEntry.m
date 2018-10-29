//
//  TimesheetEntry.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2016-03-22.
//  Copyright © 2016 FirstOnSite. All rights reserved.
//

#import "TimesheetEntry.h"

@implementation TimesheetEntry

- (id)init {
    self = [super init];
    if (self) {
        _entryId = 0;
        _item = [[GenericObject alloc] init];
        _dateTimeFrom = [NSDate date];
        _dateTimeTo = [NSDate date];
        _details = @"";
        _notes = @"";
        _claim = [[Claim alloc] init];
        _phaseIndx = 0;
        _phase = [[Phase alloc] init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:_entryId forKey:@"entryId"];
    [encoder encodeObject:_item forKey:@"item"];
    [encoder encodeObject:_dateTimeFrom forKey:@"dateTimeFrom"];
    [encoder encodeObject:_dateTimeTo forKey:@"dateTimeTo"];
    [encoder encodeObject:_details forKey:@"details"];
    [encoder encodeObject:_notes forKey:@"notes"];
    [encoder encodeObject:_claim forKey:@"claim"];
    [encoder encodeInt:_phaseIndx forKey:@"phaseIndx"];
    [encoder encodeObject:_phase forKey:@"phase"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _entryId = [decoder decodeIntForKey:@"entryId"];
        _item = [decoder decodeObjectForKey:@"item"];
        _dateTimeFrom = [decoder decodeObjectForKey:@"dateTimeFrom"];
        _dateTimeTo = [decoder decodeObjectForKey:@"dateTimeTo"];
        _details = [decoder decodeObjectForKey:@"details"];
        _notes = [decoder decodeObjectForKey:@"notes"];
        _claim = [decoder decodeObjectForKey:@"claim"];
        _phaseIndx = [decoder decodeIntForKey:@"phaseIndx"];
        _phase = [decoder decodeObjectForKey:@"phase"];
    }
    return self;
}

- (void)initWithData:(NSMutableArray *)data categories:(NSMutableArray *)categories {
    _entryId = ([data valueForKey:@"entryId"] && [data valueForKey:@"entryId"] != [NSNull null]) ? [[data valueForKey:@"entryId"] intValue] : 0;
    _item = [[GenericObject alloc] init];
    _item.genericId = ([data valueForKey:@"categoryId"] && [data valueForKey:@"categoryId"] != [NSNull null]) ? [data valueForKey:@"categoryId"] : @"0";
    _item.value = @"On Claim";
    for (GenericObject *go in categories) {
        if ([go.genericId intValue] == [_item.genericId intValue]) {
            _item = go;
        }
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT-4:00"]];
    [df setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
    
    _dateTimeFrom = [df dateFromString:(([data valueForKey:@"dateStart"] && [data valueForKey:@"dateStart"] != [NSNull null]) ? [data valueForKey:@"dateStart"] : @"0")];
    _dateTimeTo = [df dateFromString:(([data valueForKey:@"dateStop"] && [data valueForKey:@"dateStop"] != [NSNull null]) ? [data valueForKey:@"dateStop"] : @"0")];
    _details = @"";
    _notes = ([data valueForKey:@"note"] && [data valueForKey:@"note"] != [NSNull null]) ? [data valueForKey:@"note"] : @"";
    _phaseIndx = ([data valueForKey:@"phaseIndx"] && [data valueForKey:@"phaseIndx"] != [NSNull null]) ? [[data valueForKey:@"phaseIndx"] intValue] : 0;
    _claim = [[Claim alloc] init];
    _claim.claimIndx = ([data valueForKey:@"claimIndx"] && [data valueForKey:@"claimIndx"] != [NSNull null]) ? [[data valueForKey:@"claimIndx"] intValue] : 0;
    /*if (_claim.claimIndx > 0) {
        [_claim load:^(bool result) {
            _phase = [[Phase alloc] init];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"phaseIndx == %d", ([data valueForKey:@"phaseIndx"] && [data valueForKey:@"phaseIndx"] != [NSNull null]) ? [[data valueForKey:@"phaseIndx"] intValue] : 0];
            NSMutableArray *filtered = [[NSMutableArray alloc] initWithArray:_claim.phaseList];
            [filtered filterUsingPredicate:predicate];
            
            if (filtered.count > 0) {
                _phase = [filtered objectAtIndex:0];
            }
        }];
    }*/
}

@end
