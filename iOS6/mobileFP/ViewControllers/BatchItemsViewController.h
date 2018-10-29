//
//  BatchItemsViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/9/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BatchItemsViewController : UITableViewController

@property NSString *headerTitle;
@property NSMutableArray *items;
@property (strong) Claim *claim;
@property (strong) Phase *phase;
@property (strong) GenericObject *branch;
@property int transactionType;
@property NSMutableArray *searchedItems;

@end
