//
//  BatchItemsViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/9/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "BatchItemsViewController.h"
#import "CameraViewController.h"
#import "ErrorsViewController.h"
#import "BatchSearchViewController.h"

@interface BatchItemsViewController ()

@end

@implementation BatchItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedExternalScannerConected:) name:@"externalScannerConected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedExternalScannerDisconnected:) name:@"externalScannerDisconnected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedExternalScannerResponse:) name:@"externalScannerResponse" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(externalScannerItemsResponse:) name:@"externalScannerItemsResponse" object:nil];
    
    [self setTitle:_headerTitle];
    [self reloadItems];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadItems];
}

- (void)reloadItems {
    _items = [[NSMutableArray alloc] init];
    GenericObject *obj = [[GenericObject alloc] init];
    
    switch (_transactionType) {
        case 2:
            obj.code = @"claim";
            obj.genericId = [NSString stringWithFormat:@"%d", _claim.claimIndx];
            obj.parentId = [NSString stringWithFormat:@"%d", _phase.phaseIndx];
            _items = [TRANSACTIONS itemsForType:_transactionType parent:obj];
            break;
        case 4:
            obj.code = _branch.code;
            _items = [TRANSACTIONS itemsForType:_transactionType parent:obj];
            break;
        default:
            _items = [TRANSACTIONS itemsForType:_transactionType parent:obj];
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - External Scanner
- (void)receivedExternalScannerConected:(NSNotification *) notification {
    if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[self class]]) {
        [self.tableView reloadData];
    }
}

- (void)receivedExternalScannerDisconnected:(NSNotification *) notification {
    if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[self class]]) {
        [self.tableView reloadData];
    }
}

- (void)externalScannerItemsResponse:(NSNotification *) notification {
    UIViewController *lastController = [APP_DELEGATE getCurrentScreen];
    UIViewController *prevController = [APP_DELEGATE getPreviousScreen];
    
    if ([lastController isKindOfClass:[self class]] || ([prevController isKindOfClass:[self class]] && [lastController isKindOfClass:[CameraViewController class]]) || [lastController isKindOfClass:[BatchSearchViewController class]]) {
        NSMutableArray *inventories = [[notification userInfo] valueForKey:@"data"];
        
        GenericObject *parentObject = [[GenericObject alloc] init];
        int t_parent = 1;
        switch (_transactionType) {
            case 1: // transit
                parentObject.code = @"transit";
                t_parent = 7;
                break;
            case 2: // claim
                parentObject.code = @"claim";
                parentObject.parentId = [NSString stringWithFormat:@"%d", _phase.phaseIndx];
                parentObject.value = [NSString stringWithFormat:@"%d", _claim.claimIndx];
                t_parent = 2;
                break;
            case 3: // return
                parentObject.code = @"return";
                t_parent = 1;
                break;
            case 4: // branch
                parentObject = _branch;
                t_parent = 6;
                break;
        }
        
        for (Inventory *inv in inventories) {
            //Inventory *inv = [[notification userInfo] valueForKey:@"data"];
            // check statuses
            if ([inv.status.genericId intValue] != t_parent) {
                [TRANSACTIONS append:inv parentObject:parentObject];
            } else {
                [UTIL showToaster:self.view withMessage:NSLocalizedStringFromTable(@"item_already_in_this_status", [UTIL getLanguage], @"")];
            }
        }
        [self refreshTable];
        
        if (_transactionType == 2) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"claimItemsChanged" object:nil userInfo:nil];
        }
    }
}

- (void)receivedExternalScannerResponse:(NSNotification *) notification {
    UIViewController *lastController = [APP_DELEGATE getCurrentScreen];
    UIViewController *prevController = [APP_DELEGATE getPreviousScreen];
    
    if ([lastController isKindOfClass:[self class]] || ([prevController isKindOfClass:[self class]] && [lastController isKindOfClass:[CameraViewController class]])) {
        Inventory *inv = [[notification userInfo] valueForKey:@"data"];
        //genericid
        GenericObject *parentObject = [[GenericObject alloc] init];
        int t_parent = 1;
        switch (_transactionType) {
            case 1: // transit
                parentObject.code = @"transit";
                t_parent = 7;
                break;
            case 2: // claim
                parentObject.code = @"claim";
                parentObject.parentId = [NSString stringWithFormat:@"%d", _phase.phaseIndx];
                parentObject.value = [NSString stringWithFormat:@"%d", _claim.claimIndx];
                t_parent = 2;
                break;
            case 3: // return
                parentObject.code = @"return";
                t_parent = 1;
                break;
            case 4: // branch
                parentObject = _branch;
                t_parent = 6;
                break;
        }
        
        if ([inv.status.genericId intValue] != t_parent) {
            [TRANSACTIONS append:inv parentObject:parentObject];
            [self refreshTable];
            
            if (_transactionType == 2) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"claimItemsChanged" object:nil userInfo:nil];
            }
        } else {
            [UTIL showToaster:self.view withMessage:NSLocalizedStringFromTable(@"item_already_in_this_status", [UTIL getLanguage], @"")];
        }
    }
}

- (void)refreshTable {
    GenericObject *obj = [[GenericObject alloc] init];
    
    switch (_transactionType) {
        case 2:
            obj.genericId = [NSString stringWithFormat:@"%d", _claim.claimIndx];
            obj.parentId = [NSString stringWithFormat:@"%d", _phase.phaseIndx];
            _items = [TRANSACTIONS itemsForType:_transactionType parent:obj];
            break;
        case 4:
            obj.code = _branch.code;
            _items = [TRANSACTIONS itemsForType:_transactionType parent:obj];
            break;
        default:
            _items = [TRANSACTIONS itemsForType:_transactionType parent:obj];
            break;
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = NSLocalizedStringFromTable(@"no_external_scanner", [UTIL getLanguage], @"");
    if (SCANNER.isConnected) {
        title = NSLocalizedStringFromTable(@"external_scanner_connected", [UTIL getLanguage], @"");
    }
    if (section != 1) {
        title = @"";
    }
    
    return title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    if ([indexPath section] == 2) {
        height = 72.0f;
    }
    
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSInteger numberOfSections = 3;
    if (_items.count > 0) {
        numberOfSections = 4;
    }
    
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger numberOfRows = 0;
    switch (section) {
        case 0:
            numberOfRows = 1;
            break;
        case 1:
            numberOfRows = 2;
            break;
        case 2:
            numberOfRows = _items.count;
            break;
        default:
            numberOfRows = 2;
            break;
    }
    
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 44.0f;
    if (section == 0) {
        height = .1f;
    }
    
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, .1f)];
    if (section == 0) {
        [view sizeToFit];
        return view;
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    TransactionItem *ti;
    
    switch ([indexPath section]) {
        case 0:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            [cell.textLabel setText:[NSString stringWithFormat:@"Batch scan to %@", _headerTitle]];
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell setBackgroundColor:[UTIL pinkColor]];
            break;
        case 1:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            switch ([indexPath row]) {
                case 0:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"camera", [UTIL getLanguage], @"")];
                    break;
                case 1:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"manual", [UTIL getLanguage], @"")];
                    break;
            }
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            break;
        case 2:
        {
            ti = (TransactionItem *)[_items objectAtIndex:[indexPath row]];
            
            [cell.textLabel setText:[NSString stringWithFormat:@"%@ - %@",ti.inventory.itemClass,ti.inventory.itemModel]];
            [cell.detailTextLabel setNumberOfLines:4];
            NSString *details = [NSString stringWithFormat:@"%@: %@, %@: %@\n%@: %@",NSLocalizedStringFromTable(@"item", [UTIL getLanguage], @""), ti.inventory.itemNumber, NSLocalizedStringFromTable(@"tag", [UTIL getLanguage], @""), ti.inventory.assetTag, NSLocalizedStringFromTable(@"status", [UTIL getLanguage], @""), ti.inventory.status.value];
            if (![[UTIL trim:ti.inventory.transitBranch.value] isEqualToString:@""]) {
                details = [NSString stringWithFormat:@"%@ [%@]", details, ti.inventory.transitBranch.value];
            }
            [cell.detailTextLabel setText:details];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
            break;
        default:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            switch ([indexPath row]) {
                case 0:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"commit", [UTIL getLanguage], @"")];
                    [cell setBackgroundColor:[UTIL greenColor]];
                    break;
                case 1:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"revert", [UTIL getLanguage], @"")];
                    [cell setBackgroundColor:[UTIL redColor]];
                    break;
            }
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
            [cell.textLabel setTextColor:[UIColor whiteColor]];
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 1) {
        if ([indexPath row] == 0) {
            [self performSegueWithIdentifier:@"showCamera" sender:self];
        } else {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self openManual:@""];
        }
    } else {
        if ([indexPath section] == 3) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            if ([indexPath row] == 0) {
                [ALERT promptWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"do_you_want_to_commit_all_items", [UTIL getLanguage], @"") completion:^(BOOL granted) {
                    if (granted) {
                        GenericObject *parentObject = [[GenericObject alloc] init];
                        switch (self->_transactionType) {
                            case 1: // transit
                                parentObject.code = @"transit";
                                break;
                            case 2: // claim
                                parentObject.code = @"claim";
                                parentObject.value = [NSString stringWithFormat:@"%d", self->_claim.claimIndx];
                                parentObject.parentId = [NSString stringWithFormat:@"%d", self->_phase.phaseIndx];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"claimItemsChanged" object:nil userInfo:nil];
                                break;
                            case 3: // return
                                parentObject.code = @"return";
                                break;
                            case 4: // branch
                                parentObject = self->_branch;
                                break;
                        }
                        
                        [TRANSACTIONS commit:parentObject completion:^(NSMutableArray *result) {
                            if (result.count > 0) {
                                ErrorsViewController *errorsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"errorsView"];
                                [errorsViewController setErrors:result];
                                
                                UINavigationController *navController = [UTIL getErrorNavigationController:errorsViewController];
                                
                                [self.navigationController presentViewController:navController animated:YES completion:^ {
                                    [self.tabBarController.tabBar setHidden:YES];
                                }];
                            } else {
                                [self reloadItems];
                                [self.tableView reloadData];
                            }
                        }];
                    }
                }];
            } else {
                [ALERT promptWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"do_you_want_to_revert_all_items", [UTIL getLanguage], @"") completion:^(BOOL granted) {
                    if (granted) {
                        switch (self->_transactionType) {
                            case 1: // transit
                                [TRANSACTIONS transitClean];
                                break;
                            case 2: // claim
                                [TRANSACTIONS claimClean:self->_claim.claimIndx];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"claimItemsChanged" object:nil userInfo:nil];
                                break;
                            case 3: // return
                                [TRANSACTIONS returnClean];
                                break;
                            case 4: // branch
                                [TRANSACTIONS branchClean:self->_branch.code];
                                break;
                        }
                        [self reloadItems];
                        [self.tableView reloadData];
                    }
                }];
            }
        }
    }
}

- (void)openManual:(NSString *)term {
    UIAlertController *manual = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"manual_scan", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"search_equipment_term", [UTIL getLanguage], @"")  preferredStyle:UIAlertControllerStyleAlert];
    [manual addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"search", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *term = [[[manual textFields] objectAtIndex:0] text];
        if ([[UTIL trim:term] length] > 2) {
            //[SCANNER executeSearch:term];
            if ([UTIL.loading isEqual:[NSNumber numberWithInt:0]]) {
                [UTIL showActivity:NSLocalizedStringFromTable(@"scanning", [UTIL getLanguage], @"")];
                [self performSelector:@selector(doSearch:) withObject:term afterDelay:0.1f];
            }
        } else {
            //[ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:@"Fill in more than 2 characters please."];
            [ALERT alertWithHandler:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:@"Fill in more than 2 characters please." completion:^(BOOL granted) {
                if (granted) {
                    [self openManual:term];
                }
            }];
        }
    }]];
    [manual addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", [UTIL getLanguage], @"") style:UIAlertActionStyleCancel handler:nil]];
    [manual addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setPlaceholder:NSLocalizedStringFromTable(@"keyword", [UTIL getLanguage], @"")];
        [textField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
        [textField setText:term];
    }];
    [self presentViewController:manual animated:YES completion:nil];
}

- (void)doSearch:(NSString *)term {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    [API findItem:USER.sessionId regionId:USER.regionId branchName:@"" searchString:term completion:^(NSMutableArray *result) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            [UTIL hideActivity];
            
            NSString *error = @"";
            if ([result valueForKey:@"error"]) {
                error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
            }
            
            if ([error isEqualToString: @""]) {
                NSMutableArray *responseData = [result valueForKey:@"findItemResult"];
                if (![responseData isKindOfClass:[NSNull class]]) {
                    if ([responseData count] > 0) {
                        if (responseData.count == 1) {
                            for (id item in responseData) {
                                Inventory *inventory = [[Inventory alloc] init];
                                [inventory initWithData:item];
                                
                                [items addObject:inventory];
                            }
                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:items forKey:@"data"];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"externalScannerItemsResponse" object:nil userInfo:userInfo];
                        } else {
                            self->_searchedItems = [[NSMutableArray alloc] init];
                            for (id item in responseData) {
                                Inventory *inventory = [[Inventory alloc] init];
                                [inventory initWithData:item];
                                
                                [self->_searchedItems addObject:inventory];
                            }
                            [self performSegueWithIdentifier:@"showBatchSearch" sender:self];
                        }
                    } else {
                        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"nothing_found", [UTIL getLanguage], @"")];
                    }
                } else {
                    [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"nothing_found", [UTIL getLanguage], @"")];
                }
            } else {
                [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:error];
            }
        });
    }];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if ([indexPath section] == 2) {
        return YES;
    } else {
        return NO;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [ALERT promptWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"are_you_sure_you_want_to_remove_this_item", [UTIL getLanguage], @"") completion:^(BOOL granted) {
            if (granted) {
                TransactionItem *ti = (TransactionItem *)[self->_items objectAtIndex:[indexPath row]];
                [TRANSACTIONS removeInventory:ti.inventory.inventoryId];
                
                [self reloadItems];
                [self refreshTable];
            }
        }];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showCamera"]) {
        CameraViewController *child = (CameraViewController *)[segue destinationViewController];
        [child setMode:1];
    }
    if ([[segue identifier] isEqualToString:@"showBatchSearch"]) {
        BatchSearchViewController *child = (BatchSearchViewController *)[segue destinationViewController];
        [child setItems:_searchedItems];
    }
}

@end
