//
//  TimesheetViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 9/27/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Phase.h"

@interface TimesheetViewController : BaseTableViewController

@property (strong, nonatomic) IBOutlet UILabel *employeeLabel;
@property (strong, nonatomic) IBOutlet UILabel *claimLabel;
@property (strong, nonatomic) IBOutlet UILabel *phaseLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *hoursLabel;
@property (strong, nonatomic) IBOutlet UILabel *notesLabel;

@property (strong, nonatomic) IBOutlet UILabel *employeeDetailLabel;
@property (strong, nonatomic) IBOutlet UILabel *claimDetailLabel;
@property (strong, nonatomic) IBOutlet UILabel *phaseDetailLabel;
@property (strong, nonatomic) IBOutlet UITextField *dateDetailLabel;
@property (strong, nonatomic) IBOutlet UITextField *hoursDetailLabel;

@property UIDatePicker *claimDatePicker;

@property GenericObject *employee;
@property Claim *claim;
@property GenericObject *phase;
@property NSDate *date;
@property NSDate *dateStart;
@property NSDate *dateEnd;
@property float hours;
@property NSString *notes;

@property NSDateFormatter *dateFormat;

- (IBAction)savePressed:(id)sender;
- (void)refreshTable;
- (void)setSelectionObject:(GenericObject *)item;

@end
