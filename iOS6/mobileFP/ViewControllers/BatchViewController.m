//
//  BatchViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/9/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "BatchViewController.h"
#import "BatchItemsViewController.h"
#import "ClaimsViewController.h"
#import "TransactionsViewController.h"
#import "ErrorsViewController.h"

@interface BatchViewController ()

@end

@implementation BatchViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.batchType = 0;
        self.simpleMode = false;
        self.transactionType = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (_simpleMode) {
        [self setTitle:NSLocalizedStringFromTable(@"transactions", [UTIL getLanguage], @"")];
    } else {
        [self setTitle:NSLocalizedStringFromTable(@"batch_scan", [UTIL getLanguage], @"")];
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

#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"";
    if (section == 0 && !_simpleMode) {
        title = NSLocalizedStringFromTable(@"scan_to", [UTIL getLanguage], @"");
    }
    return title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSInteger numberOfSections = 1;
    if (([TRANSACTIONS items]).count > 0) {
        numberOfSections = 2;
    }
    
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger numberOfRows = 4;
    if (section == 1) {
        numberOfRows = 2;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    switch ([indexPath section]) {
        case 0:
            switch ([indexPath row]) {
                case 0:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"transit", [UTIL getLanguage], @"")];
                    [cell.imageView setImage:[UIImage imageNamed: @"Transit"]];
                    break;
                case 1:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"claim", [UTIL getLanguage], @"")];
                    [cell.imageView setImage:[UIImage imageNamed: @"Claim"]];
                    break;
                case 2:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"return_to_branch", [UTIL getLanguage], @"")];
                    [cell.imageView setImage:[UIImage imageNamed: @"Return"]];
                    break;
                case 3:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"branch_transfer", [UTIL getLanguage], @"")];
                    [cell.imageView setImage:[UIImage imageNamed: @"Branch"]];
                    break;
            }
            
            [cell.detailTextLabel setText:[NSString stringWithFormat:@" %lu ", (unsigned long)([TRANSACTIONS itemsForType:((int)[indexPath row] + 1) parent:[[GenericObject alloc] init]]).count]];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
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
    _batchType = (int)[indexPath row];
    
    if ([indexPath section] == 0) {
        switch ([indexPath row]) {
            case 0:
                if (!_simpleMode) {
                    [self performSegueWithIdentifier:@"showBatchItems" sender:self];
                } else {
                    _transactionType = 0;
                    [self performSegueWithIdentifier:@"showTransactions" sender:self];
                }
                break;
            case 1:
                if (!_simpleMode) {
                    [self performSegueWithIdentifier:@"showClaims" sender:self];
                } else {
                    _transactionType = 2;
                    [self performSegueWithIdentifier:@"showTransactions" sender:self];
                }
                break;
            case 2:
                if (!_simpleMode) {
                    [self performSegueWithIdentifier:@"showBatchItems" sender:self];
                } else {
                    _transactionType = 3;
                    [self performSegueWithIdentifier:@"showTransactions" sender:self];
                }
                break;
            case 3:
                if (!_simpleMode) {
                    [self performSegueWithIdentifier:@"showBranches" sender:self];
                } else {
                    _transactionType = 1;
                    [self performSegueWithIdentifier:@"showTransactions" sender:self];
                }
                break;
        }
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        switch ([indexPath row]) {
            case 0: {
                [ALERT promptWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"do_you_want_to_commit_all_items", [UTIL getLanguage], @"") completion:^(BOOL granted) {
                    if (granted) {
                        [TRANSACTIONS commitAll:-1 completion:^(NSMutableArray *result) {
                            if (result.count > 0) {
                                ErrorsViewController *errorsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"errorsView"];
                                [errorsViewController setErrors:result];
                                
                                UINavigationController *navController = [UTIL getErrorNavigationController:errorsViewController];
                                
                                [self.navigationController presentViewController:navController animated:YES completion:^ {
                                    [self.tabBarController.tabBar setHidden:YES];
                                }];
                            } else {
                                [self.tableView reloadData];
                            }
                        }];
                    }
                }];
            }
                break;
            case 1:
                [ALERT promptWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"do_you_want_to_revert_all_items", [UTIL getLanguage], @"") completion:^(BOOL granted) {
                    if (granted) {
                        [TRANSACTIONS clean];
                        [self.tableView reloadData];
                    }
                }];
                break;
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
    if ([[segue identifier] isEqualToString:@"showBatchItems"]) {
        BatchItemsViewController *child = (BatchItemsViewController *)[segue destinationViewController];
        if (_batchType == 0) {
            [child setHeaderTitle:NSLocalizedStringFromTable(@"transit", [UTIL getLanguage], @"")];
            [child setTransactionType:1];
        }
        if (_batchType == 2) {
            [child setHeaderTitle:NSLocalizedStringFromTable(@"return", [UTIL getLanguage], @"")];
            [child setTransactionType:3];
        }
    }
    
    if ([[segue identifier] isEqualToString:@"showBranches"]) {
    }
    
    if ([[segue identifier] isEqualToString:@"showClaims"]) {
        ClaimsViewController *child = (ClaimsViewController *)[segue destinationViewController];
        [child setOnSelect:@"showBatchScan"];
    }
    
    if ([[segue identifier] isEqualToString:@"showTransactions"]) {
        TransactionsViewController *child = (TransactionsViewController *)[segue destinationViewController];
        [child setTransactionType:_transactionType];
    }
}

@end
