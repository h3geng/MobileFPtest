//
//  ClaimsViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 9/27/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "ClaimsViewController.h"
#import "ClaimDetailsViewController.h"
#import "BatchItemsViewController.h"
#import "TimesheetViewController.h"
#import "EquipmentDetailsViewController.h"
#import "ClaimPhasesViewController.h"
#import "ExpenseViewController.h"

@interface ClaimsViewController ()

@end

@implementation ClaimsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedStringFromTable(@"claims", [UTIL getLanguage], @"")];
    
    _items = [[NSMutableArray alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (!_onSelect) {
        _onSelect = @"showDetails";
    }
    
    [_jobsSearchBar setPlaceholder:NSLocalizedStringFromTable(@"search", [UTIL getLanguage], @"")];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setTitle:NSLocalizedStringFromTable(@"claims", [UTIL getLanguage], @"")];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_items.count == 0) {
        [UTIL showActivity:@""];
        [self searchClosest];
    }
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
    
    [UTIL showActivity:NSLocalizedStringFromTable(@"searching_jobs", [UTIL getLanguage], @"")];
    [self performSelector:@selector(search:) withObject:[searchBar text] afterDelay:0.1f];
}

- (void)search:(NSString *)term {
    [API findJob:USER.sessionId regionId:USER.regionId branchCode:@"" userCode:@"" searchString:[UTIL trim:term] completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqualToString: @""]) {
            NSMutableArray *responseData = ([result valueForKey:@"findJobResult"] != [NSNull null]) ?  [result valueForKey:@"findJobResult"] : nil;
            [self processSearchResults:responseData];
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
        }
    }];
}

- (void)searchClosest {
    [_jobsSearchBar setText:@""];
    
    [API findClosestJobs:USER.sessionId regionId:USER.regionId brnachCode:@"" userCode:@"" location:LOCATION.lastSavedLocation completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqualToString: @""]) {
            NSMutableArray *responseData = ([result valueForKey:@"findClosestJobsResult"] != [NSNull null]) ?  [result valueForKey:@"findClosestJobsResult"] : nil;
            [self processSearchResults:responseData];
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
        }
    }];
}

- (void)processSearchResults:(NSMutableArray *)results {
    _items = [[NSMutableArray alloc] init];
    
    if ([results count] > 0) {
        for (id claim in results) {
            Claim *item = [[Claim alloc] init];
            item.claimIndx = [[claim valueForKey:@"ClaimIndx"] intValue];
            item.claimNumber = [claim valueForKey:@"ClaimNumber"];
            item.projectName = [claim valueForKey:@"ProjectName"];
            item.dateJobOpen = [claim valueForKey:@"DateJobOpen"];
            item.addressString = [claim valueForKey:@"Address"];
            item.city = [claim valueForKey:@"City"];
            item.address.address = item.addressString;
            item.address.city = item.city;
            [item.address prepareFullAddress];
            
            [_items addObject:item];
        }
    } else {
        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"no_jobs_found", [UTIL getLanguage], @"")];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76.0f;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    Claim *claim = [_items objectAtIndex:[indexPath row]];
    
    NSArray* dateComponents = [[NSString stringWithFormat:@"%@", claim.dateJobOpen] componentsSeparatedByString: @" "];
    NSString* day = [dateComponents objectAtIndex: 0];
    
    [cell setTag:claim.claimIndx];
    [cell.textLabel setText:[NSString stringWithFormat:@"%@ (%@)",claim.claimNumber,day]];
    [cell.detailTextLabel setNumberOfLines:2];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@\n%@",claim.projectName, claim.address.fullAddress]];
    [cell.detailTextLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [UTIL showActivity:NSLocalizedStringFromTable(@"loading_job", [UTIL getLanguage], @"")];
    [self performSelector:@selector(loadClaim:) withObject:cell afterDelay:0.1f];
}

- (void)loadClaim:(UITableViewCell *)cell {
    Claim *claim = [[Claim alloc] init];
    claim.claimIndx = (int)cell.tag;
    
    [claim load:^(bool result) {
        if (result) {
            [UTIL hideActivity];
            self->_selectedClaim = claim;
            
            [self performSelector:@selector(process) withObject:nil afterDelay:.1f];
        } else {
            [UTIL hideActivity];
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"job_not_loaded", [UTIL getLanguage], @"")];
        }
    }];
}

- (void)process {
    UIViewController *prevController = [APP_DELEGATE getPreviousScreen];
    if ([prevController isKindOfClass:[ExpenseViewController class]]) {
        NSMutableArray *notificationObjects = [[NSMutableArray alloc] init];
        [notificationObjects addObject:[NSString stringWithFormat:@"%d", 6]];
        [notificationObjects addObject:_selectedClaim];
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:notificationObjects forKey:@"collectionItem"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"collectionItemSelected" object:nil userInfo:dictionary];
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if ([prevController isKindOfClass:[TimesheetViewController class]]) {
            TimesheetViewController *timesheetViewController = (TimesheetViewController *)prevController;
            [timesheetViewController setClaim:_selectedClaim];
            [timesheetViewController setPhase:[[GenericObject alloc] init]];
            [timesheetViewController refreshTable];
            
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            if ([prevController isKindOfClass:[EquipmentDetailsViewController class]]) {
                //EquipmentDetailsViewController *equipmentDetailsViewController = (EquipmentDetailsViewController *)prevController;
                
                
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:_selectedClaim forKey:@"data"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedClaimToIssue" object:nil userInfo:userInfo];
                [self.navigationController popViewControllerAnimated:YES];
                //[equipmentDetailsViewController receivedClaimToIssue:_selectedClaim];
            } else {
                if ([prevController isKindOfClass:[MyDayEventViewController class]]) {
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:_selectedClaim forKey:@"data"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"eventClaimSelected" object:nil userInfo:userInfo];
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    if ([_onSelect isEqual: @"showDetails"]) {
                        [self performSegueWithIdentifier:@"showDetails" sender:self];
                    }
                    if ([_onSelect isEqual: @"showBatchScan"]) {
                        [self performSegueWithIdentifier:@"showPhases" sender:self];
                    }
                }
            }
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showDetails"]) {
        ClaimDetailsViewController *child = (ClaimDetailsViewController *)[segue destinationViewController];
        [child setClaim:_selectedClaim];
    }
    
    if ([[segue identifier] isEqualToString:@"showBatchScan"]) {
        BatchItemsViewController *child = (BatchItemsViewController *)[segue destinationViewController];
        [child setHeaderTitle:_selectedClaim.claimNumber];
        [child setClaim:_selectedClaim];
        [child setTransactionType:2];
    }
    
    if ([[segue identifier] isEqualToString:@"showPhases"]) {
        ClaimPhasesViewController *child = (ClaimPhasesViewController *)[segue destinationViewController];
        [child setHeaderTitle:_selectedClaim.claimNumber];
        [child setClaim:_selectedClaim];
        [child setTransactionType:2];
    }
}

- (IBAction)actionsPressed:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"choose_action", [UTIL getLanguage], @"") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionClosest = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"find_closest_jobs", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [UTIL showActivity:NSLocalizedStringFromTable(@"searching_closest_jobs", [UTIL getLanguage], @"")];
        [self performSelector:@selector(searchClosest) withObject:nil afterDelay:0.1f];
    }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", [UTIL getLanguage], @"") style:UIAlertActionStyleCancel handler:nil];
    [actionCancel setValue:[UTIL darkRedColor] forKey:@"titleTextColor"];
    
    [actionSheet addAction:actionClosest];
    [actionSheet addAction:actionCancel];
    
    if (IS_IPAD()) {
        UIPopoverPresentationController *popoverPresentationController = [actionSheet popoverPresentationController];
        popoverPresentationController.barButtonItem = _actionsButton;
        [actionSheet setModalPresentationStyle:UIModalPresentationPopover];
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

@end
