//
//  BatchSearchViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-10-06.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import "BatchSearchViewController.h"

@interface BatchSearchViewController ()

@end

@implementation BatchSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setTitle:NSLocalizedStringFromTable(@"search_results", [UTIL getLanguage], @"")];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    Inventory *inventory = (Inventory *)[_items objectAtIndex:[indexPath row]];
    [cell.textLabel setText:[NSString stringWithFormat:@"%@ - %@",inventory.itemClass,inventory.itemModel]];
    [cell.detailTextLabel setNumberOfLines:4];
    NSString *details = [NSString stringWithFormat:@"%@: %@, %@: %@\n%@: %@",NSLocalizedStringFromTable(@"item", [UTIL getLanguage], @""), inventory.itemNumber, NSLocalizedStringFromTable(@"tag", [UTIL getLanguage], @""), inventory.assetTag, NSLocalizedStringFromTable(@"status", [UTIL getLanguage], @""), inventory.status.value];
    if (![[UTIL trim:inventory.transitBranch.value] isEqualToString:@""]) {
        details = [NSString stringWithFormat:@"%@ [%@]", details, inventory.transitBranch.value];
    }
    [cell.detailTextLabel setText:details];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:[_items objectAtIndex:[indexPath row]]];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:items forKey:@"data"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"externalScannerItemsResponse" object:nil userInfo:userInfo];
    
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
