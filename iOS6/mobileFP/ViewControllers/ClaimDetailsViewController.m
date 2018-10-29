//
//  ClaimDetailsViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 9/29/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "ClaimDetailsViewController.h"
#import "ClaimPhotosViewController.h"
#import "NotesViewController.h"
#import "ClaimEquipmentViewController.h"
#import "PhasesViewController.h"
#import "ContactsViewController.h"
#import "PayPalMobile.h"

@interface ClaimDetailsViewController ()

@end

@implementation ClaimDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_claim.claimNumber) {
        [self setTitle:_claim.claimNumber];
    } else {
        [self setTitle:NSLocalizedStringFromTable(@"claim_details", [UTIL getLanguage], @"")];
    }
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // pull to refresh init
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor darkGrayColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(doRefresh) forControlEvents:UIControlEventValueChanged];
    
    // See PayPalConfiguration.h for details and default values.
    // Should you wish to change any of the values, you can do so here.
    // For example, if you wish to accept PayPal but not payment card payments, then add:
    //_payPalConfiguration.acceptCreditCards = YES;
    // Or if you wish to have the user choose a Shipping Address from those already
    // associated with the user's PayPal account, then add:
    //_payPalConfiguration.payPalShippingAddressOption = PayPalShippingAddressOptionNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doRefresh {
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedStringFromTable(@"loading_job", [UTIL getLanguage], @"") attributes:attrsDictionary];
    self.refreshControl.attributedTitle = attributedTitle;
    [self performSelector:@selector(loadClaim) withObject:nil afterDelay:0.1f];
}

- (void)loadClaim {
    [_claim load:^(bool result) {
        if (result) {
            [self.refreshControl endRefreshing];
        } else {
            [self.refreshControl endRefreshing];
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"job_not_loaded", [UTIL getLanguage], @"")];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionName = @"";
    
    switch (section) {
        case 0:
            sectionName = NSLocalizedStringFromTable(@"claim_details", [UTIL getLanguage], @"");
            break;
        case 1:
            sectionName = NSLocalizedStringFromTable(@"contacts", [UTIL getLanguage], @"");
            break;
        case 2:
            sectionName = NSLocalizedStringFromTable(@"workflow_kpi", [UTIL getLanguage], @"");
            break;
        case 3:
            sectionName = NSLocalizedStringFromTable(@"emergency_phase", [UTIL getLanguage], @"");
            break;
        case 4:
            sectionName = NSLocalizedStringFromTable(@"rebuild_phase", [UTIL getLanguage], @"");
            break;
    }
    
    return sectionName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger cnt = 1;
    
    switch (section) {
        case 0:
            cnt = 7;
            if (![APP_MODE isEqual: @"0"]) {
                cnt = 6;
            }
            break;
        case 1:
            cnt = 1;
            break;
        case 2:
            cnt = 3;
            break;
        case 3:
        case 4:
            cnt = 4;
            break;
    }
    
    return cnt;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    UILabel *lbl;
    NSMutableArray *obj;
    NSString *val;
    
    switch (indexPath.section) {
        case 0:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            switch ([indexPath row]) {
                case 0:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"project", [UTIL getLanguage], @"")];
                    [cell.detailTextLabel setText:_claim.projectName];
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    break;
                case 1:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"address", [UTIL getLanguage], @"")];
                    [cell.detailTextLabel setText:_claim.address.fullAddress];
                    if (![_claim.address.address isEqual:@""]) {
                        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    }
                    break;
                case 2:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"opened", [UTIL getLanguage], @"")];
                    [cell.detailTextLabel setText:_claim.dateJobOpen];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    break;
                case 3:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"pm", [UTIL getLanguage], @"")];
                    [cell.detailTextLabel setText:_claim.projectManager];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    break;
                case 4:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"loss_type", [UTIL getLanguage], @"")];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@",_claim.lossType]];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    break;
                case 5:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"phase_list", [UTIL getLanguage], @"")];
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    break;
                case 6:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"payment", [UTIL getLanguage], @"")];
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    break;
            }
            break;
        case 1:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            [cell.textLabel setText:NSLocalizedStringFromTable(@"view_contacts", [UTIL getLanguage], @"")];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            break;
        case 2:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            switch ([indexPath row]) {
                case 0:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"called_in", [UTIL getLanguage], @"")];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@", _claim.kPI.actuals.dateCalledIn]];
                    break;
                case 1:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"customer_contact", [UTIL getLanguage], @"")];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@", _claim.kPI.actuals.dateCustContact]];
                    val = _claim.kPI.scores.custContact;
                    if (!val || (NSNull *)val == [NSNull null]) {
                        val = @"0";
                    }
                    lbl = [UTIL getBadge:[val floatValue] type:0];
                    cell.accessoryView = [[UIView alloc] initWithFrame:lbl.frame];
                    [cell.accessoryView addSubview:lbl];
                    break;
                case 2:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"site_inspection", [UTIL getLanguage], @"")];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@", _claim.kPI.actuals.dateSiteInspect]];
                    val = _claim.kPI.scores.siteInspect;
                    if (!val || (NSNull *)val == [NSNull null]) {
                        val = @"0";
                    }
                    lbl = [UTIL getBadge:[val floatValue] type:0];
                    cell.accessoryView = [[UIView alloc] initWithFrame:lbl.frame];
                    [cell.accessoryView addSubview:lbl];
                    break;
            }
            break;
        case 3:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            switch ([indexPath row]) {
                case 0:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"em_assigned", [UTIL getLanguage], @"")];
                    obj = [self findObject:_claim.kPI.actuals.phaseTimelines type:@"EM"];
                    if ([obj count] > 0) {
                        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@", [[obj objectAtIndex:0] valueForKey:@"dateAssigned"]]];
                    }
                    break;
                case 1:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"em_estimate", [UTIL getLanguage], @"")];
                    obj = [self findObject:_claim.kPI.actuals.phaseTimelines type:@"EM"];
                    if ([obj count] > 0) {
                        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@", [[obj objectAtIndex:0] valueForKey:@"dateEstimate"]]];
                    }
                    obj = [self findObject:_claim.kPI.scores.phaseScores type:@"EM"];
                    if ([obj count] > 0) {
                        val = [[obj objectAtIndex:0] valueForKey:@"estimate"];
                        if (!val || (NSNull *)val == [NSNull null]) {
                            val = @"0";
                        }
                        lbl = [UTIL getBadge:[val floatValue] type:0];
                        cell.accessoryView = [[UIView alloc] initWithFrame:lbl.frame];
                        [cell.accessoryView addSubview:lbl];
                    }
                    break;
                case 2:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"em_start_work", [UTIL getLanguage], @"")];
                    obj = [self findObject:_claim.kPI.actuals.phaseTimelines type:@"EM"];
                    if ([obj count] > 0) {
                        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@", [[obj objectAtIndex:0] valueForKey:@"dateWorkStart"]]];
                    }
                    break;
                case 3:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"em_complete_work", [UTIL getLanguage], @"")];
                    obj = [self findObject:_claim.kPI.actuals.phaseTimelines type:@"EM"];
                    if ([obj count] > 0) {
                        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@", [[obj objectAtIndex:0] valueForKey:@"dateWorkComplete"]]];
                    }
                    obj = [self findObject:_claim.kPI.scores.phaseScores type:@"EM"];
                    if ([obj count] > 0) {
                        val = [[obj objectAtIndex:0] valueForKey:@"workAssignToStop"];
                        if (!val || (NSNull *)val == [NSNull null]) {
                            val = @"0";
                        }
                        lbl = [UTIL getBadge:[val floatValue] type:0];
                        cell.accessoryView = [[UIView alloc] initWithFrame:lbl.frame];
                        [cell.accessoryView addSubview:lbl];
                    }
                    break;
            }
            break;
        case 4:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            switch ([indexPath row]) {
                case 0:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"re_assigned", [UTIL getLanguage], @"")];
                    obj = [self findObject:_claim.kPI.actuals.phaseTimelines type:@"RE"];
                    if ([obj count] > 0) {
                        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@", [[obj objectAtIndex:0] valueForKey:@"dateAssigned"]]];
                    }
                    break;
                case 1:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"re_estimate", [UTIL getLanguage], @"")];
                    obj = [self findObject:_claim.kPI.actuals.phaseTimelines type:@"RE"];
                    if ([obj count] > 0) {
                        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@", [[obj objectAtIndex:0] valueForKey:@"dateEstimate"]]];
                    }
                    obj = [self findObject:_claim.kPI.scores.phaseScores type:@"RE"];
                    if ([obj count] > 0) {
                        val = [[obj objectAtIndex:0] valueForKey:@"estimate"];
                        if (!val || (NSNull *)val == [NSNull null]) {
                            val = @"0";
                        }
                        lbl = [UTIL getBadge:[val floatValue] type:0];
                        cell.accessoryView = [[UIView alloc] initWithFrame:lbl.frame];
                        [cell.accessoryView addSubview:lbl];
                    }
                    break;
                case 2:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"re_start_work", [UTIL getLanguage], @"")];
                    obj = [self findObject:_claim.kPI.actuals.phaseTimelines type:@"RE"];
                    if ([obj count] > 0) {
                        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@", [[obj objectAtIndex:0] valueForKey:@"dateWorkStart"]]];
                    }
                    break;
                case 3:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"re_complete_work", [UTIL getLanguage], @"")];
                    obj = [self findObject:_claim.kPI.actuals.phaseTimelines type:@"RE"];
                    if ([obj count] > 0) {
                        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@", [[obj objectAtIndex:0] valueForKey:@"dateWorkComplete"]]];
                    }
                    obj = [self findObject:_claim.kPI.scores.phaseScores type:@"RE"];
                    if ([obj count] > 0) {
                        val = [[obj objectAtIndex:0] valueForKey:@"workAssignToStop"];
                        if (!val || (NSNull *)val == [NSNull null]) {
                            val = @"0";
                        }
                        lbl = [UTIL getBadge:[val floatValue] type:0];
                        cell.accessoryView = [[UIView alloc] initWithFrame:lbl.frame];
                        [cell.accessoryView addSubview:lbl];
                    }
                    break;
            }
            break;
        default:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath section]) {
        case 0:
            switch ([indexPath row]) {
                case 0:
                    [self performSegueWithIdentifier:@"showLossDescription" sender:self];
                    break;
                case 1:
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                    if (![_claim.address.address isEqual:@""]) {
                        [self showMap];
                    }
                    break;
                case 5:
                    [self performSegueWithIdentifier:@"showPhases" sender:self];
                    break;
                case 6:
                    [self performSegueWithIdentifier:@"showPayments" sender:self];
                    break;
                default:
                    break;
            }
            break;
        case 1:
            [self performSegueWithIdentifier:@"showContacts" sender:self];
            break;
        default:
            break;
    }
}

- (void)showMap {
    NSString *fullAddress = [NSString stringWithFormat:@"%@+%@+%@",_claim.addressString, _claim.city, _claim.postal];
    fullAddress = [fullAddress stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSURL *googleURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"comgooglemaps://?saddr=%@", fullAddress]];
    NSURL *googleWebURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://www.maps.google.com/maps?saddr=%@", fullAddress]];
    NSURL *appleURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://maps.apple.com/?daddr=%@", fullAddress]];
    
    if ([[UIApplication sharedApplication] canOpenURL:googleURL]) {
        [[UIApplication sharedApplication] openURL:googleURL options:@{} completionHandler:nil];
    } else {
        if ([[UIApplication sharedApplication] canOpenURL:appleURL]) {
            [[UIApplication sharedApplication] openURL:appleURL options:@{} completionHandler:nil];
        }
        else {
            [[UIApplication sharedApplication] openURL:googleWebURL options:@{} completionHandler:nil];
        }
    }
}

- (NSMutableArray *)findObject:(NSMutableArray *)data type:(NSString *)type {
    NSMutableArray *filtered = [[NSMutableArray alloc] init];
    for (id obj in data) {
        if ([[NSString stringWithFormat:@"%@",[obj valueForKey:@"phaseCode"]] isEqualToString: type]) {
            [filtered addObject:obj];
        }
    }
    
    return filtered;
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
    if ([[segue identifier] isEqualToString:@"showPhotos"]) {
        ClaimPhotosViewController *child = (ClaimPhotosViewController *)[segue destinationViewController];
        [child setClaim:_claim];
    }
    if ([[segue identifier] isEqualToString:@"showNotes"]) {
        NotesViewController *child = (NotesViewController *)[segue destinationViewController];
        [child setClaim:_claim];
    }
    if ([[segue identifier] isEqualToString:@"showEquipment"]) {
        ClaimEquipmentViewController *child = (ClaimEquipmentViewController *)[segue destinationViewController];
        [child setClaim:_claim];
    }
    if ([[segue identifier] isEqualToString:@"showPhases"]) {
        PhasesViewController *child = (PhasesViewController *)[segue destinationViewController];
        [child setClaim:_claim];
    }
    if ([[segue identifier] isEqualToString:@"showContacts"]) {
        ContactsViewController *child = (ContactsViewController *)[segue destinationViewController];
        [child setClaim:_claim];
    }
    if ([[segue identifier] isEqualToString:@"showTimesheet"]) {
        TimesheetViewController *child = (TimesheetViewController *)[segue destinationViewController];
        [child setClaim:_claim];
    }
    if ([[segue identifier] isEqualToString:@"showWorkOrders"]) {
        
    }
    if ([[segue identifier] isEqualToString:@"showPayments"]) {
        PaymentsViewController *child = (PaymentsViewController *)[segue destinationViewController];
        [child setClaim:_claim];
    }
    if ([[segue identifier] isEqualToString:@"showChats"]) {
        //ChatsViewController *child = (ChatsViewController *)[segue destinationViewController];
        //[child setClaim:_claim];
    }
    if ([[segue identifier] isEqualToString:@"showLossDescription"]) {
        TextReaderViewController *child = (TextReaderViewController *)[segue destinationViewController];
        [child setHeaderTitle:@"Loss Description"];
        [child setText:_claim.lossDescription];
        [child setAllowEdit:NO];
    }
}

- (IBAction)actionPressed:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"choose_action", [UTIL getLanguage], @"") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionEquipment = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"equipment", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self showEquipment];
    }];
    
    UIAlertAction *actionNotes = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"notes", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self showNotes];
    }];
    
    UIAlertAction *actionPhotos = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"photos", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self showPhotos];
    }];
    
    UIAlertAction *actionMessages = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"messages", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self showMessages];
    }];
    
    UIAlertAction *actionWorkOrders = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"work_orders", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self showWorkOrders];
    }];
    
    UIAlertAction *actionDocuments = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"documents", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self showDocuments];
    }];
    
    UIAlertAction *actionSchedule = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"schedule", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
         [self showSchedule];
    }];
    
    UIAlertAction *actionMoistures = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"moistures", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self showMoistures];
    }];
    
    UIAlertAction *actionTimesheet = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"timesheet", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self showTimesheet];
    }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", [UTIL getLanguage], @"") style:UIAlertActionStyleCancel handler:nil];
    [actionCancel setValue:[UTIL darkRedColor] forKey:@"titleTextColor"];
    
    [actionSheet addAction:actionEquipment];
    [actionSheet addAction:actionNotes];
    [actionSheet addAction:actionPhotos];
    if ([APP_MODE isEqual: @"0"]) {
        [actionSheet addAction:actionMessages];
        [actionSheet addAction:actionWorkOrders];
        [actionSheet addAction:actionDocuments];
        [actionSheet addAction:actionSchedule];
        [actionSheet addAction:actionMoistures];
        [actionSheet addAction:actionTimesheet];
    }
    [actionSheet addAction:actionCancel];
    
    if (IS_IPAD()) {
        UIPopoverPresentationController *popoverPresentationController = [actionSheet popoverPresentationController];
        popoverPresentationController.barButtonItem = _actionsButton;
        [actionSheet setModalPresentationStyle:UIModalPresentationPopover];
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)showSchedule {
    [ALERT alertWithTitle:@"Warning" message:@"Sorry, Schedule feature not implemented yet..."];
}

- (void)showEquipment {
    [self performSegueWithIdentifier:@"showEquipment" sender:self];
}

- (void)showNotes {
    [self performSegueWithIdentifier:@"showNotes" sender:self];
}

- (void)showPhotos {
    [self performSegueWithIdentifier:@"showPhotos" sender:self];
}

- (void)showWorkOrders {
    //[self performSegueWithIdentifier:@"showWorkOrders" sender:self];
    [ALERT alertWithTitle:@"Warning" message:@"Sorry, Work Orders feature not implemented yet..."];
}

- (void)showDocuments {
    [ALERT alertWithTitle:@"Warning" message:@"Sorry, Documents feature not implemented yet..."];
}

- (void)showMoistures {
    [ALERT alertWithTitle:@"Warning" message:@"Sorry, Moistures feature not implemented yet..."];
}

- (void)showTimesheet {
    [self performSegueWithIdentifier:@"showTimesheet" sender:self];
}

- (void)showMessages {
    [self performSegueWithIdentifier:@"showChats" sender:self];
}

@end
