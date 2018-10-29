//
//  AlertsViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/12/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "AlertsViewController.h"
#import "AlertViewController.h"

@interface AlertsViewController ()

@end

@implementation AlertsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setTitle:NSLocalizedStringFromTable(@"file_alerts", [UTIL getLanguage], @"")];
    
    _items = [[NSMutableArray alloc] init];
    _itemsLoaded = false;
    
    [self.tableView setEstimatedRowHeight:44.0f];
    [self.tableView setRowHeight:UITableViewAutomaticDimension];
    
    [UTIL showActivity:NSLocalizedStringFromTable(@"loading", [UTIL getLanguage], @"")];
    [self performSelector:@selector(loadFileAlerts) withObject:nil afterDelay:0.1f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadFileAlerts {
    [API getFileAlertSummary:USER.sessionId ctUserId:USER.ctUser.value completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqualToString: @""]) {
            NSMutableArray *responseData = [result valueForKey:@"getFileAlertSummaryResult"];
            if (![responseData isKindOfClass:[NSNull class]]) {
                for (id alert in responseData) {
                    GenericObject *go = [[GenericObject alloc] init];
                    go.genericId = [alert valueForKey:@"alertId"];
                    go.value = [NSString stringWithFormat:@"%@ %@", [alert valueForKey:@"count"], [alert valueForKey:@"description"]];
                    [self->_items addObject:go];
                }
                
                [self.tableView reloadData];
            }
            self->_itemsLoaded = true;
        } else {
            self->_itemsLoaded = false;
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
        }
    }];
}

#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"";
    if (_itemsLoaded && [_items count] == 0) {
        title = NSLocalizedStringFromTable(@"nothing_found", [UTIL getLanguage], @"");
    }
    
    return title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    GenericObject *obj = (GenericObject *)[_items objectAtIndex:[indexPath row]];
    [cell.textLabel setText:obj.value];
    [cell.textLabel setNumberOfLines:0];
    
    [cell setTag:[obj.genericId intValue]];
    
    if ([obj.genericId isEqual: @"0"]) {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    _selectedAlert = (GenericObject *)[_items objectAtIndex:[indexPath row]];
    
    [UTIL showActivity:NSLocalizedStringFromTable(@"loading", [UTIL getLanguage], @"")];
    [self performSelector:@selector(getAlertDetails:) withObject:cell afterDelay:0.1f];
}

- (void)getAlertDetails:(UITableViewCell *)cell {
    [API getFileAlertDetail:USER.sessionId regionId:USER.regionId alertId:(int)[cell tag] ctUserId:USER.ctUser.value completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqualToString: @""]) {
            self->_alertDetails = [[NSMutableArray alloc] init];
            
            NSMutableArray *responseData = [result valueForKey:@"getFileAlertDetailResult"];
            
            if (![responseData isKindOfClass:[NSNull class]]) {
                NSMutableArray *responseDataItems = [responseData valueForKey:@"items"];
                
                GenericObject *go;
                for (id alrt in responseDataItems) {
                    go = [[GenericObject alloc] init];
                    go.genericId = [alrt valueForKey:@"Id"];
                    go.code = [alrt valueForKey:@"Code"];
                    go.value = [alrt valueForKey:@"Value"];
                    [self->_alertDetails addObject:go];
                }
                
                [self performSegueWithIdentifier:@"showDetails" sender:self];
            }
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
        }
    }];
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
        AlertViewController *child = (AlertViewController *)[segue destinationViewController];
        [child setItems:_alertDetails];
        [child setHeaderText:_selectedAlert.value];
    }
}

@end
