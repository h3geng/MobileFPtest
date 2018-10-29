//
//  MyDayEventViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2018-05-30.
//  Copyright © 2018 FirstOnSite. All rights reserved.
//

#import "MyDayEventViewController.h"

@interface MyDayEventViewController ()

@end

@implementation MyDayEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventClaimSelected:) name:@"eventClaimSelected" object:nil];
    
    [self setTitle:NSLocalizedStringFromTable(@"event", [UTIL getLanguage], @"")];
    
    _dateFormat = [[NSDateFormatter alloc] init];
    [_dateFormat setDateStyle:NSDateFormatterFullStyle];
    [_dateFormat setTimeStyle:NSDateFormatterNoStyle];
    
    NSComparisonResult result = [[NSCalendar currentCalendar] compareDate:_currentDay toDate:[NSDate date] toUnitGranularity:NSCalendarUnitDay];
    switch (result) {
        case NSOrderedAscending:
        case NSOrderedDescending:
            _currentDateField = [_dateFormat stringFromDate:_currentDay];
            break;
        default:
            _currentDateField = NSLocalizedStringFromTable(@"today", [UTIL getLanguage], @"");
            break;
    }
    
    if (self->_nonBillableCategories.count > 0) {
        [self->_nonBillableCategories insertObject:self->_selectedEvent.item atIndex:1];
    } else {
        self->_nonBillableCategories = [NSMutableArray arrayWithObject:self->_selectedEvent.item];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 1;
    
    switch (section) {
        case 0:
            numberOfRows = 2;
            break;
        case 1:
            numberOfRows = 4;
            if ([_selectedEvent.item.genericId isEqual:@"0"]) {
                numberOfRows = 7;
            }
            break;
        case 2:
            numberOfRows = 1;
            break;
    }
    
    return numberOfRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *titleForHeader = @"";
    
    switch (section) {
        case 0:
            titleForHeader = NSLocalizedStringFromTable(@"event", [UTIL getLanguage], @"");
            break;
        case 1:
            titleForHeader = _currentDateField;
            break;
        default:
            titleForHeader = NSLocalizedStringFromTable(@"notes", [UTIL getLanguage], @"");
            break;
    }
    
    return titleForHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat heightForRow = UITableViewAutomaticDimension;
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 1:
                    heightForRow = _typeVisible ? 180.0f : 0.0f;
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 1:
                    heightForRow = _startTimeVisible ? 180.0f : 0.0f;
                    break;
                case 3:
                    heightForRow = _endTimeVisible ? 180.0f : 0.0f;
                    break;
                case 6:
                    heightForRow = _phaseVisible ? 180.0f : 0.0f;
                    break;
            }
            break;
        case 2:
            heightForRow = 160.0;
            break;
    }
    
    return heightForRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"type", [UTIL getLanguage], @"")];
                    [cell.detailTextLabel setText:_selectedEvent.item.value];
                    break;
                default:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"typePicker"];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    _pickerType = (UIPickerView *)[cell.contentView viewWithTag:1];
                    [_pickerType setDelegate:self];
                    [_pickerType setDataSource:self];
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"start", [UTIL getLanguage], @"")];
                    [cell.detailTextLabel setText:[UTIL formatDateOnly:_selectedEvent.dateTimeFrom format:@"h:mm a"]];
                    break;
                case 1:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"startTimePicker"];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    _pickerStartTime = (UIDatePicker *)[cell.contentView viewWithTag:1];
                    [_pickerStartTime addTarget:self action:@selector(startTimeChanged:) forControlEvents:UIControlEventValueChanged];
                    [_pickerStartTime setDate:_selectedEvent.dateTimeFrom];
                    break;
                case 2:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"end", [UTIL getLanguage], @"")];
                    [cell.detailTextLabel setText:[UTIL formatDateOnly:_selectedEvent.dateTimeTo format:@"h:mm a"]];
                    break;
                case 3:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"endTimePicker"];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    _pickerEndTime = (UIDatePicker *)[cell.contentView viewWithTag:1];
                    [_pickerEndTime addTarget:self action:@selector(endTimeChanged:) forControlEvents:UIControlEventValueChanged];
                    [_pickerEndTime setDate:_selectedEvent.dateTimeTo];
                    break;
                case 4:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"claim", [UTIL getLanguage], @"")];
                    [cell.detailTextLabel setText:_selectedEvent.claim.claimNumber];
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    break;
                case 5:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"phase", [UTIL getLanguage], @"")];
                    [cell.detailTextLabel setText:_selectedEvent.phase.phaseCode];
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    break;
                case 6:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"typePicker"];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    _pickerPhase = (UIPickerView *)[cell.contentView viewWithTag:1];
                    [_pickerPhase setDelegate:self];
                    [_pickerPhase setDataSource:self];
                    break;
            }
            break;
        default:
        {
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(12, 2, [UIScreen mainScreen].bounds.size.width - 24, 156.0)];
            [textView setText:_selectedEvent.notes];
            [textView setDelegate:self];
            
            [cell.contentView addSubview:textView];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
            break;
    }
    
    return cell;
}

- (void)textViewDidChange:(UITextView *)textView {
    _selectedEvent.notes = textView.text;
}

- (void)startTimeChanged:(id)sender{
    _selectedEvent.dateTimeFrom = _pickerStartTime.date;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)endTimeChanged:(id)sender{
    _selectedEvent.dateTimeTo = _pickerEndTime.date;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger numberOfRows = 0;
    
    if (pickerView == _pickerType) {
        numberOfRows = _nonBillableCategories.count;
    } else {
        numberOfRows = _selectedEvent.claim.phaseList.count;
    }
    
    return numberOfRows;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *returnValue = @"";
    
    if (pickerView == _pickerType) {
        GenericObject *category = [_nonBillableCategories objectAtIndex:row];
        returnValue = category.value;
    } else {
        Phase *ph = (Phase *)[_selectedEvent.claim.phaseList objectAtIndex:row];
        returnValue = ph.phaseCode;
    }
    
    return returnValue;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == _pickerType) {
        _selectedEvent.item = [_nonBillableCategories objectAtIndex:row];
    } else {
        _selectedEvent.phase = [_selectedEvent.claim.phaseList objectAtIndex:row];
    }
    
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                _typeVisible = !_typeVisible;
                _pickerType.hidden = !_typeVisible;
                
                if (_typeVisible) {
                    _startTimeVisible = false;
                    _pickerStartTime.hidden = !_startTimeVisible;
                    _endTimeVisible = false;
                    _pickerEndTime.hidden = !_endTimeVisible;
                    _phaseVisible = false;
                    _pickerPhase.hidden = !_phaseVisible;
                }
                
                [UIView animateWithDuration:0.2 animations:^{
                    [self.tableView beginUpdates];
                    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                    [self.tableView endUpdates];
                }];
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                case 2:
                    [self toggleDatePickerCell:indexPath];
                    break;
                case 4:
                    [self performSegueWithIdentifier:@"showClaims" sender:self];
                    break;
                case 5: //phase
                    if (_selectedEvent.claim.claimIndx > 0) {
                        _phaseVisible = !_phaseVisible;
                        _pickerPhase.hidden = !_phaseVisible;
                        
                        if (_phaseVisible) {
                            _typeVisible = false;
                            _pickerType.hidden = !_typeVisible;
                            _startTimeVisible = false;
                            _pickerStartTime.hidden = !_startTimeVisible;
                            _endTimeVisible = false;
                            _pickerEndTime.hidden = !_endTimeVisible;
                        }
                        
                        [UIView animateWithDuration:0.2 animations:^{
                            [self.tableView beginUpdates];
                            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                            [self.tableView endUpdates];
                        }];
                    }
                    break;
            }
            break;
    }
}

- (void)toggleDatePickerCell:(NSIndexPath *)indexPath {
    if ([indexPath row] == 0) {
        _startTimeVisible = !_startTimeVisible;
        _pickerStartTime.hidden = !_startTimeVisible;
        
        if (_startTimeVisible) {
            _endTimeVisible = !_startTimeVisible;
            _pickerEndTime.hidden = !_endTimeVisible;
            
            _typeVisible = false;
            _pickerType.hidden = !_typeVisible;
            
            _phaseVisible = false;
            _pickerPhase.hidden = !_phaseVisible;
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            [self.tableView beginUpdates];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self.tableView endUpdates];
        }];
    }
    
    if ([indexPath row] == 2) {
        _endTimeVisible = !_endTimeVisible;
        _pickerEndTime.hidden = !_endTimeVisible;
        
        if (_endTimeVisible) {
            _startTimeVisible = !_endTimeVisible;
            _pickerStartTime.hidden = !_startTimeVisible;
            
            _typeVisible = false;
            _pickerType.hidden = !_typeVisible;
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            [self.tableView beginUpdates];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self.tableView endUpdates];
        }];
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)eventClaimSelected:(NSNotification *)notification {
    id data = [[notification userInfo] valueForKey:@"data"];
    if ([data isKindOfClass:[Claim class]]) {
        _selectedEvent.claim = data;
        _selectedEvent.phase = [[Phase alloc] init];
        
        [self.tableView reloadData];
    }
}

- (IBAction)savePressed:(id)sender {
    // validation
    if ([_selectedEvent.dateTimeFrom compare:_selectedEvent.dateTimeTo] == NSOrderedDescending) {
        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"from_cannot_be_later", [UTIL getLanguage], @"")];
    } else {
        if ([_selectedEvent.item.genericId isEqual:@"0"]) {
            if (_selectedEvent.claim.claimIndx == 0) { // claim not selected
                [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"claim_not_selected", [UTIL getLanguage], @"")];
            } else {
                if (_selectedEvent.phase.phaseIndx == 0) { // phase note selected
                    [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"phase_not_selected", [UTIL getLanguage], @"")];
                } else {
                    [self save];
                }
            }
        } else {
            [self save];
        }
    }
}

- (void)save {
    if (_selectedEvent.entryId == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dayEventAdded" object:_selectedEvent];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dayEventUpdated" object:_selectedEvent];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
