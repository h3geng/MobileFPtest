//
//  ClaimWorkOrdersViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 1/7/15.
//  Copyright (c) 2015 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkOrder.h"

@interface ClaimWorkOrdersViewController : UITableViewController

@property Claim *claim;
@property NSMutableArray *items;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *actionsButton;
- (IBAction)actionsPressed:(id)sender;

@end
