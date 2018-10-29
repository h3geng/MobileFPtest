//
//  InventoryViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/11/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "InventoryViewController.h"
#import "SelectionViewController.h"

@interface InventoryViewController ()

@end

@implementation InventoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setTitle:NSLocalizedStringFromTable(@"inventory", [UTIL getLanguage], @"")];
    [_activeSwitcher addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    [_dateTextField setTintColor:[UIColor clearColor]];
    [_dateTextField setInputView:_defaultDatePicker];
    [self setUpAccessoryView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedExternalScannerResponse:) name:@"externalScannerResponse" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doChangeAssetTag:) name:@"changeAssetTag" object:nil];
    
    _itemDuplicate = false;
    [self loadDefaults];
}

- (void)loadDefaults {
    _selectedClass = [CLASSES getClassByName:_inventory.itemClass];
    _selectedModel = [MODELS getModelByName:_inventory.itemModel];
    _selectedHome = _inventory.branch;
    _selectedCurrent = _inventory.transitBranch;
    _selectedStatus = _inventory.status;
    _selectedJobCost = _inventory.jobCostCat;
    
    if ([_selectedJobCost.genericId isEqual: @"0"]) {
        _selectedJobCost.genericId = @"";
    }
    
    [_inventory setPurchaseDate:[NSDate date]];
    [_inventory setPurchasePrice:0];
    [_inventory setActive:[_activeSwitcher isOn]];
    
    if ([_inventory.itemNumber isEqual: @""]) {
        _inventory.itemNumber = _inventory.assetTag;
    }
    
    _selection = [[NSMutableArray alloc] init];
    _selectionTitle = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self localize];
    [self fillData];
}

- (void)fillData {
    [_classDetailLabel setText:_selectedClass.value];
    [_inventory setItemClass:_selectedClass.value];
    
    [_modelDetailLabel setText:_selectedModel.value];
    [_inventory setItemModel:_selectedModel.value];
    
    [_tagTextField setText:_inventory.assetTag];
    [_itemTextField setText:_inventory.itemNumber];
    [_serialTextField setText:_inventory.serialNumber];
    [_dateTextField setText:[_dateFormatter stringFromDate:_inventory.purchaseDate]];
    [_vendorTextField setText:_inventory.vendor];
    [_priceTextField setText:[NSString stringWithFormat:@"%.2f", _inventory.purchasePrice]];
    [_lifeCycleTextField setText:_inventory.lifeCycle];
    
    [_homeDetailLabel setText:_selectedHome.value];
    [_inventory setBranch:_selectedHome];
    
    [_currentDetailLabel setText:_selectedCurrent.value];
    [_inventory setTransitBranch:_selectedCurrent];
    
    [_statusDetailLabel setText:_selectedStatus.value];
    [_inventory setStatus:_selectedStatus];
    
    [_jobCostDetailLabel setText:_selectedJobCost.genericId];
    [_inventory setJobCostCat:_selectedJobCost];
    
    [_activeSwitcher setOn:_inventory.active];
}

- (void)setState:(id)sender {
    [_inventory setActive:[sender isOn]];
}

- (void)localize {
    [_classLabel setText:[NSString stringWithFormat:@"%@ *", NSLocalizedStringFromTable(@"class", [UTIL getLanguage], @"")]];
    [_modelLabel setText:[NSString stringWithFormat:@"%@ *", NSLocalizedStringFromTable(@"model", [UTIL getLanguage], @"")]];
    [_tagLabel setText:[NSString stringWithFormat:@"%@ *", NSLocalizedStringFromTable(@"asset_tag", [UTIL getLanguage], @"")]];
    [_itemLabel setText:[NSString stringWithFormat:@"%@ *", NSLocalizedStringFromTable(@"item_no", [UTIL getLanguage], @"")]];
    [_serialLabel setText:[NSString stringWithFormat:@"%@ *", NSLocalizedStringFromTable(@"serial_no", [UTIL getLanguage], @"")]];
    [_dateLabel setText:NSLocalizedStringFromTable(@"purchase_date", [UTIL getLanguage], @"")];
    [_vendorLabel setText:NSLocalizedStringFromTable(@"vendor", [UTIL getLanguage], @"")];
    [_priceLabel setText:NSLocalizedStringFromTable(@"purchase_price", [UTIL getLanguage], @"")];
    [_lifeCycleLabel setText:NSLocalizedStringFromTable(@"life_cycle", [UTIL getLanguage], @"")];
    [_homeLabel setText:[NSString stringWithFormat:@"%@ *", NSLocalizedStringFromTable(@"home_branch", [UTIL getLanguage], @"")]];
    [_currentLabel setText:NSLocalizedStringFromTable(@"current_branch", [UTIL getLanguage], @"")];
    [_statusLabel setText:[NSString stringWithFormat:@"%@ *", NSLocalizedStringFromTable(@"status", [UTIL getLanguage], @"")]];
    [_jobCostLabel setText:[NSString stringWithFormat:@"%@ *", NSLocalizedStringFromTable(@"jobcostcats", [UTIL getLanguage], @"")]];
    [_activeLabel setText:NSLocalizedStringFromTable(@"active", [UTIL getLanguage], @"")];
}

- (void)setUpAccessoryView {
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    keyboardToolbar.tintColor = [UTIL darkBlueColor];
    
    UIBarButtonItem *flexibleSpacebutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dateSelected:)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(hideDatePicker:)];
    
    [keyboardToolbar setItems:[NSArray arrayWithObjects:cancelButton, flexibleSpacebutton, doneButton, nil] animated:NO];
    if (_inventory.purchaseDate) {
        [_defaultDatePicker setDate:_inventory.purchaseDate];
    }
    _dateTextField.inputAccessoryView = keyboardToolbar;
}

- (void)hideDatePicker:(id)sender {
    [_dateTextField resignFirstResponder];
}

- (void)dateSelected:(id)sender {
    NSDate *date = _defaultDatePicker.date;
    [_inventory setPurchaseDate:date];
    [_dateTextField setText:[_dateFormatter stringFromDate:date]];
    
    [_vendorTextField becomeFirstResponder];
}

#pragma mark - TextField Delegates
- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch ([textField tag]) {
        case 3:
            [_inventory setAssetTag:[textField text]];
            break;
        case 4:
            [_inventory setItemNumber:[textField text]];
            break;
        case 5:
            [_inventory setSerialNumber:[textField text]];
            break;
        case 7:
            [_inventory setVendor:[textField text]];
            break;
        case 8:
            @try {
                [_inventory setPurchasePrice:[[textField text] doubleValue]];
            }
            @catch (NSException *exception) {
                [_inventory setPurchasePrice:0];
            }
            break;
        case 9:
            [_inventory setLifeCycle:[textField text]];
            break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    switch ([textField tag]) {
        case 3:
            return [_itemTextField becomeFirstResponder];
            break;
        case 4:
            return [_serialTextField becomeFirstResponder];
            break;
        case 5:
            return [_dateTextField becomeFirstResponder];
            break;
        case 6:
            return [_vendorTextField becomeFirstResponder];
            break;
        case 7:
            return [_priceTextField becomeFirstResponder];
            break;
        case 8:
            return [_lifeCycleTextField becomeFirstResponder];
            break;
        default:
            return [textField resignFirstResponder];
            break;
    }
}

- (void)receivedExternalScannerResponse:(NSNotification *) notification {
    id receivedData = [[notification userInfo] valueForKey:@"data"];
    if ([receivedData isKindOfClass:[Inventory class]]) {
        _inventory = (Inventory *)receivedData;
        
        if (_inventory.inventoryId > 0) {
            _selectedClass = [CLASSES getClassByName:_inventory.itemClass];
            _selectedModel = [MODELS getModelByName:_inventory.itemModel];
            _selectedHome = _inventory.branch;
            _selectedCurrent = _inventory.transitBranch;
            _selectedStatus = _inventory.status;
            _selectedJobCost = _inventory.jobCostCat;
            
            [self fillData];
        }
        [_tagTextField setText:_inventory.assetTag];
    } else {
        if (_serialTextField.isFirstResponder) {
            _inventory.serialNumber = (NSString *)receivedData;
            [_serialTextField setText:_inventory.serialNumber];
        } else {
            if (_itemDuplicate) {
                [_inventory setAssetTag:(NSString *)receivedData];
                [_inventory setItemNumber:_inventory.assetTag];
                
                [_tagTextField setText:(NSString *)receivedData];
                [_itemTextField setText:_inventory.itemNumber];
            } else {
                [_activeSwitcher setOn:false];
                
                _inventory = [[Inventory alloc] init];
                [_inventory setAssetTag:(NSString *)receivedData];
                [_inventory setItemNumber:_inventory.assetTag];
                [_inventory setPurchaseDate:[NSDate date]];
                [_inventory setPurchasePrice:0];
                [_inventory setActive:[_activeSwitcher isOn]];
                
                [self loadDefaults];
                [self fillData];
                [_tagTextField setText:(NSString *)receivedData];
                [_itemTextField setText:_inventory.itemNumber];
            }
            
            [_serialTextField becomeFirstResponder];
        }
    }
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger numberOfRows = 1;
    if (section == 1) {
        numberOfRows = 14;
    }
    
    return numberOfRows;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath section]) {
        case 0:
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self changeAssetTag:tableView indexPath:indexPath];
            break;
        default:
            switch ([indexPath row]) {
                case 0:
                    _selection = [CLASSES items];
                    _selectionTitle = NSLocalizedStringFromTable(@"class", [UTIL getLanguage], @"");
                    _selectedObjectType = 1;
                    _selectedObject = _selectedClass;
                    [self performSegueWithIdentifier:@"showSelection" sender:self];
                    break;
                case 1:
                    if (![_selectedClass.genericId isEqual: @"0"]) {
                        _selection = [MODELS getModelsByClassId:[_selectedClass.genericId intValue]];
                    } else {
                        _selection = [[NSMutableArray alloc] init]; // if no class selected
                    }
                    _selectionTitle = NSLocalizedStringFromTable(@"model", [UTIL getLanguage], @"");
                    _selectedObjectType = 2;
                    _selectedObject = _selectedModel;
                    [self performSegueWithIdentifier:@"showSelection" sender:self];
                    break;
                case 5:
                    [_dateTextField becomeFirstResponder];
                    break;
                case 9:
                    _selection = [BRANCHES items];
                    _selectionTitle = NSLocalizedStringFromTable(@"branch", [UTIL getLanguage], @"");
                    _selectedObjectType = 3;
                    _selectedObject = _selectedHome;
                    [self performSegueWithIdentifier:@"showSelection" sender:self];
                    break;
                case 10:
                    _selection = [BRANCHES items];
                    _selectionTitle = NSLocalizedStringFromTable(@"branch", [UTIL getLanguage], @"");
                    _selectedObjectType = 4;
                    _selectedObject = _selectedCurrent;
                    [self performSegueWithIdentifier:@"showSelection" sender:self];
                    break;
                case 11:
                    _selection = [STATUSES restrictedItems];
                    _selectionTitle = NSLocalizedStringFromTable(@"status", [UTIL getLanguage], @"");
                    _selectedObjectType = 5;
                    _selectedObject = _selectedStatus;
                    [self performSegueWithIdentifier:@"showSelection" sender:self];
                    break;
                case 12:
                    _selection = [JOBCOSTCATS items];
                    _selectionTitle = NSLocalizedStringFromTable(@"jobcostcats", [UTIL getLanguage], @"");
                    _selectedObjectType = 6;
                    _selectedObject = _selectedJobCost;
                    [self performSegueWithIdentifier:@"showSelection" sender:self];
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

- (void)doChangeAssetTag:(NSNotification *)notification {
    NSString *receivedTag = [[notification userInfo] valueForKey:@"data"];
    
    _inventory.assetTag = receivedTag;
    _inventory.itemNumber = receivedTag;
    
    [_tagTextField setText:_inventory.assetTag];
    [_itemTextField setText:_inventory.itemNumber];
}

- (void)acceptChangeAssetTag {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"choose_action", [UTIL getLanguage], @"") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionCamera = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"camera", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self openCamera];
    }];
    
    UIAlertAction *actionManual = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"manual", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self openManual:@""];
    }];
    
    UIAlertAction *actionExternal = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedStringFromTable(@"external", [UTIL getLanguage], @""), NSLocalizedStringFromTable(@"scanner", [UTIL getLanguage], @"")] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
    }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", [UTIL getLanguage], @"") style:UIAlertActionStyleCancel handler:nil];
    [actionCancel setValue:[UTIL darkRedColor] forKey:@"titleTextColor"];
    
    [actionSheet addAction:actionCamera];
    [actionSheet addAction:actionManual];
    [actionSheet addAction:actionExternal];
    [actionSheet addAction:actionCancel];
    
    if (IS_IPAD()) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        UIPopoverPresentationController *popoverPresentationController = [actionSheet popoverPresentationController];
        [popoverPresentationController setSourceRect:cell.frame];
        [popoverPresentationController setSourceView:self.view];
        [actionSheet setModalPresentationStyle:UIModalPresentationPopover];
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)openManual:(NSString *)term {
    UIAlertController *manual = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"manual_scan", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"new_asset_tag", [UTIL getLanguage], @"")  preferredStyle:UIAlertControllerStyleAlert];
    [manual addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"ok", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *term = [[[manual textFields] objectAtIndex:0] text];
        self->_inventory.assetTag = term;
        self->_inventory.itemNumber = term;
        
        [self->_tagTextField setText:self->_inventory.assetTag];
        [self->_itemTextField setText:self->_inventory.itemNumber];
    }]];
    [manual addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", [UTIL getLanguage], @"") style:UIAlertActionStyleCancel handler:nil]];
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

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"showSelection"]) {
        SelectionViewController *child = (SelectionViewController *)[segue destinationViewController];
        [child setSelection:_selection];
        [child setSelectionTitle:_selectionTitle];
        [child setSelectedObjectType:_selectedObjectType];
        [child setSelectedObject:_selectedObject];
    }
}

- (IBAction)savePressed:(id)sender {
    [UTIL showActivity:NSLocalizedStringFromTable(@"saving", [UTIL getLanguage], @"")];
    [self performSelector:@selector(save) withObject:nil afterDelay:0.1f];
}

- (void)save {
    // update the status object
    if ([_inventory.status.genericId isEqual: @"0"] && ![_inventory.status.value isEqual: @""]) {
        for (GenericObject *stat in STATUSES.items) {
            if ([stat.value isEqual: _inventory.status.value]) {
                _inventory.status = stat;
            }
        }
    }
    
    [_inventory save:^(bool result) {
        [UTIL hideActivity];
        
        if (result) {
            if (self->_inventory.inventoryId == 0) {
                // check if user wants to duplicate
                [ALERT promptWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"the_item_has_been_saved_duplicate", [UTIL getLanguage], @"") completion:^(BOOL granted) {
                    if (granted) {
                        self->_inventory.inventoryId = 0;
                        self->_inventory.assetTag = @"";
                        self->_inventory.itemNumber = @"";
                        self->_inventory.serialNumber = @"";
                        
                        [self fillData];
                        self->_itemDuplicate = true;
                    } else {
                        [self->_inventory reload:^(bool result) {
                            self->_itemDuplicate = false;
                        }];
                    }
                }];
            }   else {
                self->_itemDuplicate = false;
                [self->_inventory reload:^(bool result) {
                    [ALERT alertWithTitle:NSLocalizedStringFromTable(@"information", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"the_item_has_been_saved", [UTIL getLanguage], @"")];
                }];
            }
        }
    }];
}

@end
