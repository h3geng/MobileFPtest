//
//  ClaimWorkOrdersViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 1/7/15.
//  Copyright (c) 2015 FirstOnSite. All rights reserved.
//

#import "ClaimWorkOrdersViewController.h"

@interface ClaimWorkOrdersViewController ()

@end

@implementation ClaimWorkOrdersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setTitle:NSLocalizedStringFromTable(@"work_orders", [UTIL getLanguage], @"")];
    
    [UTIL showActivity:NSLocalizedStringFromTable(@"searching", [UTIL getLanguage], @"")];
    [self performSelector:@selector(search) withObject:nil afterDelay:0.1f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)search {
    [API getJobWorkorders:USER.sessionId claimIndx:_claim.claimIndx completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqualToString: @""]) {
            NSMutableArray *responseData = ([result valueForKey:@"getJobWorkordersResult"] != [NSNull null]) ?  [result valueForKey:@"getJobWorkordersResult"] : nil;
            
            if ([responseData count] > 0) {
                self->_items = [[NSMutableArray alloc] init];
                
                for (id wo in responseData) {
                    WorkOrder *item = [[WorkOrder alloc] init];
                    [item initWithData:wo];
                    
                    [self->_items addObject:item];
                }
                [self.tableView reloadData];
            } else {
                [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"nothing_found", [UTIL getLanguage], @"")];
            }
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
        }
    }];
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

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"woCell" forIndexPath:indexPath];
    
    WorkOrder *wo = (WorkOrder *)[_items objectAtIndex:[indexPath row]];
    UILabel *lbl = (UILabel *)[cell viewWithTag:10];
    [lbl setText:wo.vendor.code];
    
    lbl = (UILabel *)[cell viewWithTag:20];
    [lbl setText:[NSString stringWithFormat:@"%@: %@", NSLocalizedStringFromTable(@"phase", [UTIL getLanguage], @""), wo.phase.code]];
    
    lbl = (UILabel *)[cell viewWithTag:30];
    [lbl setText:[NSString stringWithFormat:@"%@: %d", NSLocalizedStringFromTable(@"order", [UTIL getLanguage], @""), wo.order]];
    
    lbl = (UILabel *)[cell viewWithTag:40];
    [lbl setText:wo.comment];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
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

- (IBAction)actionsPressed:(id)sender {
}

@end
