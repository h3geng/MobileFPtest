//
//  Classes.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/11/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Classes : NSObject

@property (nonatomic, strong) NSMutableArray *items;

+ (Classes *)getInstance;

- (void)loadItems;
- (GenericObject *)getClassById:(int)classId;
- (GenericObject *)getClassByName:(NSString *)className;

@end
