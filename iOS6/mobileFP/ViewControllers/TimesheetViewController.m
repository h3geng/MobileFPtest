//
//  TimesheetViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 9/27/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "TimesheetViewController.h"
#import "EmployeesViewController.h"
#import "SelectionViewController.h"
#import "TextReaderViewController.h"
#import "HoursViewController.h"

@interface TimesheetViewController ()

@end

@implementation TimesheetViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.employee = [[GenericObject alloc] init];
        self.claim = [[Claim alloc] init];
        self.phase = [[GenericObject alloc] init];
        self.date = [NSDate date];
        self.dateStart = [NSDate date];
        self.dateEnd = [NSDate date];
        self.hours = 0;
        self.notes = @"";
        
        _dateFormat = [[NSDateFormatter alloc] init];
        [_dateFormat setDateStyle:NSDateFormatterLongStyle];
        [_dateFormat setTimeStyle:NSDateFormatterNoStyle];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedStringFromTable(@"timesheet", [UTIL getLanguage], @"")];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _claimDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [_claimDatePicker setDatePickerMode:UIDatePickerModeDate];
    
    _employee.genericId = @"1";
    _employee.value = USER.userId;
    _employee.code = USER.name;
    
    [_dateDetailLabel setTintColor:[UIColor clearColor]];
    [_dateDetailLabel setInputView:_claimDatePicker];
    [self setUpAccessoryView:_dateDetailLabel];
    
    [_hoursDetailLabel setTintColor:[UIColor clearColor]];
    [_hoursDetailLabel setEnabled:NO];
    
    [self refreshTable];
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
    [_dateDetailLabel resignFirstResponder];
}

- (void)dateSelected:(id)sender {
    NSDate *date = _claimDatePicker.date;
    _date = date;
    [_dateDetailLabel setText:[_dateFormat stringFromDate:date]];
    [_dateDetailLabel resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setTitle:NSLocalizedStringFromTable(@"timesheet", [UTIL getLanguage], @"")];
    [self localize];
    
    if (USER.isProduction) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
}

- (void)localize {
    if (USER.isProduction) {
        [_employeeLabel setText:@""];
    } else {
        [_employeeLabel setText:NSLocalizedStringFromTable(@"employee", [UTIL getLanguage], @"")];
    }
    [_claimLabel setText:NSLocalizedStringFromTable(@"job", [UTIL getLanguage], @"")];
    [_phaseLabel setText:NSLocalizedStringFromTable(@"phase", [UTIL getLanguage], @"")];
    [_dateLabel setText:NSLocalizedStringFromTable(@"date", [UTIL getLanguage], @"")];
    [_hoursLabel setText:NSLocalizedStringFromTable(@"hours", [UTIL getLanguage], @"")];
    [_notesLabel setText:NSLocalizedStringFromTable(@"notes", [UTIL getLanguage], @"")];
}

- (void)refreshTable {
    if (USER.isProduction) {
        [_employeeDetailLabel setText:@""];
    } else {
        [_employeeDetailLabel setText:_employee.code];
    }
    [_claimDetailLabel setText:_claim.claimNumber];
    [_phaseDetailLabel setText:_phase.value];
    [_dateDetailLabel setText:[_dateFormat stringFromDate:_date]];
    [_hoursDetailLabel setText:[NSString stringWithFormat:@"%.1f", _hours]];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat heightForRow = 44.0f;
    
    if (USER.isProduction && indexPath.row == 0) {
        heightForRow = 0.01f;
    }
    
    return heightForRow;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 6;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath row]) {
        case 0:
            if (!USER.isProduction) {
                [self performSegueWithIdentifier:@"showEmployees" sender:self];
            }
            break;
        case 1:
            [self performSegueWithIdentifier:@"showClaims" sender:self];
            break;
        case 2:
            [self performSegueWithIdentifier:@"showPhases" sender:self];
            break;
        case 3:
            [_dateDetailLabel becomeFirstResponder];
            break;
        case 4:
            [self performSegueWithIdentifier:@"showHours" sender:self];
            break;
        case 5:
            [self performSegueWithIdentifier:@"showNotes" sender:self];
            break;
    }
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    // Configure the cell...
    
    return cell;
}
*/

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

- (NSMutableArray *)getSelectionArray {
    NSMutableArray *response = [[NSMutableArray alloc] init];
    GenericObject *go = [[GenericObject alloc] init];
    go.genericId = @"0";
    go.value = NSLocalizedStringFromTable(@"no_phase", [UTIL getLanguage], @"");
    [response addObject:go];
    
    for (Phase *ph in _claim.phaseList) {
        go = [[GenericObject alloc] init];
        go.genericId = [NSString stringWithFormat:@"%d", ph.phaseIndx];
        go.value = ph.phaseCode;
        [response addObject:go];
    }
    
    return response;
}

- (GenericObject *)getSelectionObject {
    GenericObject *go = [[GenericObject alloc] init];
    go.genericId = _phase.genericId;
    go.value = _phase.value;
    
    return go;
}

- (void)setSelectionObject:(GenericObject *)item {
    bool phaseChanged = false;
    
    for (Phase *ph in _claim.phaseList) {
        if ([ph.phaseCode isEqual: item.value]) {
            _phase = item;
            phaseChanged = true;
        }
    }
    
    if (!phaseChanged) {
        _phase = [[GenericObject alloc] init];
    }
    [self refreshTable];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showPhases"]) {
        SelectionViewController *child = (SelectionViewController *)[segue destinationViewController];
        [child setSelection:[self getSelectionArray]];
        [child setSelectionTitle:NSLocalizedStringFromTable(@"phase", [UTIL getLanguage], @"")];
        [child setSelectedObjectType:1];
        [child setSelectedObject:[self getSelectionObject]];
    }
    if ([[segue identifier] isEqualToString:@"showNotes"]) {
        TextReaderViewController *child = (TextReaderViewController *)[segue destinationViewController];
        [child setAllowEdit:true];
        [child setText:_notes];
    }
    if ([[segue identifier] isEqualToString:@"showHours"]) {
        HoursViewController *child = (HoursViewController *)[segue destinationViewController];
        [child setBegin:_dateStart];
        [child setEnd:_dateEnd];
    }
}

- (IBAction)savePressed:(id)sender {
    if ([_employee.genericId isEqual:@"0"]) {
        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"select_employee", [UTIL getLanguage], @"")];
    } else {
        if (_claim.claimIndx > 0) {
            if (_hours > 0) {
                [UTIL showActivity:NSLocalizedStringFromTable(@"saving", [UTIL getLanguage], @"")];
                [self performSelector:@selector(saveTimesheetProcess) withObject:nil afterDelay:0.1f];
            } else {
                [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"fill_in_hours", [UTIL getLanguage], @"")];
            }
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"select_a_job", [UTIL getLanguage], @"")];
        }
    }
}

- (void)saveTimesheetProcess {
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd"];
    
    NSDateFormatter *dftime = [[NSDateFormatter alloc]init];
    [dftime setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    [API saveTimeSheet:USER.sessionId entryId:0 categoryId:0 regionId:USER.regionId branchId:[USER.branch.genericId intValue] claimIndx:_claim.claimIndx phaseIndx:[_phase.genericId intValue] projectName:_claim.claimNumber costCategoryId:0 employeeId:USER.userId dateStart:[dftime stringFromDate:_dateStart] dateStop:[dftime stringFromDate:_dateEnd] hours:_hours note:_notes latitude:LOCATION.lastSavedLocation.coordinate.latitude longitude:LOCATION.lastSavedLocation.coordinate.longitude isMobile:1 enteredById:USER.userId modifiedById:USER.userId completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        if ([error isEqualToString: @""]) {
            self->_employee = [[GenericObject alloc] init];
            self->_employee.genericId = @"1";
            self->_employee.value = USER.userId;
            self->_employee.code = USER.name;
            
            self->_claim = [[Claim alloc] init];
            self->_phase = [[GenericObject alloc] init];
            self->_date = [NSDate date];
            self->_hours = 0;
            self->_notes = @"";
            
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"information", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"timesheet_saved", [UTIL getLanguage], @"")];
            
            [self refreshTable];
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
        }
    }];
}

@end
