//
//  EquipmentViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 9/27/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EquipmentViewController : UITableViewController <UIActionSheetDelegate, UISearchBarDelegate>

@property NSMutableArray *items;
@property Inventory *selectedInventory;

@property (weak, nonatomic) IBOutlet UISearchBar *equipmentSearchBar;
- (IBAction)actionsPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *actionsButton;

@end
