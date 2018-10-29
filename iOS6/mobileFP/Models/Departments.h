//
//  Departments.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/13/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Departments : NSObject

@property (nonatomic, strong) NSMutableArray *items;

+ (Departments *)getInstance;

- (void)loadItems;
- (GenericObject *)getDepartmentById:(int)departmentId;
- (GenericObject *)getDepartmentByName:(NSString *)departmentName;

@end
