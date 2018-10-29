//
//  FosMessage.m
//  cg
//
//  Created by Ashot Navasardyan on 2016-02-19.
//  Copyright © 2016 FirstOnSite L.P. All rights reserved.
//

#import "FosMessage.h"

@implementation FosMessage

- (id)init {
    self = [super init];
    if (self) {
        _messageId = 0;
        _parentId = 0;
        _sent = false;
        _sentTo = @"";
        _isSenderExternal = true;
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
    }
    
    return self;
}

- (void)initWithData:(NSMutableArray *)data {
    @try {
        _messageId = ([data valueForKey:@"Id"] && [data valueForKey:@"Id"] != [NSNull null]) ? [[data valueForKey:@"Id"] intValue] : 0;
        _parentId = ([data valueForKey:@"ParentId"] && [data valueForKey:@"ParentId"] != [NSNull null]) ? [[data valueForKey:@"ParentId"] intValue] : 0;
        _sent = ([data valueForKey:@"Sent"] && [data valueForKey:@"Sent"] != [NSNull null]) ? [[data valueForKey:@"Sent"] boolValue] : false;
        _sentTo = ([data valueForKey:@"SentTo"] && [data valueForKey:@"SentTo"] != [NSNull null]) ? [data valueForKey:@"SentTo"] : @"";
        _isSenderExternal = ([data valueForKey:@"IsSenderExternal"] && [data valueForKey:@"IsSenderExternal"] != [NSNull null]) ? [[data valueForKey:@"IsSenderExternal"] boolValue] : false;
        _senderGUID = ([data valueForKey:@"SenderGUID"] && [data valueForKey:@"SenderGUID"] != [NSNull null]) ? [data valueForKey:@"SenderGUID"] : @"";
        _receivedFrom = ([data valueForKey:@"ReceivedFrom"] && [data valueForKey:@"ReceivedFrom"] != [NSNull null]) ? [data valueForKey:@"ReceivedFrom"] : @"";
        _isRecipientExternal = ([data valueForKey:@"IsRecipientExternal"] && [data valueForKey:@"IsRecipientExternal"] != [NSNull null]) ? [[data valueForKey:@"IsRecipientExternal"] boolValue] : false;
        _recipientGUID = ([data valueForKey:@"RecipientGUID"] && [data valueForKey:@"RecipientGUID"] != [NSNull null]) ? [data valueForKey:@"RecipientGUID"] : @"";
        _subject = ([data valueForKey:@"Subject"] && [data valueForKey:@"Subject"] != [NSNull null]) ? [data valueForKey:@"Subject"] : @"";
        _messageBody = ([data valueForKey:@"MessageBody"] && [data valueForKey:@"MessageBody"] != [NSNull null]) ? [data valueForKey:@"MessageBody"] : @"";
        _regionId = ([data valueForKey:@"RegionId"] && [data valueForKey:@"RegionId"] != [NSNull null]) ? [[data valueForKey:@"RegionId"] intValue] : 0;
        _claimIndx = ([data valueForKey:@"ClaimIndx"] && [data valueForKey:@"ClaimIndx"] != [NSNull null]) ? [[data valueForKey:@"ClaimIndx"] intValue] : 0;
        _isPrivate = ([data valueForKey:@"IsPrivate"] && [data valueForKey:@"IsPrivate"] != [NSNull null]) ? [[data valueForKey:@"IsPrivate"] boolValue] : false;
        
        if (([data valueForKey:@"DateTimeSent"] && [data valueForKey:@"DateTimeSent"] != [NSNull null])) {
            NSString *strDate = [data valueForKey:@"DateTimeSent"];
            _dateTimeSent = [NSDate dateWithTimeIntervalSince1970:[[strDate substringWithRange:NSMakeRange(6, 10)] intValue]]; //[df dateFromString:[strDate stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
        }
    }
    @catch (NSException *exception) {
        [ALERT alertWithTitle:@"Error" message:[data valueForKey:@"Error"]];
    }
}

@end
