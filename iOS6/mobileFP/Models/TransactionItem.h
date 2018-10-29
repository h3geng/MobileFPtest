//
//  TransactionItem.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/9/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransactionItem : NSObject

@property Inventory *inventory;
@property NSObject *parentObject;

- (id)init;

@end
