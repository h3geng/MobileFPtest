//
//  MyDayViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2018-05-30.
//  Copyright © 2018 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyDayEventViewController.h"
#import "TimesheetEntry.h"
#import "UIViewEvent.h"

@interface MyDayViewController : BaseTableViewController

@property UIToolbar *keyboardToolbar;
@property UITextField *currentDateField;
@property NSDateFormatter *dateFormat;
@property NSDate *currentDay;
@property UIDatePicker *dayDatePicker;
@property TimesheetEntry *selectedEvent;

@property NSMutableArray *events;
@property NSCalendar *calendar;

@property CGFloat fullHeight;
@property CGFloat width;
@property NSMutableArray *nonBillableCategories;

- (IBAction)addPressed:(id)sender;

@end
