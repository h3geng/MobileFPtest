//
//  ClaimNoteViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/13/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "ClaimNoteViewController.h"
#import "SelectionViewController.h"
#import "NotesViewController.h"
#import "NoteShareViewController.h"

@interface ClaimNoteViewController ()

@end

@implementation ClaimNoteViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.claim = [[Claim alloc] init];
        self.department = [[GenericObject alloc] init];
        self.phase = [[GenericObject alloc] init];
        self.phase.value = NSLocalizedStringFromTable(@"all", [UTIL getLanguage], @"");
        
        self.alertPm = [[GenericObject alloc] init];
        self.note = @"";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setTitle:NSLocalizedStringFromTable(@"new_note", [UTIL getLanguage], @"")];
    
    _alertPm.code = @"No";
    _alertPm.value = @"0";
    
    _noteObject = [[Note alloc] init];
    [_noteObject setClaim:_claim];
}
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![_department.value isEqual: @""]) {
        if (![[UTIL trim:_note] isEqual: @""]) {
            [UTIL showActivity:NSLocalizedStringFromTable(@"saving", [UTIL getLanguage], @"")];
            [self performSelector:@selector(saveNoteProcess) withObject:nil afterDelay:0.1f];
        }
    }
}
*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setState:(id)sender {
    _alertPm = [[GenericObject alloc] init];
    UISwitch *theSwitch = (UISwitch *)sender;
    
    if (theSwitch.on) {
        _alertPm.code = @"On";
        _alertPm.value = @"1";
    } else {
        _alertPm.code = @"Off";
        _alertPm.value = @"0";
    }
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44.0f;
    if ([indexPath section] == 1) {
        height = 100.0f;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44.0f;
    if ([indexPath section] == 1) {
        height = 100.0f;
    }
    
    return height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = NSLocalizedStringFromTable(@"notes", [UTIL getLanguage], @"");
    if (section == 0) {
        title = [NSString stringWithFormat:@"%@ %@", NSLocalizedStringFromTable(@"note_for", [UTIL getLanguage], @""), _claim.claimNumber];
    }
    
    return title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 1;
    
    if (section == 0) {
        numberOfRows = 4;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    UITextView *details;
    UILabel *alertLabel;
    UISwitch *alertPmSwitch;
    
    if ([indexPath section] == 0) {
        switch ([indexPath row]) {
            case 0:
                [cell.textLabel setText:[NSString stringWithFormat:@"%@ %@", NSLocalizedStringFromTable(@"department", [UTIL getLanguage], @""), @"*"]];
                [cell.detailTextLabel setText:_department.value];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                break;
            case 1:
                [cell.textLabel setText:NSLocalizedStringFromTable(@"phase", [UTIL getLanguage], @"")];
                [cell.detailTextLabel setText:_phase.value];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                break;
            case 2:
                cell = [tableView dequeueReusableCellWithIdentifier:@"NoteAlertCell" forIndexPath:indexPath];
                alertLabel = (UILabel *)[cell viewWithTag:10];
                [alertLabel setText:NSLocalizedStringFromTable(@"alert_pm", [UTIL getLanguage], @"")];
                
                alertPmSwitch = (UISwitch *)[cell viewWithTag:20];
                [alertPmSwitch addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
                if ([_alertPm.value isEqual: @"1"]) {
                    [alertPmSwitch setOn:YES];
                } else {
                    [alertPmSwitch setOn:NO];
                }
                
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                break;
            case 3:
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                [cell.textLabel setText:NSLocalizedStringFromTable(@"share", [UTIL getLanguage], @"")];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                break;
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NotesCell" forIndexPath:indexPath];
        details = (UITextView *)[cell viewWithTag:100];
        [details setText:_note];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        switch ([indexPath row]) {
            case 0:
                [self performSegueWithIdentifier:@"showDepartments" sender:self];
                break;
            case 1:
                [self performSegueWithIdentifier:@"showPhases" sender:self];
                break;
            case 3:
                [self performSegueWithIdentifier:@"showShare" sender:self];
                break;
        }
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

- (NSMutableArray *)getSelectionArray {
    NSMutableArray *response = [[NSMutableArray alloc] init];
    GenericObject *go = [[GenericObject alloc] init];
    go.genericId = @"0";
    go.value = NSLocalizedStringFromTable(@"all", [UTIL getLanguage], @"");
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

- (void)setPhaseObject:(GenericObject *)item {
    bool phaseChanged = false;
    
    for (Phase *ph in _claim.phaseList) {
        if ([ph.phaseCode isEqual: item.value]) {
            _phase.genericId = [NSString stringWithFormat:@"%d", ph.phaseIndx];
            _phase.value = ph.phaseCode;
            phaseChanged = true;
        }
    }
    
    if (!phaseChanged) {
        _phase = [[GenericObject alloc] init];
        _phase.value = NSLocalizedStringFromTable(@"all", [UTIL getLanguage], @"");
    }
    [self.tableView reloadData];
}

- (void)setDepartmentObject:(GenericObject *)item {
    bool departmentChanged = false;
    
    for (GenericObject *dep in DEPARTMENTS.items) {
        if ([dep.value isEqual: item.value]) {
            _department = dep;
            departmentChanged = true;
        }
    }
    
    if (!departmentChanged) {
        _department = [[GenericObject alloc] init];
    }
    [self.tableView reloadData];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    _note = textView.text;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showDepartments"]) {
        SelectionViewController *child = (SelectionViewController *)[segue destinationViewController];
        [child setSelection:DEPARTMENTS.items];
        [child setSelectionTitle:NSLocalizedStringFromTable(@"department", [UTIL getLanguage], @"")];
        [child setSelectedObjectType:1];
        [child setSelectedObject:_department];
    }
    if ([[segue identifier] isEqualToString:@"showPhases"]) {
        SelectionViewController *child = (SelectionViewController *)[segue destinationViewController];
        [child setSelection:[self getSelectionArray]];
        [child setSelectionTitle:NSLocalizedStringFromTable(@"phase", [UTIL getLanguage], @"")];
        [child setSelectedObjectType:2];
        [child setSelectedObject:[self getSelectionObject]];
    }
    if ([[segue identifier] isEqualToString:@"showShare"]) {
        NoteShareViewController *child = (NoteShareViewController *)[segue destinationViewController];
        [child setNote:_noteObject];
    }
}

- (IBAction)savePressed:(id)sender {
    if (![_department.value isEqual: @""]) {
        if (![[UTIL trim:_note] isEqual: @""]) {
            [UTIL showActivity:NSLocalizedStringFromTable(@"saving", [UTIL getLanguage], @"")];
            [self performSelector:@selector(saveNoteProcess) withObject:nil afterDelay:0.1f];
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"fill_in_notes", [UTIL getLanguage], @"")];
        }
    } else {
        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"select_a_department", [UTIL getLanguage], @"")];
    }
}

- (void)saveNoteProcess {
    // department code
    NSString *departmentCode = @"";
    for (GenericObject *department in DEPARTMENTS.items) {
        if ([department.value isEqual: _department.value]) {
            departmentCode = department.genericId;
            break;
        }
    }
    
    // alert PM
    if ([_alertPm.value isEqualToString: @"0"]) {
        _alertPm.value = @"false";
    } else {
        _alertPm.value = @"true";
    }
    
    // Phase index
    int phaseIndx = 0;
    for (Phase *phase in _claim.phaseList) {
        if (phase.phaseIndx == [_phase.genericId integerValue]) {
            phaseIndx = phase.phaseIndx;
        }
    }
    
    // fix note text for unwanted characters
    _note = [_note stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    
    [API addNoteToJob:USER.sessionId regionId:USER.regionId claimIndex:_claim.claimIndx phaseIndex:phaseIndx departmentCode:departmentCode note:_note alertPM:_alertPm.value completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSString *error = @"";
        if ([result valueForKey:@"Message"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"Message"]];
        }
        
        if ([error isEqualToString: @""]) {
            NSMutableArray *response = [result valueForKey:@"d"];
            [ALERT alertWithHandler:NSLocalizedStringFromTable(@"information", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"the_note_has_been_saved", [UTIL getLanguage], @"") completion:^(BOOL granted) {
                if (self->_noteObject.share.contacts.count > 0) {
                    self->_noteObject.noteId = [[response valueForKey:@"itemId"] intValue];
                    
                    [UTIL showActivity:NSLocalizedStringFromTable(@"please_wait", [UTIL getLanguage], @"")];
                    [self performSelector:@selector(noteShare) withObject:nil afterDelay:0.1f];
                } else {
                    [self goBack];
                }
            }];
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
        }
    }];
}

- (void)noteShare {
    _noteObject.share.regionId = _claim.regionId;
    _noteObject.share.claimId = _claim.claimIndx;
    _noteObject.share.noteId = _noteObject.noteId;
    
    [_noteObject.share send:^(NSMutableArray *result) {
        [UTIL hideActivity];
        // check if shared
        if (result == nil) {
            [ALERT alertWithHandler:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"error_occurred_while_sharing_the_note", [UTIL getLanguage], @"") completion:^(BOOL granted) {
                [self goBack];
            }];
        } else {
            NSMutableArray *response = [result valueForKey:@"shareNoteResult"];
            if (![[[response valueForKey:@"Status"] stringValue] isEqual:@"0"]) {
                [ALERT alertWithHandler:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"error_occurred_while_sharing_the_note", [UTIL getLanguage], @"") completion:^(BOOL granted) {
                    [self goBack];
                }];
            } else {
                [ALERT alertWithHandler:NSLocalizedStringFromTable(@"information", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"note_shared", [UTIL getLanguage], @"") completion:^(BOOL granted) {
                    [self goBack];
                }];
            }
        }
    }];
}

- (void)goBack {
    UIViewController *parent = [APP_DELEGATE getPreviousScreen];
    if ([parent isKindOfClass:[NotesViewController class]]) {
        NotesViewController *notesViewController = (NotesViewController *)parent;
        [notesViewController setReload:true];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
