//
//  Share.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-09-08.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import "Share.h"

@implementation Share

- (id)init {
    self = [super init];
    if (self) {
        _sendEmail = true;
        _sendPushNotification = true;
        _contacts = [[NSMutableArray alloc] init];
        _regionId = 0;
        _claimId = 0;
        _noteId = 0;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeBool:_sendEmail forKey:@"sendEmail"];
    [encoder encodeBool:_sendPushNotification forKey:@"sendPushNotification"];
    [encoder encodeObject:_contacts forKey:@"contacts"];
    [encoder encodeInt:_regionId forKey:@"regionId"];
    [encoder encodeInt:_claimId forKey:@"claimId"];
    [encoder encodeInt:_noteId forKey:@"noteId"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _sendEmail = [decoder decodeBoolForKey:@"sendEmail"];
        _sendPushNotification = [decoder decodeBoolForKey:@"sendPushNotification"];
        _contacts = [decoder decodeObjectForKey:@"contacts"];
        _regionId = [decoder decodeIntForKey:@"regionId"];
        _claimId = [decoder decodeIntForKey:@"claimId"];
        _noteId = [decoder decodeIntForKey:@"noteId"];
    }
    return self;
}

- (void)send:(void(^)(NSMutableArray* result))completion {
    [API shareNote:USER.sessionId shareObject:self completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

@end
