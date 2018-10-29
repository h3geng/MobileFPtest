//
//  ClaimEquipmentViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/6/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "ClaimEquipmentViewController.h"
#import "SelectionViewController.h"
#import "EquipmentDetailsViewController.h"
#import "CameraViewController.h"

@interface ClaimEquipmentViewController ()

@end

@implementation ClaimEquipmentViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.claim = [[Claim alloc] init];
        self.receivedInventory = [[Inventory alloc] init];
        self.selectedInventory = [[Inventory alloc] init];
        self.selectedPhase = [[Phase alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedExternalScannerResponse:) name:@"externalScannerResponse" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(claimItemsChanged:) name:@"claimItemsChanged" object:nil];
    
    [self setTitle:NSLocalizedStringFromTable(@"equipment", [UTIL getLanguage], @"")];
    
    if (_claim.phaseList.count == 1) {
        _selectedPhase = [_claim.phaseList objectAtIndex:0];
    } else {
        _selectedPhase = [[Phase alloc] init];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (NSMutableArray *)inventoriesForPhase:(NSString *)phaseCode {
    NSMutableArray *response = [[NSMutableArray alloc] init];
    
    for (Inventory *inv in _claim.inventoryList) {
        if ([inv.currentPhase isEqual: phaseCode] || [phaseCode isEqual: @""]) {
            [response addObject:inv];
        }
    }
    
    for (TransactionItem *trans in [TRANSACTIONS claimItems:_claim.claimIndx]) {
        Inventory *inv = (Inventory *)trans.inventory;
        if ([inv.currentPhase isEqual: phaseCode] || [phaseCode isEqual: @""]) {
            [response addObject:inv];
        }
    }
    
    return response;
}

- (void)receivedExternalScannerResponse:(NSNotification *) notification {
    UIViewController *lastController = [APP_DELEGATE getCurrentScreen];
    UIViewController *prevController = [APP_DELEGATE getPreviousScreen];
    
    if ([lastController isKindOfClass:[self class]] || ([prevController isKindOfClass:[self class]] && [lastController isKindOfClass:[CameraViewController class]])) {
        Inventory *inv = [[notification userInfo] valueForKey:@"data"];
        inv.committed = false;
        inv.currentPhase = _selectedPhase.phaseCode;
        
        GenericObject *parentObject = [[GenericObject alloc] init];
        parentObject.code = @"claim";
        parentObject.genericId = [NSString stringWithFormat:@"%d", _selectedPhase.phaseIndx];
        parentObject.value = [NSString stringWithFormat:@"%d", _claim.claimIndx];
        
        [TRANSACTIONS append:inv parentObject:parentObject];
        [self.tableView reloadData];
    }
}

- (void)claimItemsChanged:(NSNotification *) notification {
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    if ([indexPath section] == 1) {
        height = 72.0f;
    }
    
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger numberOfRows = 1;
    if (section == 1) {
        numberOfRows = [self inventoriesForPhase:_selectedPhase.phaseCode].count;
    }
    
    return numberOfRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *title = @"";
    if ([self inventoriesForPhase:_selectedPhase.phaseCode].count == 0 && section == 0) {
        title = NSLocalizedStringFromTable(@"nothing_found", [UTIL getLanguage], @"");
    }
    
    if ([TRANSACTIONS claimItems:_claim.claimIndx].count > 0 && section == 1) {
        title = NSLocalizedStringFromTable(@"inventory_with_pink_background_is_not_committed_swipe_to_remove", [UTIL getLanguage], @"");
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    Inventory *inventory;
    
    switch ([indexPath section]) {
        case 0:
            [cell.textLabel setText:NSLocalizedStringFromTable(@"phase", [UTIL getLanguage], @"")];
            if (_selectedPhase.phaseIndx == 0) {
                [cell.detailTextLabel setText:NSLocalizedStringFromTable(@"all", [UTIL getLanguage], @"")];
            } else {
                [cell.detailTextLabel setText:_selectedPhase.phaseCode];
            }
            break;
        default:
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
            
            inventory = [[self inventoriesForPhase:_selectedPhase.phaseCode] objectAtIndex:[indexPath row]];
            
            [cell.textLabel setText:[NSString stringWithFormat:@"%@ - %@",inventory.itemClass,inventory.itemModel]];
            [cell.detailTextLabel setNumberOfLines:-1];
            NSString *details = [NSString stringWithFormat:@"%@: %@, %@: %@", NSLocalizedStringFromTable(@"item", [UTIL getLanguage], @""), inventory.itemNumber, NSLocalizedStringFromTable(@"tag", [UTIL getLanguage], @""),inventory.assetTag];
            if (![[UTIL trim:inventory.transitBranch.value] isEqualToString:@""]) {
                details = [NSString stringWithFormat:@"%@\n%@: %@", details, NSLocalizedStringFromTable(@"current_branch", [UTIL getLanguage], @""), inventory.transitBranch.value];
            }
            [cell.detailTextLabel setText:details];
            if (!inventory.committed) {
                [cell setBackgroundColor:[UTIL lightRedColor]];
            }
        }
            break;
    }
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        [self performSegueWithIdentifier:@"showSelection" sender:self];
    } else {
        _selectedInventory = [[self inventoriesForPhase:_selectedPhase.phaseCode] objectAtIndex:[indexPath row]];
        [self performSegueWithIdentifier:@"showEquipment" sender:self];
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if ([indexPath section] == 1) {
        NSMutableArray *arr = [self inventoriesForPhase:_selectedPhase.phaseCode];
        if (arr.count > 0) {
            Inventory *inventory = [[self inventoriesForPhase:_selectedPhase.phaseCode] objectAtIndex:[indexPath row]];
            if (inventory.committed) {
                return NO;
            } else {
                return YES;
            }
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [ALERT promptWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"do_you_want_to_remove_this_item", [UTIL getLanguage], @"") completion:^(BOOL granted) {
            if (granted) {
                Inventory *inventory = [[self inventoriesForPhase:self->_selectedPhase.phaseCode] objectAtIndex:[indexPath row]];
                [TRANSACTIONS removeInventory:inventory.inventoryId];
                
                [self.tableView reloadData];
            } else {
                [self setEditing:NO animated:YES];
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
    go.genericId = [NSString stringWithFormat:@"%d", _selectedPhase.phaseIndx];
    go.value = _selectedPhase.phaseCode;

    return go;
}

- (void)setSelectionObject:(GenericObject *)item {
    bool phaseChanged = false;
    
    for (Phase *ph in _claim.phaseList) {
        if ([ph.phaseCode isEqual: item.value]) {
            _selectedPhase = ph;
            phaseChanged = true;
        }
    }
    
    if (!phaseChanged) {
        _selectedPhase = [[Phase alloc] init];
    }
    [self.tableView reloadData];
}

- (IBAction)addPressed:(id)sender {
    if ([_selectedPhase.phaseCode isEqualToString:@""]) {
        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"select_a_phase", [UTIL getLanguage], @"")];
    } else {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"choose_method", [UTIL getLanguage], @"") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *actionManual = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"manual", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self openManual];
        }];
        
        UIAlertAction *actionCamera = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"camera", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self performSegueWithIdentifier:@"showCamera" sender:self];
        }];
        
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", [UTIL getLanguage], @"") style:UIAlertActionStyleCancel handler:nil];
        [actionCancel setValue:[UTIL darkRedColor] forKey:@"titleTextColor"];
        
        [actionSheet addAction:actionManual];
        [actionSheet addAction:actionCamera];
        [actionSheet addAction:actionCancel];
        
        if (IS_IPAD()) {
            UIPopoverPresentationController *popoverPresentationController = [actionSheet popoverPresentationController];
            popoverPresentationController.barButtonItem = _actionsButton;
            [actionSheet setModalPresentationStyle:UIModalPresentationPopover];
        }
        
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
}

- (void)openManual {
    UIAlertController *manual = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"manual_scan", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"fill_in_asset_tag", [UTIL getLanguage], @"")  preferredStyle:UIAlertControllerStyleAlert];
    [manual addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"search", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *term = [[[manual textFields] objectAtIndex:0] text];
        if ([[UTIL trim:term] length] > 0) {
            [SCANNER executeSearch:term];
        }
    }]];
    [manual addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setPlaceholder:NSLocalizedStringFromTable(@"asset_tag", [UTIL getLanguage], @"")];
        [textField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    }];
    [self presentViewController:manual animated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showSelection"]) {
        SelectionViewController *child = (SelectionViewController *)[segue destinationViewController];
        [child setSelection:[self getSelectionArray]];
        [child setSelectionTitle:NSLocalizedStringFromTable(@"phase", [UTIL getLanguage], @"")];
        [child setSelectedObjectType:1];
        [child setSelectedObject:[self getSelectionObject]];
    }
    
    if ([[segue identifier] isEqualToString:@"showEquipment"]) {
        EquipmentDetailsViewController *child = (EquipmentDetailsViewController *)[segue destinationViewController];
        [child setInventory:_selectedInventory];
        [child setAllowActions:false];
    }
    
    if ([[segue identifier] isEqualToString:@"showCamera"]) {
        CameraViewController *child = (CameraViewController *)[segue destinationViewController];
        [child setMode:0];
    }
}

@end
