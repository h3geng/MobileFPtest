//
//  PendingPhoto.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-06-01.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import "PendingPhoto.h"

@implementation PendingPhoto

- (id)init {
    self = [super init];
    if (self) {
        _claimIndex = 0;
        _phaseIndex = 0;
        _claimName = @"";
        _phaseName = @"";
        _photos = 0;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:_claimIndex forKey:@"claimIndex"];
    [encoder encodeInt:_phaseIndex forKey:@"phaseIndex"];
    [encoder encodeInt:_photos forKey:@"photos"];
    [encoder encodeObject:_claimName forKey:@"claimName"];
    [encoder encodeObject:_phaseName forKey:@"phaseName"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _claimIndex = [decoder decodeIntForKey:@"claimIndex"];
        _phaseIndex = [decoder decodeIntForKey:@"phaseIndex"];
        _photos = [decoder decodeIntForKey:@"photos"];
        _claimName = [decoder decodeObjectForKey:@"claimName"];
        _phaseName = [decoder decodeObjectForKey:@"phaseName"];
    }
    return self;
}

@end
