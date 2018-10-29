//
//  TimeEntryDetailsViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2016-03-24.
//  Copyright © 2016 FirstOnSite. All rights reserved.
//

#import "TimeEntryDetailsViewController.h"

@interface TimeEntryDetailsViewController ()

@end

@implementation TimeEntryDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_navItem setTitle:_item.item.value];
    
    _claims = [[NSMutableArray alloc] init];
    
    _phasePickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    [_phasePickerView setDataSource: self];
    [_phasePickerView setDelegate: self];
    _phasePickerView.showsSelectionIndicator = YES;
    
    _phaseSource = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_phaseSource];
    [_phaseSource setInputView:_phasePickerView];
    
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(hidePicker:)];
    UIBarButtonItem *flexibleSpacebutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePicker:)];
    
    pickerToolbar.tintColor = [UTIL darkBlueColor];
    [pickerToolbar setItems:[NSArray arrayWithObjects:cancelButton, flexibleSpacebutton, doneButton, nil] animated:YES];
    _phaseSource.inputAccessoryView = pickerToolbar;
    
    _selectedClaim = _item.claim;
    _selectedPhase = _item.phase;
    
    _sectionCount = 2;
    if ([_item.item.genericId intValue] == 2) { // clock out
        _sectionCount = 2;
    }
    if ([_item.item.genericId intValue] == 1) { // clock in
        _sectionCount = 1;
    }
    if ([_item.item.genericId intValue] == 0) { // claim
        _sectionCount = 4;
        
        if (_selectedClaim.claimIndx > 0) {
            _claims = [[NSMutableArray alloc] init];
            [_claims addObject:_selectedClaim];
        } else {
            [self searchClosest];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // Remove notification for keyboard change events
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    _mainTableView.contentInset = contentInsets;
    _mainTableView.scrollIndicatorInsets = contentInsets;
    
    _mainTableView.contentInset = contentInsets;
    _mainTableView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _mainTableView.contentInset = contentInsets;
    _mainTableView.scrollIndicatorInsets = contentInsets;
    
    _mainTableView.contentInset = contentInsets;
    _mainTableView.scrollIndicatorInsets = contentInsets;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hidePicker:(id)sender {
    [_phaseSource resignFirstResponder];
    [self keyboardWillHide:nil];
}

- (void)donePicker:(id)sender {
    [_phaseSource resignFirstResponder];
    [self keyboardWillHide:nil];
    //[self addTimesheetEntry:_selectedEvent details:@""];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat heightForHeader = 32.0f;
    if (section == 0 || section == 3) {
        heightForHeader = CGFLOAT_MIN;
    }
    
    return heightForHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"";
    
    switch (section) {
        case 1:
            title = @"Notes";
            break;
        case 2:
            title = @"Claims";
            break;
    }
    
    return title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat heightForRow = 44;
    
    switch ([indexPath section]) {
        case 0:
            heightForRow = 140;
            break;
        case 1:
            heightForRow = 100;
            break;
        case 3:
            heightForRow = 72;
            break;
    }
    
    return heightForRow;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 1;
    
    switch (section) {
        case 0:
            numberOfRows = 2;
            if ([_item.item.genericId isEqual:@"2"] || [_item.item.genericId isEqual:@"1"]) { // clock out, // clock in
                numberOfRows = 1;
            }
            break;
        case 3:
            numberOfRows = _claims.count;
            break;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    UIDatePicker *dtPicker;
    UISearchBar *searchBar;
    Claim *claim;
    UILabel *lbl;
    UITextView *notesText;
    
    switch ([indexPath section]) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"time" forIndexPath:indexPath];
            dtPicker = (UIDatePicker *)[cell viewWithTag:1];
            [dtPicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
            //[dtPicker setMinimumDate:_minDate];
            lbl = (UILabel *)[cell viewWithTag:6];
            
            if ([indexPath row] == 0) {
                // from
                [lbl setText:@"Start"];
                //[dtPicker setMaximumDate:_maxDate];
                [dtPicker setDate:_item.dateTimeFrom];
                _selectedMinDate = dtPicker.date;
                [dtPicker setTag:2];
            } else {
                // to
                [lbl setText:@"End"];
                //[dtPicker setMinimumDate:_selectedMinDate];
                //[dtPicker setMaximumDate:[NSDate date]];
                [dtPicker setDate:_item.dateTimeTo];
                [dtPicker setTag:4];
            }
            if ([_item.item.genericId isEqual:@"2"] || [_item.item.genericId isEqual:@"1"]) { // clock out, // clock in
                [lbl setText:@""];
            }
            break;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"notes" forIndexPath:indexPath];
            notesText = (UITextView *)[cell viewWithTag:1];
            [notesText setText:_item.notes];
            break;
        case 2:
            cell = [tableView dequeueReusableCellWithIdentifier:@"search" forIndexPath:indexPath];
            searchBar = (UISearchBar *)[cell viewWithTag:1];
            [searchBar setDelegate:self];
            break;
        default:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
            claim = [_claims objectAtIndex:[indexPath row]];
            
            NSArray* dateComponents = [[NSString stringWithFormat:@"%@", claim.dateJobOpen] componentsSeparatedByString: @" "];
            NSString* day = [dateComponents objectAtIndex: 0];
            
            [cell setTag:claim.claimIndx];
            [cell.textLabel setText:[NSString stringWithFormat:@"%@ (%@)",claim.claimNumber,day]];
            
            if (_selectedPhase.phaseIndx > 0) {
                [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@",_selectedPhase.phaseCode]];
            } else {
                [cell.detailTextLabel setNumberOfLines:-1];
                [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@\n%@",claim.projectName, claim.address.fullAddress]];
            }
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            
            break;
    }
    return cell;
}

- (void)dateChanged:(id)sender{
    UIDatePicker *picker = (UIDatePicker *)sender;
    if (picker.tag == 2) {
        UITableViewCell *cell = [_mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        UIDatePicker *pickerTo = (UIDatePicker *)[cell viewWithTag:4];
        
        [pickerTo setMinimumDate:picker.date];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 3) {
        _selectedClaim = [_claims objectAtIndex:[indexPath row]];
        [_selectedClaim load:^(bool result) {
            if (result) {
                self->_selectedPhase = [[Phase alloc] init];
                
                if (self->_selectedClaim.phaseList.count > 0) {
                    self->_selectedPhase = [self->_selectedClaim.phaseList objectAtIndex:0];
                    
                    self->_claims = [[NSMutableArray alloc] init];
                    [self->_claims addObject:self->_selectedClaim];
                    
                    //[_mainTableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
                    [self->_mainTableView reloadData];
                }
                
                [self->_phaseSource becomeFirstResponder];
                [self->_mainTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _selectedClaim.phaseList.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    Phase *ph = [_selectedClaim.phaseList objectAtIndex:row];
    
    return ph.phaseCode;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _selectedPhase = [_selectedClaim.phaseList objectAtIndex:row];
    
    _claims = [[NSMutableArray alloc] init];
    [_claims addObject:_selectedClaim];
    
    [_mainTableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    [UTIL showActivity:NSLocalizedStringFromTable(@"searching_jobs", [UTIL getLanguage], @"")];
    [self performSelector:@selector(search:) withObject:[searchBar text] afterDelay:0.1f];
}

- (void)search:(NSString *)term {
    [API findJob:USER.sessionId regionId:USER.regionId branchCode:@"" userCode:@"" searchString:[UTIL trim:term] completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqual: @""]) {
            NSMutableArray *responseData = ([result valueForKey:@"findJobResult"] != [NSNull null]) ?  [result valueForKey:@"findJobResult"] : nil;
            [self processSearchResults:responseData];
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
        }
    }];
}

- (void)searchClosest {
    [API findClosestJobs:USER.sessionId regionId:USER.regionId brnachCode:@"" userCode:@"" location:LOCATION.lastSavedLocation completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqual: @""]) {
            NSMutableArray *responseData = ([result valueForKey:@"findClosestJobsResult"] != [NSNull null]) ?  [result valueForKey:@"findClosestJobsResult"] : nil;
            [self processSearchResults:responseData];
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
        }
    }];
}

- (void)processSearchResults:(NSMutableArray *)results {
    _claims = [[NSMutableArray alloc] init];
    
    if ([results count] > 0) {
        _selectedPhase = [[Phase alloc] init];
        
        for (id claim in results) {
            Claim *item = [[Claim alloc] init];
            item.claimIndx = [[claim valueForKey:@"ClaimIndx"] intValue];
            item.claimNumber = [claim valueForKey:@"ClaimNumber"];
            item.projectName = [claim valueForKey:@"ProjectName"];
            item.dateJobOpen = [claim valueForKey:@"DateJobOpen"];
            item.addressString = [claim valueForKey:@"Address"];
            item.city = [claim valueForKey:@"City"];
            item.address.address = item.addressString;
            item.address.city = item.city;
            [item.address prepareFullAddress];
            
            [_claims addObject:item];
        }
        
        // show first 5 results
        _claims = [NSMutableArray arrayWithArray:[_claims subarrayWithRange:NSMakeRange(0, 5)]];
    } else {
        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"no_jobs_found", [UTIL getLanguage], @"")];
    }
    
    [_mainTableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
}

- (IBAction)donePressed:(id)sender {
    UITableViewCell *cell = [_mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UIDatePicker *dtPicker = (UIDatePicker *)[cell viewWithTag:2];
    UITextView *textView;
    
    _item.dateTimeFrom = dtPicker.date;
    
    if ([_item.item.genericId isEqual:@"2"] || [_item.item.genericId isEqual:@"1"]) { // clock out, // clock in
        _item.dateTimeTo = _item.dateTimeFrom;
    } else {
        // to date time
        cell = [_mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        dtPicker = (UIDatePicker *)[cell viewWithTag:4];
        _item.dateTimeTo = dtPicker.date;
    }
    
    if (_sectionCount > 1) {
        cell = [_mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        textView = (UITextView *)[cell viewWithTag:1];
        _item.notes = textView.text;
    }
    
    if (_sectionCount == 4) {
        // claim
        _item.claim = _selectedClaim;
        _item.phase = _selectedPhase;
    }
    
    if (_sectionCount > 1) {
        if ([_item.notes isEqual:@""]) {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:@"Please fill in notes..."];
        } else {
            if (_sectionCount == 4) {
                if (_item.claim.claimIndx == 0) {
                    [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:@"Please select a claim..."];
                } else {
                    if (_item.phase.phaseIndx == 0) {
                        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:@"Please select a phase..."];
                    } else {
                        [self done];
                    }
                }
            } else {
                [self done];
            }
        }
    } else {
        [self done];
    }
}

- (void)done {
    bool valid = true;
    NSMutableArray *teOverlapped = [[NSMutableArray alloc] init];
    // check for overlapped hours
    for (TimesheetEntry *te in _currentEvents) {
        if (te.entryId != _item.entryId) {
            if ((_item.dateTimeFrom < te.dateTimeTo && _item.dateTimeFrom > te.dateTimeFrom) || (_item.dateTimeTo < te.dateTimeTo && _item.dateTimeTo > te.dateTimeFrom) || (_item.dateTimeTo > te.dateTimeFrom && _item.dateTimeTo < te.dateTimeTo) || (_item.dateTimeFrom > te.dateTimeFrom && _item.dateTimeTo < te.dateTimeTo) || (_item.dateTimeFrom < te.dateTimeFrom && _item.dateTimeTo > te.dateTimeTo)) {
                valid = false;
                [teOverlapped addObject:te];
            }
        }
    }
    
    if (valid) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTimeline" object:_item];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [ALERT promptWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"you_have_overlapped_times_do_you_want_to_automatically_adjust_them", [UTIL getLanguage], @"") completion:^(BOOL granted) {
            if (granted) {
                for (TimesheetEntry *t in teOverlapped) {
                    bool signleTimedItem = (t.dateTimeFrom == t.dateTimeTo);
                    
                    if (self->_item.dateTimeFrom > t.dateTimeFrom) {
                        if (self->_item.dateTimeTo > t.dateTimeTo) {
                            // 1
                            t.dateTimeTo = self->_item.dateTimeFrom;
                        } else {
                            // 2
                            t.dateTimeTo = self->_item.dateTimeFrom;
                        }
                        
                        if (signleTimedItem) {
                            t.dateTimeFrom = t.dateTimeTo;
                        }
                    } else {
                        if (self->_item.dateTimeTo < t.dateTimeTo) {
                            // 3
                            t.dateTimeFrom = self->_item.dateTimeTo;
                        } else {
                            // 4
                            t.dateTimeFrom = self->_item.dateTimeTo;
                        }
                        if (signleTimedItem) {
                            t.dateTimeTo = t.dateTimeFrom;
                        }
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTimeline" object:t];
                    [UTIL hideActivity];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTimeline" object:self->_item];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

- (IBAction)cancelPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
