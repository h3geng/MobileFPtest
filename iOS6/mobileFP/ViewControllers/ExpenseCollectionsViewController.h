//
//  ExpenseCollectionsViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-03-22.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExpenseCollectionsViewController : BaseTableViewController

@property NSMutableArray *items;
@property int collectionType;
@property NSString *selectedId;

@property int regionId;
@property int branchId;
@property int categoryId;
@property NSString *departmentId;
@property NSString *jobCostTypeId;

@end
