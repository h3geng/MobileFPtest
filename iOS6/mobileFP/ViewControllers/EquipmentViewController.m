//
//  EquipmentViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 9/27/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "EquipmentViewController.h"
#import "EquipmentDetailsViewController.h"
#import "CameraViewController.h"
#import "InventoryViewController.h"
#import "BatchViewController.h"

@interface EquipmentViewController ()

@end

@implementation EquipmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedStringFromTable(@"equipment", [UTIL getLanguage], @"")];
    
    [_equipmentSearchBar setDelegate:self];
    
    _items = [[NSMutableArray alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedExternalScannerConected:) name:@"externalScannerConected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedExternalScannerDisconnected:) name:@"externalScannerDisconnected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedExternalScannerResponse:) name:@"externalScannerResponse" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setTitle:NSLocalizedStringFromTable(@"equipment", [UTIL getLanguage], @"")];
    [self localize];
    
    [self.tableView reloadData];
    
    if (![_equipmentSearchBar.text isEqual: @""]) {
        [UTIL showActivity:NSLocalizedStringFromTable(@"searching", [UTIL getLanguage], @"")];
        [self performSelector:@selector(search:) withObject:[_equipmentSearchBar text] afterDelay:0.1f];
    }
}

- (void)localize {
    [_equipmentSearchBar setPlaceholder:NSLocalizedStringFromTable(@"search", [UTIL getLanguage], @"")];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    [UTIL showActivity:NSLocalizedStringFromTable(@"searching", [UTIL getLanguage], @"")];
    [self performSelector:@selector(search:) withObject:[searchBar text] afterDelay:0.1f];
}

- (void)search:(NSString *)term {
    _items = [[NSMutableArray alloc] init];
    
    [API findItem:USER.sessionId regionId:USER.regionId branchName:@"" searchString:term completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqualToString: @""]) {
            NSMutableArray *responseData = [result valueForKey:@"findItemResult"];
            if (![responseData isKindOfClass:[NSNull class]]) {
                if ([responseData count] > 0) {
                    for (id item in responseData) {
                        Inventory *inventory = [[Inventory alloc] init];
                        [inventory initWithData:item];
                        
                        [self->_items addObject:inventory];
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
        
        [self.tableView reloadData];
    }];
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

- (void)receivedExternalScannerResponse:(NSNotification *) notification {
    UIViewController *lastController = [APP_DELEGATE getCurrentScreen];
    UIViewController *prevController = [APP_DELEGATE getPreviousScreen];
    
    if ([lastController isKindOfClass:[self class]] || ([prevController isKindOfClass:[self class]] && [lastController isKindOfClass:[CameraViewController class]])) {
        Inventory *inv = [[notification userInfo] valueForKey:@"data"];
        _items = [[NSMutableArray alloc] init];
        [_items addObject:inv];
        
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = NSLocalizedStringFromTable(@"no_external_scanner", [UTIL getLanguage], @"");
    if (SCANNER.isConnected) {
        title = NSLocalizedStringFromTable(@"external_scanner_connected", [UTIL getLanguage], @"");
    }
    if (section == 1) {
        title = @"";
    }
    
    return title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger numberOfRows = 2;
    if (section == 1) {
        numberOfRows = _items.count;
    }
    
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    if ([indexPath section] == 1) {
        height = 72.0f;
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    Inventory *inventory;
    NSString *inventoryDetails;
    
    switch ([indexPath section]) {
        case 0:
            switch ([indexPath row]) {
                case 0:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"camera", [UTIL getLanguage], @"")];
                    break;
                default:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"batch_scan", [UTIL getLanguage], @"")];
                    break;
            }
            break;
        default:
            inventory = (Inventory *)[_items objectAtIndex:[indexPath row]];
            
            [cell.textLabel setText:[NSString stringWithFormat:@"%@ - %@",inventory.itemClass,inventory.itemModel]];
            [cell.detailTextLabel setNumberOfLines:4];
            inventoryDetails = [NSString stringWithFormat:@"%@: %@, %@: %@\n%@: %@", NSLocalizedStringFromTable(@"item", [UTIL getLanguage], @""), inventory.itemNumber, NSLocalizedStringFromTable(@"tag", [UTIL getLanguage], @""),inventory.assetTag, NSLocalizedStringFromTable(@"status", [UTIL getLanguage], @""), inventory.status.value];
            if (![[UTIL trim:inventory.transitBranch.value] isEqualToString:@""]) {
                inventoryDetails = [NSString stringWithFormat:@"%@ [%@]", inventoryDetails, inventory.transitBranch.value];
            }
            [cell.detailTextLabel setText:inventoryDetails];
            break;
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath section]) {
        case 0:
            switch ([indexPath row]) {
                case 0:
                    [self performSegueWithIdentifier:@"showCamera" sender:self];
                    break;
                default:
                    [self performSegueWithIdentifier:@"showBatch" sender:self];
                    break;
            }
            break;
        default:
            _selectedInventory = (Inventory *)[_items objectAtIndex:[indexPath row]];
            [self performSegueWithIdentifier:@"showDetails" sender:self];
            break;
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"showDetails"]) {
        EquipmentDetailsViewController *child = (EquipmentDetailsViewController *)[segue destinationViewController];
        [child setInventory:_selectedInventory];
    }
    if ([[segue identifier] isEqualToString:@"showInventoryManage"]) {
        InventoryViewController *child = (InventoryViewController *)[segue destinationViewController];
        [child setInventory:[[Inventory alloc] init]];
    }
    if ([[segue identifier] isEqualToString:@"showCamera"]) {
        CameraViewController *child = (CameraViewController *)[segue destinationViewController];
        [child setMode:0];
    }
    if ([[segue identifier] isEqualToString:@"showBatch"]) {
        BatchViewController *child = (BatchViewController *)[segue destinationViewController];
        [child setSimpleMode:false];
    }
}

- (IBAction)actionsPressed:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"choose_action", [UTIL getLanguage], @"") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionItem;
    
    if (!USER.isProduction) {
        actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"add_new", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self performSegueWithIdentifier:@"showInventoryManage" sender:self];
        }];
        [actionSheet addAction:actionItem];
    }
    
    actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"clear_search_results", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self clearSearchResults];
    }];
    [actionSheet addAction:actionItem];
    
    actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", [UTIL getLanguage], @"") style:UIAlertActionStyleCancel handler:nil];
    [actionItem setValue:[UTIL darkRedColor] forKey:@"titleTextColor"];
    [actionSheet addAction:actionItem];
    
    if (IS_IPAD()) {
        UIPopoverPresentationController *popoverPresentationController = [actionSheet popoverPresentationController];
        [popoverPresentationController setBarButtonItem:_actionsButton];
        [actionSheet setModalPresentationStyle:UIModalPresentationPopover];
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)clearSearchResults {
    [ALERT promptWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"are_you_sure_you_want_to_clear_search_results", [UTIL getLanguage], @"") completion:^(BOOL granted) {
        if (granted) {
            [self->_equipmentSearchBar setText:@""];
            
            self->_items = [[NSMutableArray alloc] init];
            [self.tableView reloadData];
        }
    }];
}

@end
