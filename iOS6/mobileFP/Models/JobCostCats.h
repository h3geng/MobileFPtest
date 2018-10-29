//
//  JobCostCats.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/11/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JobCostCats : NSObject

@property (nonatomic, strong) NSMutableArray *items;

+ (JobCostCats *)getInstance;

- (void)loadItems;
- (GenericObject *)getJobCostCatById:(int)jobCostCatId;
- (GenericObject *)getJobCostCatByName:(NSString *)jobCostCatName;

@end
