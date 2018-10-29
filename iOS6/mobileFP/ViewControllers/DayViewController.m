//
//  DayViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2016-03-15.
//  Copyright © 2016 FirstOnSite. All rights reserved.
//

#import "DayViewController.h"

@interface DayViewController ()

@end

@implementation DayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTimeline:) name:@"updateTimeline" object:nil];
    
    [self setTitle:NSLocalizedStringFromTable(@"my_day", [UTIL getLanguage], @"")];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    _summaryHours = 0;
    
    _dayEventsArray = [[NSMutableArray alloc] init];
    // Begin event picker
    _eventPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    [_eventPickerView setDataSource: self];
    [_eventPickerView setDelegate: self];
    _eventPickerView.showsSelectionIndicator = YES;
    
    _eventsArray = [[NSMutableArray alloc] init];
    
    _eventsSource = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_eventsSource];
    [_eventsSource setInputView:_eventPickerView];
    
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(hidePicker:)];
    UIBarButtonItem *flexibleSpacebutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePicker:)];
    
    pickerToolbar.tintColor = [UTIL darkBlueColor];
    [pickerToolbar setItems:[NSArray arrayWithObjects:cancelButton, flexibleSpacebutton, doneButton, nil] animated:YES];
    _eventsSource.inputAccessoryView = pickerToolbar;
    // end picker
    
    _currentDay = [NSDate date];
    _dayDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [_dayDatePicker setDatePickerMode:UIDatePickerModeDate];
    [_dayDatePicker setMaximumDate:_currentDay];
    
    _dateFormat = [[NSDateFormatter alloc] init];
    [_dateFormat setDateStyle:NSDateFormatterLongStyle];
    [_dateFormat setTimeStyle:NSDateFormatterNoStyle];
    
    _eventDateFormat = [[NSDateFormatter alloc] init];
    [_eventDateFormat setDateStyle:NSDateFormatterNoStyle];
    [_eventDateFormat setTimeStyle:NSDateFormatterShortStyle];
    
    [UTIL showActivity:NSLocalizedStringFromTable(@"", [UTIL getLanguage], @"")];
    [self performSelector:@selector(getNonBillableCategories) withObject:nil afterDelay:.1f];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextField *text = (UITextField *)[cell viewWithTag:1];
    
    [self setUpAccessoryView:text];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadTimesheet {
    _dayEventsArray = [[NSMutableArray alloc] init];
    
    // load my day for selected date
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    [API GetTimesheet:USER.sessionId day:[df stringFromDate:_currentDay] completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqual: @""]) {
            NSMutableArray *responseData = [result valueForKey:@"GetTimesheetResult"];
            
            if (![responseData isKindOfClass:[NSNull class]]) {
                for (id item in responseData) {
                    TimesheetEntry *entry = [[TimesheetEntry alloc] init];
                    [entry initWithData:item categories:self->_nonBillableCategories];
                    
                    if (entry.claim.claimIndx > 0) {
                        [entry.claim load:^(bool result) {
                            entry.phase = [[Phase alloc] init];
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"phaseIndx == %d", entry.phaseIndx];
                            NSMutableArray *filtered = [[NSMutableArray alloc] initWithArray:entry.claim.phaseList];
                            [filtered filterUsingPredicate:predicate];
                            
                            if (filtered.count > 0) {
                                entry.phase = [filtered objectAtIndex:0];
                            }
                            [self->_dayEventsArray addObject:entry];
                            [self rebuildDayItems];
                        }];
                    } else {
                        [self->_dayEventsArray addObject:entry];
                    }
                }
                
                [self rebuildDayItems];
            }
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
        }
    }];
}

- (void)getNonBillableCategories {
    _nonBillableCategories = [[NSMutableArray alloc] init];
    
    [API getNonBillableCategories:USER.sessionId completion:^(NSMutableArray *result) {
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqual: @""]) {
            NSMutableArray *responseData = [result valueForKey:@"GetNonBillableCategoriesResult"];
            
            if (![responseData isKindOfClass:[NSNull class]]) {
                for (id item in responseData) {
                    GenericObject *category = [[GenericObject alloc] init];
                    [category initWithData:item];
                    [self->_nonBillableCategories addObject:category];
                }
            }
        } else {
            [ALERT alertWithTitle:@"Error" message:error];
        }
        
        [self->_eventsArray addObjectsFromArray:self->_nonBillableCategories];
        
        // claim
        GenericObject *item = [[GenericObject alloc] init];
        item.genericId = @"0";
        item.value = @"On Claim";
        
        if (self->_eventsArray.count > 0) {
            [self->_eventsArray insertObject:item atIndex:1];
        } else {
            self->_eventsArray = [NSMutableArray arrayWithObject:item];
        }
        
        [self performSelector:@selector(loadTimesheet) withObject:nil afterDelay:.1f];
    }];
}

- (void)setUpAccessoryView:(UITextField *)textField {
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    keyboardToolbar.tintColor = [UTIL darkBlueColor];
    
    UIBarButtonItem *flexibleSpacebutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dateSelected:)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(hideDatePicker:)];
    
    [keyboardToolbar setItems:[NSArray arrayWithObjects:cancelButton, flexibleSpacebutton, doneButton, nil] animated:NO];
    textField.inputAccessoryView = keyboardToolbar;
}

- (void)hideDatePicker:(id)sender {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextField *text = (UITextField *)[cell viewWithTag:1];
    [text resignFirstResponder];
}

- (void)dateSelected:(id)sender {
    _currentDay = _dayDatePicker.date;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextField *text = (UITextField *)[cell viewWithTag:1];
    
    NSComparisonResult result = [[NSCalendar currentCalendar] compareDate:_currentDay toDate:[NSDate date] toUnitGranularity:NSCalendarUnitDay];
    switch (result) {
        case NSOrderedAscending:
        case NSOrderedDescending:
            [text setText:[_dateFormat stringFromDate:_currentDay]];
            break;
        default:
            [text setText:@"Today"];
            break;
    }
    
    [text resignFirstResponder];
    
    [UTIL showActivity:NSLocalizedStringFromTable(@"", [UTIL getLanguage], @"")];
    [self performSelector:@selector(loadTimesheet) withObject:nil afterDelay:.1f];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = CGFLOAT_MIN;
    if (section == 1) {
        height = 32.0f;
    }
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat height = CGFLOAT_MIN;
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title;
    
    switch (section) {
        case 1:
            if (_dayEventsArray.count == 0) {
                title = @"";
            } else {
                title = @"Events";
            }
            break;
        default:
            title = @"";
            break;
    }
    
    return title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 1;
    
    switch (section) {
        case 1:
            numberOfRows = _dayEventsArray.count;
            break;
        case 2:
        case 3:
            if (_dayEventsArray.count == 0) {
                numberOfRows = 0;
            }
            break;
        default:
            break;
    }
    
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat heightForRow = tableView.rowHeight;
    if ([indexPath section] == 1) {
        heightForRow = 54;
    }
    
    return heightForRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    UITableViewCell *cell2;
    TimesheetEntry *item;
    UILabel *lbl;
    
    switch ([indexPath section]) {
        case 0:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"daySelector" forIndexPath:indexPath];
            UITextField *text = (UITextField *)[cell viewWithTag:1];
            
            NSComparisonResult result = [[NSCalendar currentCalendar] compareDate:_currentDay toDate:[NSDate date] toUnitGranularity:NSCalendarUnitDay];
            switch (result) {
                case NSOrderedAscending:
                case NSOrderedDescending:
                    [text setText:[_dateFormat stringFromDate:_currentDay]];
                    break;
                default:
                    [text setText:@"Today"];
                    break;
            }
            
            [text setTextAlignment:NSTextAlignmentCenter];
            [text setInputView:_dayDatePicker];
        }
            break;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"entry" forIndexPath:indexPath];
            cell2 = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"entry"];
            item = [_dayEventsArray objectAtIndex:[indexPath row]];
            lbl = [cell viewWithTag:1];
            if (item.claim.claimIndx != 0) {
                [lbl setText:item.claim.claimNumber];
                lbl = [cell viewWithTag:2];
                [lbl setText:item.phase.phaseCode];
            } else {
                [lbl setText:item.item.value];
                lbl = [cell viewWithTag:2];
                if ([item.item.genericId isEqual:@"2"]) {
                    [lbl setText:item.notes];
                } else {
                    if ([item.details isEqual:@""]) {
                        item.details = @"Day";
                    }
                    [lbl setText:item.details];
                }
            }
            
            [lbl setTextColor:[[cell2 detailTextLabel] textColor]];
            
            lbl = [cell viewWithTag:3];
            if (item.dateTimeFrom == item.dateTimeTo) {
                [lbl setText:[_eventDateFormat stringFromDate:item.dateTimeFrom]];
            } else {
                [lbl setText:[NSString stringWithFormat:@"%@ - %@", [_eventDateFormat stringFromDate:item.dateTimeFrom], [_eventDateFormat stringFromDate:item.dateTimeTo]]];
            }
            [lbl setTextColor:[[cell2 detailTextLabel] textColor]];
            break;
        default:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            [cell.textLabel setText:@"Summary"];
            [cell.detailTextLabel setText:[NSString stringWithFormat:@"%.1f hours", _summaryHours]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            break;
    }
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if ([indexPath section] == 1) {
        TimesheetEntry *item = [_dayEventsArray objectAtIndex:[indexPath row]];
        if ([item.item.genericId isEqual:@"1"]) {
            return NO;
        } else {
            return YES;
        }
    } else {
        return NO;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        TimesheetEntry *te = [_dayEventsArray objectAtIndex:[indexPath row]];
        
        [UTIL showActivity:@""];
        [self deleteEntry:te];
        
        [_dayEventsArray removeObjectAtIndex:[indexPath row]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)deleteEntry:(TimesheetEntry *)item {
    [API deleteTimeSheetEntry:USER.sessionId entryId:item.entryId completion:^(NSMutableArray *result) {
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqualToString: @""]) {
            NSMutableArray *responseData = [result valueForKey:@"deleteTimeSheetEntryResult"];
            
            if ([[responseData valueForKey:@"Message"] isEqual:@""] || [[responseData valueForKey:@"Message"] isKindOfClass:[NSNull class]]) {
                [UTIL hideActivity];
            } else {
                [UTIL hideActivity];
                [ALERT alertWithTitle:@"Error" message:[responseData valueForKey:@"Message"]];
            }
        } else {
            [UTIL hideActivity];
            [ALERT alertWithTitle:@"Error" message:error];
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        _selectedEntry = [_dayEventsArray objectAtIndex:[indexPath row]];
        
        //[self openTimeSource];
        [self performSegueWithIdentifier:@"showDetails" sender:self];
    }
}

- (NSDate *)minDate {
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    // Extract date components into components1
    NSDateComponents *components1 = [gregorianCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:_currentDay];
    
    // Combine date and time into components3
    NSDateComponents *components3 = [[NSDateComponents alloc] init];
    
    [components3 setYear:components1.year];
    [components3 setMonth:components1.month];
    [components3 setDay:components1.day];
    
    [components3 setHour:0];
    [components3 setMinute:0];
    [components3 setSecond:0];
    
    // Generate a new NSDate from components3.
    return [self roundDate:[gregorianCalendar dateFromComponents:components3]];
}

- (NSDate *)maxDate {
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    // Extract date components into components1
    NSDateComponents *components1 = [gregorianCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    
    // Extract time components into components2
    NSDateComponents *components2 = [gregorianCalendar components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[NSDate date]];
    
    // Combine date and time into components3
    NSDateComponents *components3 = [[NSDateComponents alloc] init];
    
    [components3 setYear:components1.year];
    [components3 setMonth:components1.month];
    [components3 setDay:components1.day];
    
    [components3 setHour:components2.hour];
    [components3 setMinute:components2.minute];
    [components3 setSecond:components2.second];
    
    // Generate a new NSDate from components3.
    return [self roundDate:[gregorianCalendar dateFromComponents:components3]];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _eventsArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    GenericObject *category = [_eventsArray objectAtIndex:row];
    
    return category.value;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (![self checkIfNeedClockIn] && row == 0) {
        [pickerView selectRow:1 inComponent:component animated:YES];
    } else {
        _selectedEvent = [_eventsArray objectAtIndex:row];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showDetails"]) {
        TimeEntryDetailsViewController *child = (TimeEntryDetailsViewController *)[segue destinationViewController];
        [child setItem:_selectedEntry];
        [child setCurrentEvents:_dayEventsArray];
        
        if (_dayEventsArray.count == 0 || _selectedEntry == [_dayEventsArray firstObject]) { // == 1 means we have clocked in
            [child setMinDate:[self minDate]];
        } else {
            TimesheetEntry *te = [_dayEventsArray firstObject];
            if ([_selectedEntry.item.genericId intValue] == 1) { // if second time clocked in during the day
                te = [_dayEventsArray lastObject];
            }
            
            [child setMinDate:te.dateTimeTo];
        }
        
        [child setMaxDate:[self maxDate]];
    }
}

- (bool)checkIfNeedClockIn {
    bool response = false;
    
    TimesheetEntry *lastEvent = [_dayEventsArray lastObject];
    if ([lastEvent.item.genericId isEqual:@"2"]) {
        response = true;
    }
    
    return response;
}

- (NSDate *)roundDate:(NSDate *)dt {
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    // Extract date components into components1
    NSDateComponents *components1 = [gregorianCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:dt];
    
    // Extract time components into components2
    NSDateComponents *components2 = [gregorianCalendar components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:dt];
    
    // Combine date and time into components3
    NSDateComponents *components3 = [[NSDateComponents alloc] init];
    
    [components3 setYear:components1.year];
    [components3 setMonth:components1.month];
    [components3 setDay:components1.day];
    
    NSInteger minutes = components2.minute;
    float minuteUnit = ceil((float) minutes / 15.0);
    minutes = (minuteUnit - 1) * 15.0;
    
    [components3 setHour:components2.hour];
    [components3 setMinute:minutes];
    
    return [gregorianCalendar dateFromComponents:components3];
}

- (void)addTimesheetEntry:(GenericObject *)item details:(NSString *)details {
    _selectedEntry = [[TimesheetEntry alloc] init];
    _selectedEntry.item = item;
    _selectedEntry.details = details;
    _selectedEntry.dateTimeFrom = [self roundDate:_currentDay];
    _selectedEntry.dateTimeTo = [self roundDate:_currentDay];
    if ([item.genericId intValue] > 0) {
        _selectedEntry.details = @"Non Billable";
    }
    
    [self performSegueWithIdentifier:@"showDetails" sender:self];
}

- (void)updateTimeline:(NSNotification *)notification {
    TimesheetEntry *entry = (TimesheetEntry *)notification.object;
    
    [UTIL showActivity:NSLocalizedStringFromTable(@"saving", [UTIL getLanguage], @"")];
    [self performSelector:@selector(doSave:) withObject:entry afterDelay:.1f];
}

- (IBAction)addPressed:(id)sender {
    if (_dayEventsArray.count == 0) {
        [self addTimesheetEntry:[_eventsArray objectAtIndex:0] details:@"Day"];
    } else {
        if ([self checkIfNeedClockIn]) {
            [self addTimesheetEntry:[_eventsArray objectAtIndex:0] details:@"Prev. Clock Out"];
        } else {
            _selectedEvent = [_eventsArray objectAtIndex:1];
            [_eventPickerView selectRow:1 inComponent:0 animated:YES];
            [_eventsSource becomeFirstResponder];
        }
    }
}

- (void)hidePicker:(id)sender {
    [_eventsSource resignFirstResponder];
}

- (void)donePicker:(id)sender {
    [_eventsSource resignFirstResponder];
    
    [self addTimesheetEntry:_selectedEvent details:@""];
}

- (void)rebuildDayItems {
    // sort events
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateTimeFrom" ascending:YES];
    _dayEventsArray = [NSMutableArray arrayWithArray:[_dayEventsArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
    
    // update summary
    [self updateSummary];
    
    [self.tableView reloadData];
}

- (void)updateSummary {
    //TimesheetEntry *teStart = [_dayEventsArray firstObject];
    //TimesheetEntry *teEnd = [_dayEventsArray lastObject];
    
    //NSTimeInterval distanceBetweenDates = [teEnd.dateTimeTo timeIntervalSinceDate:teStart.dateTimeFrom];
    double secondsInAnHour = 3600;
    _summaryHours = 0;
    
    // working hours
    int index = 0;
    NSTimeInterval differenceBetweenDates = 0;
    for (TimesheetEntry *item in _dayEventsArray) {
        differenceBetweenDates = [item.dateTimeTo timeIntervalSinceDate:item.dateTimeFrom];
        _summaryHours += differenceBetweenDates / secondsInAnHour;
        index++;
    }
    /*
    // get non working hours during the day
    index = 0;
    distanceBetweenDates = 0;
    for (TimesheetEntry *item in _dayEventsArray) {
        if ([item.item.genericId isEqual:@"0"] && index != 0) {
            TimesheetEntry *clockedOutBefore = [_dayEventsArray objectAtIndex:(index - 1)];
            
            distanceBetweenDates = [item.dateTimeTo timeIntervalSinceDate:clockedOutBefore.dateTimeFrom];
        }
        index++;
    }
    
    _summaryHours -= distanceBetweenDates / secondsInAnHour;*/
}

- (void)doSave:(TimesheetEntry *)item {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    
    NSDateFormatter *dfd = [[NSDateFormatter alloc] init];
    [dfd setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    [API saveTimeSheet:USER.sessionId entryId:item.entryId categoryId:[item.item.genericId intValue] regionId:USER.regionId branchId:[USER.branch.genericId intValue] claimIndx:item.claim.claimIndx phaseIndx:item.phase.phaseIndx projectName:item.claim.claimNumber costCategoryId:@"" employeeId:USER.userId dateStart:[dfd stringFromDate:item.dateTimeFrom] dateStop:[dfd stringFromDate:item.dateTimeTo] hours:([item.dateTimeTo timeIntervalSinceDate:item.dateTimeFrom]/3600) note:item.notes latitude:LOCATION.lastSavedLocation.coordinate.latitude longitude:LOCATION.lastSavedLocation.coordinate.longitude isMobile:1 enteredById:USER.userId modifiedById:USER.userId completion:^(NSMutableArray *result) {
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqualToString: @""]) {
            NSMutableArray *responseData = [result valueForKey:@"saveTimeSheetEntryResult"];
            
            if ([[responseData valueForKey:@"Message"] isEqual:@""] || [[responseData valueForKey:@"Message"] isKindOfClass:[NSNull class]]) {
                [self performSelector:@selector(loadTimesheet) withObject:nil afterDelay:.1f];
                [self rebuildDayItems];
            } else {
                [UTIL hideActivity];
                [ALERT alertWithTitle:@"Error" message:[responseData valueForKey:@"Message"]];
            }
        } else {
            [UTIL hideActivity];
            [ALERT alertWithTitle:@"Error" message:error];
        }
    }];
}

@end
