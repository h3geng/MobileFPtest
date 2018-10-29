//
//  FosChat.m
//  cg
//
//  Created by Ashot Navasardyan on 2016-02-19.
//  Copyright © 2016 FirstOnSite L.P. All rights reserved.
//

#import "FosChat.h"

@implementation FosChat

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

- (void)initWithData:(NSMutableArray *)data {
    @try {
        _chatId = ([data valueForKey:@"Id"] && [data valueForKey:@"Id"] != [NSNull null]) ? [[data valueForKey:@"Id"] intValue] : 0;
        _accountName = ([data valueForKey:@"AccountName"] && [data valueForKey:@"AccountName"] != [NSNull null]) ? [data valueForKey:@"AccountName"] : @"";
        _accountGuid = ([data valueForKey:@"AccountGuid"] && [data valueForKey:@"AccountGuid"] != [NSNull null]) ? [data valueForKey:@"AccountGuid"] : @"";
        _started = ([data valueForKey:@"Started"] && [data valueForKey:@"Started"] != [NSNull null]) ? [data valueForKey:@"Started"] : @"";
        _subject = ([data valueForKey:@"Subject"] && [data valueForKey:@"Subject"] != [NSNull null]) ? [data valueForKey:@"Subject"] : @"";
        
        if (([data valueForKey:@"Messages"] && [data valueForKey:@"Messages"] != [NSNull null])) {
            for (id item in [data valueForKey:@"Messages"]) {
                FosMessage *message = [[FosMessage alloc] init];
                [message initWithData:item];
                
                [_messages addObject:message];
            }
        }
    }
    @catch (NSException *exception) {
        [ALERT alertWithTitle:@"Error" message:[data valueForKey:@"error"]];
    }
}

@end
