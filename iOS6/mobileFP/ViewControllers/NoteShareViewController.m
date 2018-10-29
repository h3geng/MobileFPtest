//
//  NoteShareViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-09-07.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import "NoteShareViewController.h"
#import "DeviceContactsViewController.h"
#import "NoteShareConfirmationViewController.h"

@interface NoteShareViewController ()

@end

@implementation NoteShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setTitle:NSLocalizedStringFromTable(@"share", [UTIL getLanguage], @"")];
    
    _contacts = [[NSMutableArray alloc] init];
    _claimContacts = [[NSMutableArray alloc] init];
    
    _recent = [[NSMutableArray alloc] init];
    _recentToShow = [[NSMutableArray alloc] init];
    
    [UTIL showActivity:NSLocalizedStringFromTable(@"loading", [UTIL getLanguage], @"")];
    [self performSelector:@selector(loadRecents:) withObject:@"1" afterDelay:0.1f];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noteShareConfirmed:) name:@"noteShareConfirmed" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadRecents:(NSString *)loadDefault {
    _recent = [[NSMutableArray alloc] init];
    
    [API getRecents:USER.sessionId userGUID:USER.userId isFOS:@"true" completion:^(NSMutableArray *result) {
        if (result) {
            for (NSMutableArray *item in [result valueForKey:@"getRecentsResult"]) {
                GenericObject *obj = [[GenericObject alloc] init];
                obj.code = [item valueForKey:@"Code"];
                obj.value = [item valueForKey:@"Value"];
                
                [self->_recent addObject:obj];
            }
        }
        
        [UTIL hideActivity];
        self->_recentToShow = [NSMutableArray arrayWithArray:self->_recent];
        
        if ([loadDefault isEqual:@"1"]) {
            [self collectDefaultContacts];
        }
    }];
}

- (void)collectDefaultContacts {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    for (Contact *cont in _note.claim.contactList) {
        GenericObject *obj = [[GenericObject alloc] init];
        obj.code = [NSString stringWithFormat:@"%@ - %@", cont.title, cont.fullName];
        obj.value = cont.email;
        
        if ([USER isProduction]) {
            if (cont.forProduction) {
                [arr addObject:obj];
            }
        } else {
            [arr addObject:obj];
        }
    }
    
    if (![[UTIL trim:_note.claim.adjuster.email] isEqual:@""] && ![USER isProduction]) {
        GenericObject *obj = [[GenericObject alloc] init];
        obj.code = [NSString stringWithFormat:@"Adjuster - %@", _note.claim.adjuster.fullName];
        obj.value = _note.claim.adjuster.email;
        [arr addObject:obj];
    }
    
    _claimContacts = [NSMutableArray arrayWithArray:arr];
    _contacts = [NSMutableArray arrayWithArray:_claimContacts];
    
    [self.tableView reloadData];
}

- (bool)checkAllSelected {
    bool response = true;
    
    for (GenericObject *item in _contacts) {
        if (![item.genericId isEqual:@"1"]) {
            response = false;
        }
    }
    
    return response;
}

- (void)addToRecent:(GenericObject *)obj {
    bool exists = false;
    for (GenericObject *item in _recent) {
        if ([item.code isEqual:obj.code] && [item.value isEqual:obj.value]) {
            exists = true;
        }
    }
    
    if (exists) {
        [_recentToShow addObject:obj];
    }
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *titleForHeader = @"";
    
    switch (section) {
        case 0:
            titleForHeader = NSLocalizedStringFromTable(@"contacts", [UTIL getLanguage], @"");
            break;
        case 1:
            titleForHeader = NSLocalizedStringFromTable(@"recent", [UTIL getLanguage], @"");
            break;
    }
    
    return titleForHeader;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *title = @"";
    
    if (section == 1) {
        if (_recentToShow.count == 0) {
            title = NSLocalizedStringFromTable(@"no_recent_contacts", [UTIL getLanguage], @"");
        } else {
            title = NSLocalizedStringFromTable(@"tap_to_add_recent_contact_to_sharing_contacts", [UTIL getLanguage], @"");
        }
    }
    
    return title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    
    switch (section) {
        case 0:
            numberOfRows = _contacts.count + 1;
            break;
        case 1:
            numberOfRows = _recentToShow.count;
            break;
        default:
            numberOfRows = 1;
            break;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    GenericObject *obj;
    
    switch ([indexPath section]) {
        case 0:
            if ([indexPath row] == 0) {
                [cell.textLabel setText:NSLocalizedStringFromTable(@"select_all", [UTIL getLanguage], @"")];
                if ([self checkAllSelected]) {
                    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                }
            } else {
                obj = [_contacts objectAtIndex:([indexPath row] - 1)];
                [cell.textLabel setText:obj.code];
                if ([obj.genericId isEqual:@"1"]) {
                    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                }
            }
            break;
        case 1:
            obj = [_recentToShow objectAtIndex:[indexPath row]];
            [cell.textLabel setText:obj.code];
            break;
        default:
            [cell.textLabel setText:NSLocalizedStringFromTable(@"share", [UTIL getLanguage], @"")];
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GenericObject *obj;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch ([indexPath section]) {
        case 0:
            if ([indexPath row] == 0) {
                for (GenericObject *item in _contacts) {
                    item.genericId = @"1";
                }
            } else {
                obj = [_contacts objectAtIndex:([indexPath row] - 1)];
                if ([obj.genericId isEqual:@"1"]) {
                    obj.genericId = @"0";
                } else {
                    obj.genericId = @"1";
                }
            }
            [self.tableView reloadData];
            break;
        case 1:
            obj = [_recentToShow objectAtIndex:[indexPath row]];
            obj.genericId = @"1";
            [_contacts addObject:obj];
            [_recentToShow removeObjectAtIndex:[indexPath row]];
            
            [self.tableView reloadData];
            break;
        case 2:
            [self share];
            break;
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    switch ([indexPath section]) {
        case 0:
            if ([indexPath row] > _claimContacts.count) {
                return YES;
            } else {
                return NO;
            }
            break;
        case 1:
            return YES;
            break;
        default:
            return NO;
            break;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        switch ([indexPath section]) {
            case 0:
            {
                if ([indexPath row] > _claimContacts.count) {
                    [ALERT promptWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"are_you_sure_you_want_to_remove_this_item", [UTIL getLanguage], @"") completion:^(BOOL granted) {
                        if (granted) {
                            GenericObject *obj = [self->_contacts objectAtIndex:([indexPath row] - 1)];
                            
                            [self->_contacts removeObjectAtIndex:([indexPath row] - 1)];
                            [self addToRecent:obj];
                            
                            [self.tableView reloadData];
                        }
                    }];
                }
            }
                break;
            case 1:
            {
                [ALERT promptWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"are_you_sure_you_want_to_remove_this_item", [UTIL getLanguage], @"") completion:^(BOOL granted) {
                    if (granted) {
                        GenericObject *obj = [self->_recent objectAtIndex:[indexPath row]];
                        [UTIL showActivity:@""];
                        [self performSelector:@selector(deleteRecent:) withObject:obj afterDelay:0.1f];
                    }
                }];
            }
                break;
        }
    }
}

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

- (void)deleteRecent:(GenericObject *)item {
    [API deleteRecent:USER.sessionId userGUID:USER.userId email:item.value completion:^(NSMutableArray *result) {
        [self loadRecents:@""];
    }];
}

- (void)share {
    if (!_note.share.sendEmail && !_note.share.sendPushNotification) {
        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"sendemail_or_sendpush", [UTIL getLanguage], @"")];
    } else {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (GenericObject *item in _contacts) {
            if ([item.genericId isEqual:@"1"]) {
                [arr addObject:item];
            }
        }
        
        if (arr.count == 0) {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"no_share_contacts_selected", [UTIL getLanguage], @"")];
        } else {
            _note.share.contacts = [NSMutableArray arrayWithArray:arr];
            [self performSegueWithIdentifier:@"showConfirmation" sender:self];
        }
    }
}

- (void)noteShareConfirmed:(NSNotification *)note {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noteShareConfirmed" object:nil];
    if (_note.noteId == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [UTIL showActivity:NSLocalizedStringFromTable(@"please_wait", [UTIL getLanguage], @"")];
        [self performSelector:@selector(noteShare) withObject:nil afterDelay:0.1f];
    }
}

- (void)noteShare {
    _note.share.regionId = _note.regionId;
    _note.share.claimId = _note.claim.claimIndx;
    _note.share.noteId = _note.noteId;
    
    [_note.share send:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        if (result == nil) {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"error_occurred_while_sharing_the_note", [UTIL getLanguage], @"")];
        } else {
            NSMutableArray *response = [result valueForKey:@"shareNoteResult"];
            if (![response isEqual:[NSNull null]]) {
                NSString *statusCode = [NSString stringWithFormat:@"%@",[response valueForKey:@"Status"]];
                if ([statusCode isEqual:@"0"]) {
                    [ALERT alertWithHandler:NSLocalizedStringFromTable(@"information", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"note_shared", [UTIL getLanguage], @"") completion:^(BOOL granted) {
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                } else {
                    [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"error_occurred_while_sharing_the_note", [UTIL getLanguage], @"")];
                }
            } else {
                [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"error_occurred_while_sharing_the_note", [UTIL getLanguage], @"")];
            }
        }
    }];
}

- (void)showCustomEmail {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"custom_email", [UTIL getLanguage], @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertActionOk = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"ok", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (alertController.textFields.count > 0) {
            UITextField *textField = [alertController.textFields firstObject];
            
            NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
            NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
            
            if ([emailTest evaluateWithObject:textField.text]) {
                GenericObject *obj = [[GenericObject alloc] init];
                obj.code = [UTIL trim:textField.text];
                obj.value = obj.code;
                obj.genericId = @"1";
                
                [self->_contacts addObject:obj];
                
                [self.tableView reloadData];
            } else {
                [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"invalid_email_address", [UTIL getLanguage], @"")];
            }
        }
    }];
    
    UIAlertAction *alertActionCancel = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:nil];
    
    [alertController addAction:alertActionOk];
    [alertController addAction:alertActionCancel];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedStringFromTable(@"custom_email", [UTIL getLanguage], @"");
        [textField setKeyboardType:UIKeyboardTypeEmailAddress];
    }];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showDeviceContacts"]) {
        DeviceContactsViewController *child = (DeviceContactsViewController *)[segue destinationViewController];
        [child setNote:_note];
    }
    
    if ([[segue identifier] isEqualToString:@"showConfirmation"]) {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (GenericObject *item in _contacts) {
            if ([item.genericId isEqual:@"1"]) {
                [arr addObject:item];
            }
        }
        
        NoteShareConfirmationViewController *child = (NoteShareConfirmationViewController *)[segue destinationViewController];
        [child setRecipients:arr];
    }
}

- (IBAction)addPressed:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"select_contacts", [UTIL getLanguage], @"") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionContacts = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"my_contacts", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self performSegueWithIdentifier:@"showDeviceContacts" sender:self];
    }];
    
    UIAlertAction *actionCustom = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"custom_email", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self showCustomEmail];
    }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", [UTIL getLanguage], @"") style:UIAlertActionStyleCancel handler:nil];
    [actionCancel setValue:[UTIL darkRedColor] forKey:@"titleTextColor"];
    
    [actionSheet addAction:actionContacts];
    [actionSheet addAction:actionCustom];
    [actionSheet addAction:actionCancel];
    
    if (IS_IPAD()) {
        UIPopoverPresentationController *popoverPresentationController = [actionSheet popoverPresentationController];
        popoverPresentationController.barButtonItem = _addButton;
        [actionSheet setModalPresentationStyle:UIModalPresentationPopover];
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

@end
