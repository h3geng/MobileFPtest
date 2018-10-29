//
//  TimeEntryDetailsViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2016-03-24.
//  Copyright © 2016 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimesheetEntry.h"

@interface TimeEntryDetailsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property UIPickerView *phasePickerView;
@property UITextField *phaseSource;

@property Claim *selectedClaim;
@property Phase *selectedPhase;
@property NSMutableArray *currentEvents;

@property TimesheetEntry *item;
@property NSDate *minDate;
@property NSDate *selectedMinDate;
@property NSDate *maxDate;
@property NSInteger sectionCount;
@property NSMutableArray *claims;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

- (IBAction)donePressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;

@end
