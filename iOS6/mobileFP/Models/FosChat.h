//
//  FosChat.h
//  cg
//
//  Created by Ashot Navasardyan on 2016-02-19.
//  Copyright © 2016 FirstOnSite L.P. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FosMessage.h"

@interface FosChat : NSObject

@property int chatId;
@property NSString *accountName;
@property NSString *accountGuid;
@property NSString *started;
@property NSString *subject;
@property NSMutableArray *messages;

- (id)init;
- (void)initWithData:(NSMutableArray *)data;

@end
