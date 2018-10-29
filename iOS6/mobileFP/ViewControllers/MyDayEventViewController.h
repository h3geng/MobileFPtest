//
//  MyDayEventViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2018-05-30.
//  Copyright © 2018 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimesheetEntry.h"

@interface MyDayEventViewController : BaseTableViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate>

@property NSDateFormatter *dateFormat;
@property NSDate *currentDay;
@property NSString *currentDateField;

@property BOOL typeVisible;
@property UIPickerView *pickerType;
@property BOOL startTimeVisible;
@property UIDatePicker *pickerStartTime;
@property BOOL endTimeVisible;
@property UIDatePicker *pickerEndTime;

@property BOOL phaseVisible;
@property UIPickerView *pickerPhase;

@property NSMutableArray *nonBillableCategories;
@property TimesheetEntry *selectedEvent;

- (IBAction)savePressed:(id)sender;

@end
