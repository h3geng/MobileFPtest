//
//  ClaimEquipmentViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/6/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Phase.h"

@interface ClaimEquipmentViewController : UITableViewController <UIActionSheetDelegate>

@property Claim *claim;
@property Phase *selectedPhase;
@property Inventory *selectedInventory;
@property Inventory *receivedInventory;

- (void)setSelectionObject:(GenericObject *)item;
- (IBAction)addPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *actionsButton;

@end
