//
//  EquipmentDetailsViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 9/27/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "EquipmentDetailsViewController.h"
#import "InventoryViewController.h"
#import "ClaimEquipmentViewController.h"
#import "SelectionViewController.h"
#import "BranchesViewController.h"
#import "CameraViewController.h"

@interface EquipmentDetailsViewController ()

@end

@implementation EquipmentDetailsViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.allowActions = true;
        self.receiveModeInventory = true;
        self.reloadOnAppear = true;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:_inventory.itemModel];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedExternalScannerResponse:) name:@"externalScannerResponse" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedClaimToIssue:) name:@"receivedClaimToIssue" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAssetTag:) name:@"changeAssetTag" object:nil];
    
    if (!_allowActions) {
        [self.navigationItem setRightBarButtonItem:nil];
    }
    
    _receiveModeInventory = true;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_reloadOnAppear) {
        [UTIL showActivity:NSLocalizedStringFromTable(@"loading", [UTIL getLanguage], @"")];
        [self performSelector:@selector(reloadInventoryData) withObject:nil afterDelay:0.1f];
    } else {
        _reloadOnAppear = true;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_claimToIssue.claimIndx > 0 && _receivedClaim) {
        _receivedClaim = false;
        
        [UTIL hideActivity];
        [self performSegueWithIdentifier:@"showPhases" sender:self];
    }
}

- (void)reloadInventoryData {
    [_inventory reload:^(bool result) {
        if (result) {
            [UTIL hideActivity];
            
            [self setTitle:self->_inventory.itemModel];
            [self.tableView reloadData];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //[self onEndFlash:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)changeAssetTag:(NSNotification *)notification {
    NSString *receivedTag = [[notification userInfo] valueForKey:@"data"];
    
    [UTIL showActivity:NSLocalizedStringFromTable(@"saving", [UTIL getLanguage], @"")];
    [self performSelector:@selector(replaceItemTag:) withObject:receivedTag afterDelay:0.1f];
}

- (void)receivedExternalScannerResponse:(NSNotification *)notification {
    if ([[APP_DELEGATE getCurrentScreen] isKindOfClass:[self class]]) {
        [_actionSheet dismissViewControllerAnimated:YES completion:^{
            NSString *receivedTag = @"";
            id data = [[notification userInfo] valueForKey:@"data"];
            if ([data isKindOfClass:[Inventory class]]) {
                receivedTag = ((Inventory *)data).assetTag;
            } else {
                receivedTag = (NSString *)data;
            }
            
            if ([receivedTag isEqual:@""]) {
                [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"unknown_error", [UTIL getLanguage], @"")];
            } else {
                UIViewController *lastController = [APP_DELEGATE getCurrentScreen];
                UIViewController *prevController = [APP_DELEGATE getPreviousScreen];
                
                if (([lastController isKindOfClass:[self class]] && ![prevController isKindOfClass:[ClaimEquipmentViewController class]]) || [lastController isKindOfClass:[CameraViewController class]]) {
                    if ([lastController isKindOfClass:[CameraViewController class]]) {
                        self->_receiveModeInventory = false;
                    }
                    
                    if (self->_receiveModeInventory) {
                        if ([[[notification userInfo] valueForKey:@"data"] isKindOfClass:[Inventory class]]) {
                            self->_inventory = (Inventory *)[[notification userInfo] valueForKey:@"data"];
                            
                            [self setTitle:self->_inventory.itemModel];
                            [self.tableView reloadData];
                        }
                    } else {
                        [self onEndFlash:nil];
                        
                        [UTIL showActivity:NSLocalizedStringFromTable(@"saving", [UTIL getLanguage], @"")];
                        [self performSelector:@selector(replaceItemTag:) withObject:receivedTag afterDelay:0.1f];
                    }
                }
            }
        }];
        
    }
}

- (void)replaceItemTag:(NSString *)tag {
    @try {
        NSString *tagRegex = @"^[0-9]{7}$";
        NSPredicate *tagTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", tagRegex];
        
        if ([tagTest evaluateWithObject:tag]) {
            [API replaceAssetTag:USER.sessionId regionId:USER.regionId inventoryId:_inventory.inventoryId newTag:tag completion:^(NSMutableArray *result) {
                [UTIL hideActivity];
                
                NSString *error = @"";
                if ([result valueForKey:@"error"]) {
                    error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
                }
                
                if ([error isEqualToString: @""]) {
                    NSMutableArray *responseData = [result valueForKey:@"replaceAssetTagResult"];
                    NSString *message = [responseData valueForKey:@"Message"];
                    
                    if ([message isEqual: [NSNull null]]) {
                        self->_inventory.assetTag = tag;
                        [self.tableView reloadData];
                    } else {
                        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:message];
                    }
                } else {
                    [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
                }
            }];
        } else {
            [UTIL hideActivity];
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"invalid_asset_tag", [UTIL getLanguage], @"")];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.debugDescription);
        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"unknown_error", [UTIL getLanguage], @"")];
    }
    @finally {
        [UTIL hideActivity];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 1;
    
    if (section == 1) {
        numberOfRows = 5;
        if (USER.isProduction) {
            numberOfRows = 4;
        }
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    switch ([indexPath section]) {
        case 0:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            [cell.textLabel setText:NSLocalizedStringFromTable(@"change_asset_tag", [UTIL getLanguage], @"")];
            break;
        default:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            switch ([indexPath row]) {
                case 0:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"asset_tag", [UTIL getLanguage], @"")];
                    [cell.detailTextLabel setText:_inventory.assetTag];
                    if (USER.isProduction) {
                        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    }
                    break;
                case 1:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"item_no", [UTIL getLanguage], @"")];
                    [cell.detailTextLabel setText:_inventory.itemNumber];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    break;
                case 2:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"status", [UTIL getLanguage], @"")];
                    if ([_inventory.status.genericId isEqual: @"2"]) {
                        if (![_inventory.currentClaim.claimNumber isEqual: @""]) {
                            [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@ (%@)", _inventory.status.value, _inventory.currentClaim.claimNumber]];
                        } else {
                            [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@", _inventory.status.value]];
                        }
                    } else {
                        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@", _inventory.status.value]];
                    }
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    break;
                case 3:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"branch", [UTIL getLanguage], @"")];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@ / %@", _inventory.branch.value, _inventory.transitBranch.value]];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    break;
                case 4:
                    // restrict manage
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"manage", [UTIL getLanguage], @"")];
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    break;
            }
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath section]) {
        case 0:
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self changeAssetTag:tableView indexPath:indexPath];
            break;
        default:
            switch ([indexPath row]) {
                case 0: {
                    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                    
                    if (!_receiveModeInventory) {
                        _receiveModeInventory = true;
                        [self onEndFlash:nil];
                        return;
                    }
                    
                    [self changeAssetTag:tableView indexPath:indexPath];
                }
                    break;
                case 4:
                    [self performSegueWithIdentifier:@"showInventory" sender:self];
                    break;
            }
            break;
    }
}

- (void)changeAssetTag:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    if (!USER.isProduction) {
        [ALERT promptWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"are_you_sure_you_want_to_change_the_asset_tag", [UTIL getLanguage], @"") completion:^(BOOL granted) {
            if (granted) {
                [self acceptChangeAssetTag];
            } else {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }];
    }
}

- (void)acceptChangeAssetTag {
    _actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"choose_action", [UTIL getLanguage], @"") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"camera", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        self->_receiveModeInventory = false;
        [self onEndFlash:nil];
        [self flashCell];
        [self openCamera];
    }];
    [_actionSheet addAction:actionItem];
    
    actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"manual", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        self->_receiveModeInventory = false;
        [self onEndFlash:nil];
        [self flashCell];
        [self openManual:@""];
    }];
    [_actionSheet addAction:actionItem];
    
    actionItem = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedStringFromTable(@"external", [UTIL getLanguage], @""), NSLocalizedStringFromTable(@"scanner", [UTIL getLanguage], @"")] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        self->_receiveModeInventory = false;
        [self onEndFlash:nil];
        [self flashCell];
    }];
    [_actionSheet addAction:actionItem];
    
    actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", [UTIL getLanguage], @"") style:UIAlertActionStyleCancel handler:nil];
    [actionItem setValue:[UTIL darkRedColor] forKey:@"titleTextColor"];
    [_actionSheet addAction:actionItem];
    
    if (IS_IPAD()) {
        UIPopoverPresentationController *popoverPresentationController = [_actionSheet popoverPresentationController];
        [popoverPresentationController setBarButtonItem:_actionButton];
        [_actionSheet setModalPresentationStyle:UIModalPresentationPopover];
    }
    
    [self presentViewController:_actionSheet animated:YES completion:nil];
}

- (void)openManual:(NSString *)term {
    UIAlertController *manual = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"manual_scan", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"new_asset_tag", [UTIL getLanguage], @"")  preferredStyle:UIAlertControllerStyleAlert];
    [manual addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"ok", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *term = [[[manual textFields] objectAtIndex:0] text];
        if ([[UTIL trim:term] length] > 2) {
            if ([UTIL.loading isEqual:[NSNumber numberWithInt:0]]) {
                [UTIL showActivity:NSLocalizedStringFromTable(@"scanning", [UTIL getLanguage], @"")];
                [SCANNER performSelector:@selector(executeSearch:) withObject:term afterDelay:0.1f];
            }
        } else {
            [ALERT alertWithHandler:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:@"Fill in more than 2 characters please." completion:^(BOOL granted) {
                if (granted) {
                    [self openManual:term];
                }
            }];
        }
    }]];
    [manual addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", [UTIL getLanguage], @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
        [self onEndFlash:nil];
    }]];
    [manual addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setPlaceholder:NSLocalizedStringFromTable(@"asset_tag", [UTIL getLanguage], @"")];
        [textField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
        [textField setText:term];
    }];
    [self presentViewController:manual animated:YES completion:nil];
}

- (void)openCamera {
    [self performSegueWithIdentifier:@"showCamera" sender:self];
}

- (void)flashCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setAlpha:1.0];
    
    [cell.contentView.layer setBorderColor:[UTIL redColor].CGColor];
    [cell.contentView.layer setBorderWidth:2.0f];
    
    _startTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onStartFlash:) userInfo:nil repeats:YES];
    //_endTimer = [NSTimer scheduledTimerWithTimeInterval:14 target:self selector:@selector(onEndFlash:) userInfo:nil repeats:NO];
}

- (void)onStartFlash:(NSTimer*)theTimer {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    
    [UIView beginAnimations:@"fade out" context:nil];
    [UIView setAnimationDuration:1.0];
    
    if ([[self.tableView cellForRowAtIndexPath:indexPath] alpha] == 1.0) {
        [[self.tableView cellForRowAtIndexPath:indexPath] setAlpha:.1];
    } else {
        [[self.tableView cellForRowAtIndexPath:indexPath] setAlpha:1.0];
    }
    
    [UIView commitAnimations];
}

- (void)onEndFlash:(NSTimer*)theTimer {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    _receiveModeInventory = true;
    
    [UIView beginAnimations:@"fade out" context:nil];
    [UIView setAnimationDuration:1.0];
    
    [cell setAlpha:1.0];
    
    [UIView commitAnimations];
    
    [cell.contentView.layer setBorderColor:[UIColor clearColor].CGColor];
    [cell.contentView.layer setBorderWidth:0.0f];
    
    [_startTimer invalidate];
    _startTimer = nil;
    
    [_endTimer invalidate];
    _endTimer = nil;
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
    
    for (Phase *ph in _claimToIssue.phaseList) {
        go = [[GenericObject alloc] init];
        go.genericId = [NSString stringWithFormat:@"%d", ph.phaseIndx];
        go.value = ph.phaseCode;
        [response addObject:go];
    }
    
    return response;
}

- (GenericObject *)getSelectionObject {
    GenericObject *go = [[GenericObject alloc] init];
    go.genericId = _claimToIssue.transactionPhase;
    go.value = _claimToIssue.transactionPhase;
    
    return go;
}

- (void)setPhaseObject:(GenericObject *)item {
    bool phaseChanged = false;
    
    for (Phase *ph in _claimToIssue.phaseList) {
        if ([ph.phaseCode isEqual: item.value]) {
            _claimToIssue.transactionPhase = ph.phaseCode;
            phaseChanged = true;
        }
    }
    
    if (!phaseChanged) {
        _claimToIssue.transactionPhase = @"";
    }
    
    [self issueToClaim];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showInventory"]) {
        InventoryViewController *child = (InventoryViewController *)[segue destinationViewController];
        [child setInventory:_inventory];
    }
    if ([[segue identifier] isEqualToString:@"showBranches"]) {
        
    }
    if ([[segue identifier] isEqualToString:@"showPhases"]) {
        SelectionViewController *child = (SelectionViewController *)[segue destinationViewController];
        [child setSelection:[self getSelectionArray]];
        [child setSelectionTitle:NSLocalizedStringFromTable(@"phase", [UTIL getLanguage], @"")];
        [child setSelectedObjectType:1];
        [child setSelectedObject:[self getSelectionObject]];
    }
    if ([[segue identifier] isEqualToString:@"showCamera"]) {
        CameraViewController *child = (CameraViewController *)[segue destinationViewController];
        [child setMode:0];
    }
}

- (IBAction)actionPressed:(id)sender {
    [self onEndFlash:nil];
    
    // check if need actions
    if ([_inventory.status.genericId intValue] != 1 && [_inventory.status.genericId intValue] != 2 && [_inventory.status.genericId intValue] != 6 && [_inventory.status.genericId intValue] != 7) {
        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"this_item_has_no_actions", [UTIL getLanguage], @"")];
    } else {
        _actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"choose_action", [UTIL getLanguage], @"") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *actionItem;
        
        switch ([_inventory.status.genericId intValue]) {
            case 1:
            {
                actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"in_transit", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    [self doInTransit];
                }];
                [_actionSheet addAction:actionItem];
                actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"issue_to_job", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    [self doIssueToJob];
                }];
                [_actionSheet addAction:actionItem];
                actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"branch_transfer", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    [self doBranchTransfer];
                }];
                [_actionSheet addAction:actionItem];
            }
                break;
            case 2:
            {
                actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"in_transit", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    [self doInTransit];
                }];
                [_actionSheet addAction:actionItem];
                actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"return_to_branch", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    [self doReturnBranch];
                }];
                [_actionSheet addAction:actionItem];
                /*actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"issue_to_job", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    [self doIssueToJob];
                }];
                [_actionSheet addAction:actionItem];*/
            }
                break;
            case 6:
            {
                actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"receive_item", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    [self doReceiveItem];
                }];
                [_actionSheet addAction:actionItem];
            }
                break;
            case 7:
            {
                actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"issue_to_job", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    [self doIssueToJob];
                }];
                [_actionSheet addAction:actionItem];
                actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"return_to_branch", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    [self doReturnBranch];
                }];
                [_actionSheet addAction:actionItem];
            }
                break;
        }
        
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", [UTIL getLanguage], @"") style:UIAlertActionStyleCancel handler:nil];
        [actionCancel setValue:[UTIL darkRedColor] forKey:@"titleTextColor"];
        
        [_actionSheet addAction:actionCancel];
        
        if (IS_IPAD()) {
            UIPopoverPresentationController *popoverPresentationController = [_actionSheet popoverPresentationController];
            [popoverPresentationController setBarButtonItem:_actionButton];
            [_actionSheet setModalPresentationStyle:UIModalPresentationPopover];
        }
        
        [self presentViewController:_actionSheet animated:YES completion:nil];
    }
}

- (void)doInTransit {
    [ALERT promptWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"are_you_sure_you_want_to_change_the_status_of_this_item", [UTIL getLanguage], @"") completion:^(BOOL granted) {
        if (granted) {
            GenericObject *go = [[GenericObject alloc] init];
            go.code = @"transit";
            
            [UTIL showActivity:NSLocalizedStringFromTable(@"saving", [UTIL getLanguage], @"")];
            [self performSelector:@selector(doTransaction:) withObject:go afterDelay:0.1f];
        }
    }];
}

- (void)doIssueToJob {
    [ALERT promptWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"are_you_sure_you_want_to_change_the_status_of_this_item", [UTIL getLanguage], @"") completion:^(BOOL granted) {
        if (granted) {
            [self performSelector:@selector(doShowClaim) withObject:nil afterDelay:.1f];
        }
    }];
}

- (void)doBranchTransfer {
    [ALERT promptWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"are_you_sure_you_want_to_change_the_status_of_this_item", [UTIL getLanguage], @"") completion:^(BOOL granted) {
        if (granted) {
            [self performSegueWithIdentifier:@"showBranches" sender:self];
        }
    }];
}

- (void)doReturnBranch {
    [ALERT promptWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"are_you_sure_you_want_to_change_the_status_of_this_item", [UTIL getLanguage], @"") completion:^(BOOL granted) {
        if (granted) {
            GenericObject *go = [[GenericObject alloc] init];
            go.code = @"return";
            
            [UTIL showActivity:NSLocalizedStringFromTable(@"saving", [UTIL getLanguage], @"")];
            [self performSelector:@selector(doTransaction:) withObject:go afterDelay:0.1f];
        }
    }];
}

- (void)doShowClaim {
    [self performSegueWithIdentifier:@"showClaims" sender:self];
}

- (void)doReceiveItem {
    [self doReturnBranch]; //todo: discuss this action
}

- (void)receivedClaimToIssue:(NSNotification *)notification {
    id data = [[notification userInfo] valueForKey:@"data"];
    if ([data isKindOfClass:[Claim class]]) {
        _claimToIssue = (Claim *)data;
        _receivedClaim = true;
        //[self performSegueWithIdentifier:@"showPhases" sender:self];
    }
}
/*
- (void)receivedClaimToIssue:(Claim *)parent {
    _claimToIssue = parent;
    
    [self performSegueWithIdentifier:@"showPhases" sender:self];
}
*/
- (void)issueToBranch {
    [UTIL showActivity:NSLocalizedStringFromTable(@"saving", [UTIL getLanguage], @"")];
    [self performSelector:@selector(doTransaction:) withObject:_branchToIssue afterDelay:0.1f];
}

- (void)issueToClaim {
    [UTIL showActivity:NSLocalizedStringFromTable(@"saving", [UTIL getLanguage], @"")];
    [self performSelector:@selector(doTransaction:) withObject:_claimToIssue afterDelay:0.1f];
}

- (void)doTransaction:(NSObject *)parent {
    [TRANSACTIONS commitInventory:parent inventory:_inventory];
    [UTIL hideActivity];
    
    /*[_inventory reload:^(bool result) {
        [self.tableView reloadData];
    }];*/
    [self.navigationController popViewControllerAnimated:YES];
}

@end
