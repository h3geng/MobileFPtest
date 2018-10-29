//
//  ClaimsViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 9/27/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyDayEventViewController.h"

@interface ClaimsViewController : UITableViewController <UISearchBarDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *jobsSearchBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *actionsButton;

@property NSMutableArray *items;
@property Claim *selectedClaim;
@property NSString *onSelect;

- (IBAction)actionsPressed:(id)sender;

@end
