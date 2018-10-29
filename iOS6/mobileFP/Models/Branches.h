//
//  Branches.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/9/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Branches : NSObject

@property (nonatomic, strong) NSMutableArray *items;

+ (Branches *)getInstance;

- (void)loadItems;
- (GenericObject *)getBranchById:(int)branchId;
- (GenericObject *)getBranchByCode:(NSString *)branchCode;
- (GenericObject *)getBranchByName:(NSString *)branchName;

@end
