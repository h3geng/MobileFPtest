//
//  ClaimPhasesViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 4/29/15.
//  Copyright (c) 2015 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClaimPhasesViewController : UITableViewController

@property (strong) Claim *claim;
@property Phase *phase;
@property NSString *headerTitle;
@property NSMutableArray *items;
@property int transactionType;

@end
