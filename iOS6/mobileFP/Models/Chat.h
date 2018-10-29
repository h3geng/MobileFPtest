//
//  Chat.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2016-02-03.
//  Copyright © 2016 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"

@interface Chat : NSObject

@property int chatId;
@property NSString *accountName;
@property NSString *accountGuid;
@property NSString *started;
@property NSString *subject;
@property NSMutableArray *messages;

- (id)init;
- (void)initWithData:(NSMutableArray *)data;

@end
