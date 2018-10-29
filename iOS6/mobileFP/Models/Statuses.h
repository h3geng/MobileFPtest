//
//  Statuses.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/11/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Statuses : NSObject

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *restrictedItems;

+ (Statuses *)getInstance;

- (void)loadItems;
- (GenericObject *)getStatusById:(int)statusId;
- (GenericObject *)getStatusByName:(NSString *)statusName;

@end
