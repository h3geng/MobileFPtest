//
//  AlertViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/12/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertViewController : UITableViewController

@property NSMutableArray *items;
@property NSMutableArray *viewItems;
@property Claim *selectedClaim;

@property NSString *headerText;
@property NSString *mainTitle;

@end
