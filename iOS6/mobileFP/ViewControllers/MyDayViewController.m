//
//  MyDayViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2018-05-30.
//  Copyright © 2018 FirstOnSite. All rights reserved.
//

#import "MyDayViewController.h"

@interface MyDayViewController ()

@end

@implementation MyDayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dayEventAdded:) name:@"dayEventAdded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dayEventUpdated:) name:@"dayEventUpdated" object:nil];
    
    [self setTitle:NSLocalizedStringFromTable(@"my_day", [UTIL getLanguage], @"")];
    
    _events = [[NSMutableArray alloc] init];
    _calendar = [NSCalendar currentCalendar];
    
    _dateFormat = [[NSDateFormatter alloc] init];
    [_dateFormat setDateStyle:NSDateFormatterFullStyle];
    [_dateFormat setTimeStyle:NSDateFormatterNoStyle];
    
    _currentDay = [NSDate date];
    _dayDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [_dayDatePicker setDatePickerMode:UIDatePickerModeDate];
    [_dayDatePicker setMaximumDate:_currentDay];
    
    _keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    _keyboardToolbar.tintColor = [UTIL darkBlueColor];
    
    UIBarButtonItem *flexibleSpacebutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dateSelected:)];
    UIBarButtonItem *todayButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"today", [UTIL getLanguage], @"") style:UIBarButtonItemStyleDone target:self action:@selector(todayPressed:)];
    
    [_keyboardToolbar setItems:[NSArray arrayWithObjects:todayButton, flexibleSpacebutton, doneButton, nil] animated:NO];
    
    _currentDateField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 56.0f)];
    [_currentDateField setTag:1];
    [_currentDateField setTextAlignment:NSTextAlignmentCenter];
    [_currentDateField setInputAccessoryView:_keyboardToolbar];
    [_currentDateField setInputView:_dayDatePicker];
    [_currentDateField setText:NSLocalizedStringFromTable(@"today", [UTIL getLanguage], @"")];
    [_currentDateField setTintColor:[UIColor clearColor]];
    
    _fullHeight = 53.0f;
    _width = [UIScreen mainScreen].bounds.size.width - 74.0;
    
    [UTIL showActivity:NSLocalizedStringFromTable(@"", [UTIL getLanguage], @"")];
    [self performSelector:@selector(getNonBillableCategories) withObject:nil afterDelay:.1f];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // scroll close to current hour and draw red line for current hour
    [self scrollToCurrentHour];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollToCurrentHour {
    NSInteger currentHour = [_calendar component:NSCalendarUnitHour fromDate:[NSDate date]];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentHour inSection:0];
    // scroll to current hour
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectZero];
    [headerView setBackgroundColor:[UIColor colorWithRed:249.0f/255 green:249.0f/255 blue:249.0f/255 alpha:1]];
    [headerView addSubview:_currentDateField];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 56)];
    [path addLineToPoint:CGPointMake([UIScreen mainScreen].bounds.size.width, 56)];
    shapeLayer.path = path.CGPath;
    shapeLayer.strokeColor = [UIColor colorWithRed:178.0f/255 green:178.0f/255 blue:178.0f/255 alpha:1].CGColor;
    [headerView.layer addSublayer:shapeLayer];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 56.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 24;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"time" forIndexPath:indexPath];
    
    // prepare cell
    NSInteger x = indexPath.row;
    NSString *ampm = @" AM";
    if (x > 11) {
        x -= 12;
        ampm = @" PM";
    }
    
    // convert 0 to 12
    if (x == 0) {
        x = 12;
    }
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1];
    [label setText:[NSString stringWithFormat:@"%ld %@", (long)x, ampm]];
    
    UIView *separator = [cell.contentView viewWithTag:2];
    [separator setBackgroundColor:self.tableView.separatorColor];
    
    for (UIView *old in cell.contentView.subviews) {
        if (old.tag != 1 && old.tag != 2) {
            [old removeFromSuperview];
        }
    }
    
    NSMutableArray *entries = [self getEventsForCell:indexPath.row];
    for (TimesheetEntry *entry in entries) {
        if (entry != nil) {
            // get coordinates
            NSInteger eventStartHour = [_calendar component:NSCalendarUnitHour fromDate:entry.dateTimeFrom];
            NSInteger eventEndHour = [_calendar component:NSCalendarUnitHour fromDate:entry.dateTimeTo];
            NSInteger eventStartMinute = [_calendar component:NSCalendarUnitMinute fromDate:entry.dateTimeFrom];
            NSInteger eventEndMinute = [_calendar component:NSCalendarUnitMinute fromDate:entry.dateTimeTo];
            
            CGFloat y = 2.0;
            CGFloat height = 0;
            if (eventStartHour == indexPath.row) {
                y = _fullHeight * eventStartMinute/60 + 2.0;
                if (eventStartHour == eventEndHour) {
                    height = _fullHeight * (eventEndMinute - eventStartMinute)/60;
                } else {
                    height = _fullHeight;
                }
            } else {
                y = 2.0;
                if (eventEndHour > indexPath.row) {
                    height = _fullHeight;
                } else {
                    height = _fullHeight * eventEndMinute/60;
                }
            }
            
            if (height > 0) {
                UIViewEvent *eventView = [[UIViewEvent alloc] initWithFrame:CGRectMake(56.0, y, _width, height)];
                [eventView setTag:(10 * (indexPath.row + 1))];
                [eventView setEntry:entry];
                
                UITapGestureRecognizer *eventSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEventTap:)];
                [eventView addGestureRecognizer:eventSingleTap];
                
                if (entry.claim.claimIndx > 0) {
                    [eventView setBackgroundColor:[UTIL EventColor2]];
                } else {
                    [eventView setBackgroundColor:[UTIL EventColor1]];
                }
                
                UIBezierPath *path = [UIBezierPath bezierPath];
                [path moveToPoint:CGPointMake(0, 0)];
                [path addLineToPoint:CGPointMake(0, height)];
                CAShapeLayer *shapeLayer = [CAShapeLayer layer];
                shapeLayer.path = [path CGPath];
                if (entry.claim.claimIndx > 0) {
                    shapeLayer.strokeColor = [[UTIL EventLineColor2] CGColor];
                } else {
                    shapeLayer.strokeColor = [[UTIL EventLineColor1] CGColor];
                }
                shapeLayer.lineWidth = 2.0;
                
                [eventView.layer addSublayer:shapeLayer];
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(4.0, 0.0, _width - 8.0, height - 2.0)];
                [label setText:[NSString stringWithFormat:@"%@ (%@ - %@)\n%@", entry.item.value, [UTIL formatDateOnly:entry.dateTimeFrom format:@"h:mm a"], [UTIL formatDateOnly:entry.dateTimeTo format:@"h:mm a"], entry.notes]];
                [label setNumberOfLines:-1];
                if (entry.claim.claimIndx > 0) {
                    [label setTextColor:[UTIL EventLineColor2]];
                } else {
                    [label setTextColor:[UTIL EventLineColor1]];
                }
                [label setFont:[UIFont systemFontOfSize:11]];
                
                [eventView addSubview:label];
                [cell.contentView addSubview:eventView];
            }
        }
    }
    
    return cell;
}

- (void)handleEventTap:(UITapGestureRecognizer *)recognizer {
    UIViewEvent *tapped = (UIViewEvent *)recognizer.view;
    _selectedEvent = tapped.entry;
    
    [self performSegueWithIdentifier:@"showEvent" sender:self];
}

- (NSMutableArray *)getEventsForCell:(NSInteger)row {
    NSMutableArray *response = [[NSMutableArray alloc] init];
    
    for (TimesheetEntry *entry in _events) {
        NSInteger eventStartHour = [_calendar component:NSCalendarUnitHour fromDate:entry.dateTimeFrom];
        NSInteger eventEndHour = [_calendar component:NSCalendarUnitHour fromDate:entry.dateTimeTo];
        
        if (eventStartHour <= row && eventEndHour >= row) {
            [response addObject:entry];
        }
    }
    
    return response;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showEvent"]) {
        MyDayEventViewController *child = (MyDayEventViewController *)[segue destinationViewController];
        [child setCurrentDay:_currentDay];
        [child setSelectedEvent:_selectedEvent];
        [child setNonBillableCategories:_nonBillableCategories];
    }
}

- (void)dateSelected:(id)sender {
    _currentDay = _dayDatePicker.date;
    
    NSComparisonResult result = [[NSCalendar currentCalendar] compareDate:_currentDay toDate:[NSDate date] toUnitGranularity:NSCalendarUnitDay];
    switch (result) {
        case NSOrderedAscending:
        case NSOrderedDescending:
            [_currentDateField setText:[_dateFormat stringFromDate:_currentDay]];
            break;
        default:
            [_currentDateField setText:NSLocalizedStringFromTable(@"today", [UTIL getLanguage], @"")];
            break;
    }
    
    [_currentDateField resignFirstResponder];
    
    [UTIL showActivity:NSLocalizedStringFromTable(@"", [UTIL getLanguage], @"")];
    [self performSelector:@selector(loadTimesheet) withObject:nil afterDelay:.1f];
}

- (void)todayPressed:(id)sender {
    _currentDay = [NSDate date];
    [_dayDatePicker setDate:_currentDay];
    
    [_currentDateField setText:NSLocalizedStringFromTable(@"today", [UTIL getLanguage], @"")];
    [_currentDateField resignFirstResponder];
    
    [UTIL showActivity:NSLocalizedStringFromTable(@"", [UTIL getLanguage], @"")];
    [self performSelector:@selector(loadTimesheet) withObject:nil afterDelay:.1f];
}

- (void)getNonBillableCategories {
    _nonBillableCategories = [[NSMutableArray alloc] init];
    
    [API getNonBillableCategories:USER.sessionId completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
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
        [self performSelector:@selector(loadTimesheet) withObject:nil afterDelay:.1f];
    }];
}

- (void)loadTimesheet {
    _events = [[NSMutableArray alloc] init];
    
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
                            [self->_events addObject:entry];
                            [self.tableView reloadData];
                        }];
                    } else {
                        [self->_events addObject:entry];
                    }
                }
                
                [self.tableView reloadData];
            }
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
        }
    }];
}

- (IBAction)addPressed:(id)sender {
    _selectedEvent = [[TimesheetEntry alloc] init];
    _selectedEvent.item.genericId = @"0";
    _selectedEvent.item.value = @"On Claim";
    _selectedEvent.dateTimeFrom = _currentDay;
    _selectedEvent.dateTimeTo = _currentDay;
    _selectedEvent.entryId = 0;
    
    [self performSegueWithIdentifier:@"showEvent" sender:self];
}

- (void)dayEventAdded:(NSNotification *)notification {
    TimesheetEntry *entry = (TimesheetEntry *)notification.object;
    
    [UTIL showActivity:NSLocalizedStringFromTable(@"saving", [UTIL getLanguage], @"")];
    [self performSelector:@selector(doSave:) withObject:entry afterDelay:.1f];
}

- (void)dayEventUpdated:(NSNotification *)notification {
    TimesheetEntry *entry = (TimesheetEntry *)notification.object;
    
    [UTIL showActivity:NSLocalizedStringFromTable(@"saving", [UTIL getLanguage], @"")];
    [self performSelector:@selector(doSave:) withObject:entry afterDelay:.1f];
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
