//
//  BranchesViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/9/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "BranchesViewController.h"
#import "BatchItemsViewController.h"
#import "EquipmentDetailsViewController.h"

@interface BranchesViewController ()

@end

@implementation BranchesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setTitle:NSLocalizedStringFromTable(@"branches", [UTIL getLanguage], @"")];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return BRANCHES.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    GenericObject *go = (GenericObject *)[BRANCHES.items objectAtIndex:[indexPath row]];
    [cell.textLabel setText:[NSString stringWithFormat:@"%@ (%@)", go.value, go.code]];
    NSUInteger transItemsCount = [TRANSACTIONS branchItems:go.code].count;
    if (transItemsCount > 0) {
        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)transItemsCount]];
    }
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedBranch = (GenericObject *)[BRANCHES.items objectAtIndex:[indexPath row]];
    
    UIViewController *parent = [APP_DELEGATE getPreviousScreen];
    if ([parent isKindOfClass:[EquipmentDetailsViewController class]]) {
        EquipmentDetailsViewController *equipmentDetailsViewController = (EquipmentDetailsViewController *)parent;
        [equipmentDetailsViewController setBranchToIssue:_selectedBranch];
        [equipmentDetailsViewController issueToBranch];
        [equipmentDetailsViewController setReloadOnAppear:false];
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self performSegueWithIdentifier:@"showBatchScan" sender:self];
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
    if ([[segue identifier] isEqualToString:@"showBatchScan"]) {
        BatchItemsViewController *child = (BatchItemsViewController *)[segue destinationViewController];
        [child setHeaderTitle:_selectedBranch.value];
        [child setBranch:_selectedBranch];
        [child setTransactionType:4];
    }
}

@end
