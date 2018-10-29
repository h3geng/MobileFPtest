//
//  Message.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2016-02-03.
//  Copyright © 2016 FirstOnSite. All rights reserved.
//

#import "Message.h"

@implementation Message

- (id)init {
    self = [super init];
    if (self) {
        _messageId = 0;
        _parentId = 0;
        _sentTo = @"";
        _isSenderExternal = false;
        _senderGUID = @"";
        _receivedFrom = @"";
        _isRecipientExternal = false;
        _recipientGUID = @"";
        
        _subject = @"";
        _messageBody = @"";
        _regionId = 0;
        _claimIndx = 0;
        
        _isPrivate = false;
        _dateTimeSent = nil;
        _sent = false;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:_messageId forKey:@"messageId"];
    [encoder encodeInt:_parentId forKey:@"parentId"];
    [encoder encodeObject:_sentTo forKey:@"sentTo"];
    [encoder encodeBool:_isSenderExternal forKey:@"isSenderExternal"];
    [encoder encodeObject:_senderGUID forKey:@"senderGUID"];
    [encoder encodeObject:_receivedFrom forKey:@"receivedFrom"];
    [encoder encodeBool:_isRecipientExternal forKey:@"isRecipientExternal"];
    [encoder encodeObject:_recipientGUID forKey:@"recipientGUID"];
    
    [encoder encodeObject:_subject forKey:@"subject"];
    [encoder encodeObject:_messageBody forKey:@"messageBody"];
    [encoder encodeInt:_regionId forKey:@"regionId"];
    [encoder encodeInt:_claimIndx forKey:@"claimIndx"];
    
    [encoder encodeBool:_isPrivate forKey:@"isPrivate"];
    [encoder encodeObject:_dateTimeSent forKey:@"dateTimeSent"];
    [encoder encodeBool:_sent forKey:@"sent"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _messageId = [decoder decodeIntForKey:@"messageId"];
        _parentId = [decoder decodeIntForKey:@"parentId"];
        _sentTo = [decoder decodeObjectForKey:@"sentTo"];
        _isSenderExternal = [decoder decodeBoolForKey:@"isSenderExternal"];
        _senderGUID = [decoder decodeObjectForKey:@"senderGUID"];
        _receivedFrom = [decoder decodeObjectForKey:@"receivedFrom"];
        _isRecipientExternal = [decoder decodeBoolForKey:@"isRecipientExternal"];
        _recipientGUID = [decoder decodeObjectForKey:@"recipientGUID"];
        
        _subject = [decoder decodeObjectForKey:@"subject"];
        _messageBody = [decoder decodeObjectForKey:@"messageBody"];
        _regionId = [decoder decodeIntForKey:@"regionId"];
        _claimIndx = [decoder decodeIntForKey:@"claimIndx"];
        
        _isPrivate = [decoder decodeBoolForKey:@"isPrivate"];
        _dateTimeSent = [decoder decodeObjectForKey:@"dateTimeSent"];
        _sent = [decoder decodeBoolForKey:@"sent"];
    }
    return self;
}

- (void)initWithData:(NSMutableArray *)data {
    if ([data valueForKey:@"Id"] && [data valueForKey:@"Id"] != [NSNull null]) {
        _messageId = [[data valueForKey:@"Id"] intValue];
    }
    if ([data valueForKey:@"ParentId"] && [data valueForKey:@"ParentId"] != [NSNull null]) {
        _parentId = [[data valueForKey:@"ParentId"] intValue];
    }
    if ([data valueForKey:@"SentTo"] && [data valueForKey:@"SentTo"] != [NSNull null]) {
        _sentTo = [data valueForKey:@"SentTo"];
    }
    if ([data valueForKey:@"IsSenderExternal"] && [data valueForKey:@"IsSenderExternal"] != [NSNull null]) {
        _isSenderExternal = [[data valueForKey:@"IsSenderExternal"] boolValue];
    }
    if ([data valueForKey:@"SenderGUID"] && [data valueForKey:@"SenderGUID"] != [NSNull null]) {
        _senderGUID = [data valueForKey:@"SenderGUID"];
    }
    if ([data valueForKey:@"ReceivedFrom"] && [data valueForKey:@"ReceivedFrom"] != [NSNull null]) {
        _receivedFrom = [data valueForKey:@"ReceivedFrom"];
    }
    if ([data valueForKey:@"IsRecipientExternal"] && [data valueForKey:@"IsRecipientExternal"] != [NSNull null]) {
        _isRecipientExternal = [[data valueForKey:@"IsRecipientExternal"] boolValue];
    }
    if ([data valueForKey:@"RecipientGUID"] && [data valueForKey:@"RecipientGUID"] != [NSNull null]) {
        _recipientGUID = [data valueForKey:@"RecipientGUID"];
    }
    
    if ([data valueForKey:@"Subject"] && [data valueForKey:@"Subject"] != [NSNull null]) {
        _subject = [data valueForKey:@"Subject"];
    }
    if ([data valueForKey:@"MessageBody"] && [data valueForKey:@"MessageBody"] != [NSNull null]) {
        _messageBody = [data valueForKey:@"MessageBody"];
    }
    if ([data valueForKey:@"RegionId"] && [data valueForKey:@"RegionId"] != [NSNull null]) {
        _regionId = [[data valueForKey:@"RegionId"] intValue];
    }
    if ([data valueForKey:@"ClaimIndx"] && [data valueForKey:@"ClaimIndx"] != [NSNull null]) {
        _claimIndx = [[data valueForKey:@"ClaimIndx"] intValue];
    }
    
    if ([data valueForKey:@"IsPrivate"] && [data valueForKey:@"IsPrivate"] != [NSNull null]) {
        _isPrivate = [[data valueForKey:@"IsPrivate"] boolValue];
    }
    if ([data valueForKey:@"DateTimeSent"] && [data valueForKey:@"DateTimeSent"] != [NSNull null]) {
        _dateTimeSent = [data valueForKey:@"DateTimeSent"];
    }
    if ([data valueForKey:@"Sent"] && [data valueForKey:@"Sent"] != [NSNull null]) {
        _sent = [[data valueForKey:@"Sent"] boolValue];
    }
}

@end
