//
//  EquipmentDetailsViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 9/27/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Phase.h"

@interface EquipmentDetailsViewController : UITableViewController <UIActionSheetDelegate>

@property Inventory *inventory;
@property bool allowActions;
@property Claim *claimToIssue;
@property GenericObject *branchToIssue;
@property bool reloadOnAppear;
@property bool receivedClaim;

@property bool receiveModeInventory;

@property NSTimer *startTimer;
@property NSTimer *endTimer;

- (IBAction)actionPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *actionButton;
@property UIAlertController *actionSheet;

- (void)setPhaseObject:(GenericObject *)item;
- (void)receivedClaimToIssue:(NSObject *)parent;
- (void)issueToBranch;

@end
