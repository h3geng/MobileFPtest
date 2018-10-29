//
//  TransactionsViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/15/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "TransactionsViewController.h"
#import "ErrorsViewController.h"

@interface TransactionsViewController ()

@end

@implementation TransactionsViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.transactionType = 0;
        self.items = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self reloadItems];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    if (_items.count > 0) {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    
    switch (_transactionType) {
        case 0: // transit
            [self setTitle:NSLocalizedStringFromTable(@"transit", [UTIL getLanguage], @"")];
            break;
        case 1: // branch
            [self setTitle:NSLocalizedStringFromTable(@"branch_transfer", [UTIL getLanguage], @"")];
            break;
        case 2: // claim
            [self setTitle:NSLocalizedStringFromTable(@"claim", [UTIL getLanguage], @"")];
            break;
        case 3: // return
            [self setTitle:NSLocalizedStringFromTable(@"return_to_branch", [UTIL getLanguage], @"")];
            break;
    }
}

- (void)reloadItems {
    NSMutableArray *transItems;
    _items = [[NSMutableArray alloc] init];
    
    switch (_transactionType) {
        case 0: // transit
            transItems = [TRANSACTIONS transitItems];
            break;
        case 1: // branch
            transItems = [TRANSACTIONS branchItems:@""];
            break;
        case 2: // claim
            transItems = [TRANSACTIONS claimItems:0];
            break;
        case 3: // return
            transItems = [TRANSACTIONS returnItems];
            break;
    }
    
    for (TransactionItem *item in transItems) {
        [_items addObject:item.inventory];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44.0f;
    if ([indexPath section] == 0) {
        height = 72.0f;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44.0f;
    if ([indexPath section] == 0) {
        height = 72.0f;
    }
    
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSInteger numberOfSections = 1;
    if (_items.count > 0) {
        numberOfSections = 2;
    }
    
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger numberOfRows = _items.count;
    if (section == 1) {
        numberOfRows = 2;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    Inventory *inventory;
    
    switch ([indexPath section]) {
        case 0:
        {
            inventory = [_items objectAtIndex:[indexPath row]];
            
            [cell.textLabel setText:[NSString stringWithFormat:@"%@ - %@",inventory.itemClass,inventory.itemModel]];
            [cell.detailTextLabel setNumberOfLines:-1];
            
            NSString *details = [NSString stringWithFormat:@"%@: %@, %@: %@",NSLocalizedStringFromTable(@"item", [UTIL getLanguage], @""), inventory.itemNumber, NSLocalizedStringFromTable(@"tag", [UTIL getLanguage], @""),inventory.assetTag];
            
            if (![[UTIL trim:inventory.transitBranch.value] isEqualToString:@""]) {
                details = [NSString stringWithFormat:@"%@\n%@: %@", details, NSLocalizedStringFromTable(@"current_branch", [UTIL getLanguage], @""), inventory.transitBranch.value];
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

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if ([indexPath section] == 0) {
        return YES;
    } else {
        return NO;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Inventory *inventory = [_items objectAtIndex:[indexPath row]];
        [TRANSACTIONS removeInventory:inventory.inventoryId];
        
        if (_transactionType == 2) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"claimItemsChanged" object:nil userInfo:nil];
        }
        
        [self reloadItems];
        if (_items.count > 0) {
            self.navigationItem.rightBarButtonItem = self.editButtonItem;
        }
        [self.tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        switch ([indexPath row]) {
            case 0: {
                [ALERT promptWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"do_you_want_to_commit_all_items", [UTIL getLanguage], @"") completion:^(BOOL granted) {
                    if (granted) {
                        [TRANSACTIONS commitAll:self->_transactionType completion:^(NSMutableArray *result) {
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
                        switch (self->_transactionType) {
                            case 0: // transit
                                [TRANSACTIONS transitClean];
                                break;
                            case 1: // branch
                                [TRANSACTIONS branchClean:@""];
                                break;
                            case 2: // claim
                                [TRANSACTIONS claimClean:0];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"claimItemsChanged" object:nil userInfo:nil];
                                break;
                            case 3: // return
                                [TRANSACTIONS returnClean];
                                break;
                        }
                        [self reloadItems];
                        [self.tableView reloadData];
                    }
                }];
                break;
        }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
