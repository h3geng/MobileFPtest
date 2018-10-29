//
//  ClaimDetailsViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 9/29/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimesheetViewController.h"
#import "PaymentsViewController.h"

@interface ClaimDetailsViewController : UITableViewController <UIActionSheetDelegate>

- (IBAction)actionPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *actionsButton;
@property Claim *claim;

//@property(nonatomic, strong, readwrite) UIPopoverController *flipsidePopoverController;

@property(nonatomic, strong, readwrite) NSString *environment;
@property(nonatomic, assign, readwrite) BOOL acceptCreditCards;
@property(nonatomic, strong, readwrite) NSString *resultText;

@end
