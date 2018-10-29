//
//  Message.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2016-02-03.
//  Copyright © 2016 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

@property int messageId;
@property int parentId;
@property NSString *sentTo;
@property bool isSenderExternal;
@property NSString *senderGUID;
@property NSString *receivedFrom;
@property bool isRecipientExternal;
@property NSString *recipientGUID;

@property NSString *subject;
@property NSString *messageBody;
@property int regionId;
@property int claimIndx;

@property bool isPrivate;
@property NSDate *dateTimeSent;
@property bool sent;

- (id)init;
- (void)initWithData:(NSMutableArray *)data;

@end
