//
//  FosMessage.h
//  cg
//
//  Created by Ashot Navasardyan on 2016-02-19.
//  Copyright © 2016 FirstOnSite L.P. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FosMessage : NSObject

@property int messageId;
@property int parentId;
@property bool sent;
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

- (id)init;
- (void)initWithData:(NSMutableArray *)data;

@end
