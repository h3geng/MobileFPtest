//
//  EmployeesViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/12/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "EmployeesViewController.h"
#import "TimesheetViewController.h"

@interface EmployeesViewController ()

@end

@implementation EmployeesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedStringFromTable(@"employee", [UTIL getLanguage], @"")];
    
    _items = [[NSMutableArray alloc] init];
    
    _defaultEmployee = [[GenericObject alloc] init];
    _defaultEmployee.genericId = @"1";
    _defaultEmployee.value = USER.userId;
    _defaultEmployee.code = USER.name;
    
    [_employeeSearchBar setDelegate:self];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_employeeSearchBar setPlaceholder:NSLocalizedStringFromTable(@"search", [UTIL getLanguage], @"")];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    [UTIL showActivity:NSLocalizedStringFromTable(@"searching_employees", [UTIL getLanguage], @"")];
    [self performSelector:@selector(search:) withObject:[searchBar text] afterDelay:0.1f];
}

- (void)search:(NSString *)term {
    [API findProductionEmployees:USER.sessionId searchString:term completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqualToString: @""]) {
            NSMutableArray *responseData = [result valueForKey:@"findProductionEmployeesResult"];
            int cnt = 0;
            @try {
                cnt = (int)responseData.count;
            }
            @catch (NSException *exception) {
                cnt = 0;
            }
            @finally {
            }
            
            if (cnt > 0)
            {
                self->_items = [[NSMutableArray alloc] init];
                for (id emp in responseData) {
                    GenericObject *tempObj = [[GenericObject alloc] init];
                    tempObj.genericId = @"1";
                    tempObj.value = [emp valueForKey:@"Id"];
                    tempObj.code = [emp valueForKey:@"Value"];
                    [self->_items addObject:tempObj];
                }
                
                [self.tableView reloadData];
            } else {
                [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"nothing_found", [UTIL getLanguage], @"")];
            }
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
        }
    }];
}

#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"";
    if (section == 0 && USER.isProduction) {
        title = NSLocalizedStringFromTable(@"default_employee", [UTIL getLanguage], @"");
    }
    
    return title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSInteger numberOfSections = 1;
    
    if (USER.isProduction) {
        numberOfSections = 2;
    }
    
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger numberOfRows = 0;
    switch (section) {
        case 0:
            if (USER.isProduction) {
                numberOfRows = 1;
            } else {
                numberOfRows = _items.count;
            }
            break;
        default:
            numberOfRows = _items.count;
            break;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    GenericObject *go = _defaultEmployee;
    if ([indexPath section] == 1 || !USER.isProduction) {
        go = (GenericObject *)[_items objectAtIndex:[indexPath row]];
    }
    [cell.textLabel setText:go.code];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GenericObject *go = _defaultEmployee;
    if ([indexPath section] == 1 || !USER.isProduction) {
        go = (GenericObject *)[_items objectAtIndex:[indexPath row]];
    }
    
    TimesheetViewController *timesheetViewController = (TimesheetViewController *)[APP_DELEGATE getPreviousScreen];
    [timesheetViewController setEmployee:go];
    [timesheetViewController refreshTable];
    
    [self.navigationController popViewControllerAnimated:YES];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
