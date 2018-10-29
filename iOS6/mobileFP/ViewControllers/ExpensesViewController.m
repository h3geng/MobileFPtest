//
//  ExpensesViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-01-17.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import "ExpensesViewController.h"

@interface ExpensesViewController ()

@end

@implementation ExpensesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedStringFromTable(@"expenses", [UTIL getLanguage], @"")];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _statusFilter = 0;
    
    _corporateItems = [[NSMutableArray alloc] init];
    _mileageItems = [[NSMutableArray alloc] init];
    _personalItems = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _items = [[NSMutableArray alloc] init];
    
    [UTIL showActivity:@""];
    [API getExpenseMileageRate:USER.sessionId completion:^(NSMutableArray *result) {
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqualToString: @""]) {
            NSMutableArray *responseData = ([result valueForKey:@"getExpenseMileageRateResult"] != [NSNull null]) ?  [result valueForKey:@"getExpenseMileageRateResult"] : nil;
            if (responseData != nil) {
                [UTIL setMileageRange:[[responseData valueForKey:@"ParentId"] doubleValue]];
                [UTIL setMileageRate1:[[responseData valueForKey:@"Value"] doubleValue]];
                [UTIL setMileageRate2:[[responseData valueForKey:@"Code"] doubleValue]];
                [self getExpenses];
            } else {
                [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:@"Sorry mileage rates not available"];
            }
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
        }
    }];
}

- (void)getExpenses {
    _corporateItems = [[NSMutableArray alloc] init];
    _mileageItems = [[NSMutableArray alloc] init];
    _personalItems = [[NSMutableArray alloc] init];
    
    [API getExpenses:USER.sessionId userGUID:USER.userId status:[NSString stringWithFormat:@"%d", _statusFilter] completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqualToString: @""]) {
            NSMutableArray *responseData = ([result valueForKey:@"getExpensesResult"] != [NSNull null]) ?  [result valueForKey:@"getExpensesResult"] : nil;
            for (id expense in responseData) {
                Expense *item = [[Expense alloc] init];
                [item initWithData:expense];
                
                [self->_items addObject:item];
            }
            
            [self collectExpenses];
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
        }
    }];
}

- (void)collectExpenses {
    for (Expense *item in _items) {
        switch (item.expenseMethodId) {
            case 1:
                [self->_corporateItems addObject:item];
                break;
            case 2:
                [self->_personalItems addObject:item];
                break;
            case 3:
                [self->_mileageItems addObject:item];
                break;
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat heightForRow = 56.0f;
    
    if ([indexPath section] == 0) {
        heightForRow = UITableViewAutomaticDimension;
    }
    
    return heightForRow;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 1;
    
    switch (section) {
        case 1:
            numberOfRows = _corporateItems.count;
            break;
        case 2:
            numberOfRows = _mileageItems.count;
            break;
        case 3:
            numberOfRows = _personalItems.count;
            break;
        default:
            numberOfRows = 1;
            break;
    }
    
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        default:
            return .1f;
            break;
        case 1:
            if (_corporateItems.count == 0) {
                return .1f;
            } else {
                return UITableViewAutomaticDimension;
            }
            break;
        case 2:
            if (_mileageItems.count == 0) {
                 return .1f;
            } else {
                return UITableViewAutomaticDimension;
            }
            break;
        case 3:
            if (_personalItems.count == 0) {
                 return .1f;
            } else {
                return UITableViewAutomaticDimension;
            }
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    switch (section) {
        default:
            return UITableViewAutomaticDimension;
            break;
        case 1:
            if (_corporateItems.count == 0) {
                return .1f;
            } else {
                return UITableViewAutomaticDimension;
            }
            break;
        case 2:
            if (_mileageItems.count == 0) {
                return .1f;
            } else {
                return UITableViewAutomaticDimension;
            }
            break;
        case 3:
            if (_personalItems.count == 0) {
                return .1f;
            } else {
                return UITableViewAutomaticDimension;
            }
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"";
    
    switch (section) {
        case 1:
            if (_corporateItems.count > 0) {
                title = NSLocalizedStringFromTable(@"corporate_card", [UTIL getLanguage], @"");
            }
            break;
        case 2:
            if (_mileageItems.count > 0) {
                title = NSLocalizedStringFromTable(@"mileage", [UTIL getLanguage], @"");
            }
            break;
        case 3:
            if (_personalItems.count > 0) {
                title = NSLocalizedStringFromTable(@"out_of_pocket", [UTIL getLanguage], @"");
            }
            break;
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    Expense *expense;
    
    switch ([indexPath section]) {
        case 0:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"filterCell" forIndexPath:indexPath];
            UISegmentedControl *filter = (UISegmentedControl *)[cell viewWithTag:1];
            [filter addTarget:self action:@selector(filterChanged:) forControlEvents:UIControlEventValueChanged];
        }
            break;
        case 1:
            expense = (Expense *)[_corporateItems objectAtIndex:[indexPath row]];
            break;
        case 2:
            expense = (Expense *)[_mileageItems objectAtIndex:[indexPath row]];
            break;
        case 3:
            expense = (Expense *)[_personalItems objectAtIndex:[indexPath row]];
            break;
    }
    
    if ([indexPath section] != 0) {
        NSDate *dt = [UTIL formatDateString:expense.dateExpense format:@"yyyy-MM-dd"];
        [cell.textLabel setText:[NSString stringWithFormat:@"$%.02f", expense.totalAmount]];
        [cell.detailTextLabel setText:[UTIL formatDateOnly:dt format:@"MMM d, yyyy"]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    return cell;
}

- (void)filterChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 1:
            _statusFilter = 6;
            break;
        case 2:
            _statusFilter = 3;
            break;
        case 3:
            _statusFilter = 1;
            break;
        default:
            _statusFilter = 0;
            break;
    }
    
    _items = [[NSMutableArray alloc] init];
    [UTIL showActivity:@""];
    [self getExpenses];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] != 0) {
        switch ([indexPath section]) {
            case 1:
                _selectedExpense = (Expense *)[_corporateItems objectAtIndex:[indexPath row]];
                break;
            case 2:
                _selectedExpense = (Expense *)[_mileageItems objectAtIndex:[indexPath row]];
                break;
            case 3:
                _selectedExpense = (Expense *)[_personalItems objectAtIndex:[indexPath row]];
                break;
        }
        
        [UTIL showActivity:@""];
        [_selectedExpense load:^(NSMutableArray *result) {
            [UTIL hideActivity];
            
            [self->_selectedExpense initWithData:result];
            [self performSegueWithIdentifier:@"showExpense" sender:self];
        }];
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
    if ([[segue identifier] isEqualToString:@"showExpense"]) {
        ExpenseViewController *child = (ExpenseViewController *)[segue destinationViewController];
        [child setExpense:_selectedExpense];
    }
}

- (IBAction)addPressed:(id)sender {
    _selectedExpense = [[Expense alloc] init];
    
    _selectedExpense.dateExpense = [UTIL formatDateOnly:[NSDate date] format:@"yyyy-MM-dd HH:mm:ss"];
    _selectedExpense.currencyId = 1; // set default to CAD for new expenses
    
    GenericObject *br = [ALLBRANCHES getBranchByName:USER.userDetail.branch];
    _selectedExpense.branchId = [br.genericId intValue];
    _selectedExpense.branchName = br.value;
    
    _selectedExpense.expenseMethodId = 3; // set default to mileage for new expenses
    
    [self performSegueWithIdentifier:@"showExpense" sender:self];
}

@end
