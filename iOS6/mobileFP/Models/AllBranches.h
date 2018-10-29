//
//  AllBranches.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2018-09-11.
//  Copyright © 2018 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AllBranches : NSObject

@property (nonatomic, strong) NSMutableArray *items;

+ (Branches *)getInstance;

- (void)loadItems;
- (GenericObject *)getBranchById:(int)branchId;
- (GenericObject *)getBranchByCode:(NSString *)branchCode;
- (GenericObject *)getBranchByName:(NSString *)branchName;

@end
