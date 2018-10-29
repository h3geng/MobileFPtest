//
//  Chat.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2016-02-03.
//  Copyright © 2016 FirstOnSite. All rights reserved.
//

#import "Chat.h"

@implementation Chat

- (id)init {
    self = [super init];
    if (self) {
        _chatId = 0;
        _accountName = @"";
        _accountGuid = @"";
        _started = @"";
        _subject = @"";
        
        _messages = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:_chatId forKey:@"chatId"];
    [encoder encodeObject:_accountName forKey:@"accountName"];
    [encoder encodeObject:_accountGuid forKey:@"accountGuid"];
    [encoder encodeObject:_started forKey:@"started"];
    [encoder encodeObject:_subject forKey:@"subject"];
    [encoder encodeObject:_messages forKey:@"messages"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _chatId = [decoder decodeIntForKey:@"chatId"];
        _accountName = [decoder decodeObjectForKey:@"accountName"];
        _accountGuid = [decoder decodeObjectForKey:@"accountGuid"];
        _started = [decoder decodeObjectForKey:@"started"];
        _subject = [decoder decodeObjectForKey:@"subject"];
        _messages = [decoder decodeObjectForKey:@"messages"];
    }
    return self;
}

- (void)initWithData:(NSMutableArray *)data {
    if ([data valueForKey:@"Id"] && [data valueForKey:@"Id"] != [NSNull null]) {
        _chatId = [[data valueForKey:@"Id"] intValue];
    }
    if ([data valueForKey:@"AccountName"] && [data valueForKey:@"AccountName"] != [NSNull null]) {
        _accountName = [data valueForKey:@"AccountName"];
    }
    if ([data valueForKey:@"AccountGuid"] && [data valueForKey:@"AccountGuid"] != [NSNull null]) {
        _accountGuid = [data valueForKey:@"AccountGuid"];
    }
    if ([data valueForKey:@"Started"] && [data valueForKey:@"Started"] != [NSNull null]) {
        _started = [data valueForKey:@"Started"];
    }
    if ([data valueForKey:@"Subject"] && [data valueForKey:@"Subject"] != [NSNull null]) {
        _subject = [data valueForKey:@"Subject"];
    }
    if ([data valueForKey:@"Messages"] && [data valueForKey:@"Messages"] != [NSNull null]) {
        for (id item in [data valueForKey:@"Subject"]) {
            Message *message = [[Message alloc] init];
            [message initWithData:item];
            
            [_messages addObject:message];
        }
    }
}

@end
