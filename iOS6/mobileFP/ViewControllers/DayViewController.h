//
//  DayViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2016-03-15.
//  Copyright © 2016 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimesheetEntry.h"
#import "TimeEntryDetailsViewController.h"

@interface DayViewController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@property UIDatePicker *dayDatePicker;
@property UIPickerView *eventPickerView;

@property NSDateFormatter *dateFormat;
@property NSDateFormatter *eventDateFormat;
@property NSMutableArray *nonBillableCategories;

@property UITextField *eventsSource;
@property NSMutableArray *eventsArray;
@property NSMutableArray *dayEventsArray;
@property GenericObject *selectedEvent;
@property TimesheetEntry *selectedEntry;

@property NSDate *currentDay;

@property float summaryHours;

- (IBAction)addPressed:(id)sender;

@end
