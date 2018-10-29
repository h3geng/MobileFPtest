//
//  PaymentsViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2016-01-26.
//  Copyright © 2016 FirstOnSite. All rights reserved.
//

#import "PaymentsViewController.h"

@interface PaymentsViewController ()

@end

@implementation PaymentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setTitle:NSLocalizedStringFromTable(@"payments", [UTIL getLanguage], @"")];
    
    _paymentTypes = [[NSMutableArray alloc] init];
    _payments = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _payments = [[NSMutableArray alloc] init];
    [UTIL showActivity:NSLocalizedStringFromTable(@"loading", [UTIL getLanguage], @"")];
    [self performSelector:@selector(reloadPaymentTypes) withObject:nil afterDelay:0.1f];
}

- (void)reloadPaymentTypes {
    [API getPaymentTypes:USER.sessionId completion:^(NSMutableArray *result) {
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqualToString: @""]) {
            for (id item in [result valueForKey:@"getPaymentTypesResult"]) {
                GenericObject *obj = [[GenericObject alloc] init];
                [obj initWithData:item];
                
                [self->_paymentTypes addObject:obj];
            }
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
            self->_paymentTypes = [[NSMutableArray alloc] init];
        }
        
        [self performSelector:@selector(reloadPayments) withObject:nil afterDelay:0.1f];
    }];
}

- (void)reloadPayments {
    [API getTransactionList:USER.sessionId regionId:_claim.regionId claimIndx:_claim.claimIndx completion:^(NSMutableArray *result) {
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqualToString: @""]) {
            for (id item in [result valueForKey:@"getTransactionListResult"]) {
                GenericObject *pmt = [[GenericObject alloc] init];
                [pmt initWithData:item];
                
                [self->_payments addObject:pmt];
            }
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
            self->_payments = [[NSMutableArray alloc] init];
        }
        
        [UTIL hideActivity];
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _payments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedStringFromTable(@"payment_history", [UTIL getLanguage], @"");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    GenericObject *item = (GenericObject *)[_payments objectAtIndex:[indexPath row]];
    [cell.textLabel setText:[NSString localizedStringWithFormat:@"$ %.2f", [item.value floatValue]]];
    
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"Transaction #%@\nDate: %@", item.parentId, item.code]];
    [cell.detailTextLabel setNumberOfLines:-1];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"addPayment"]) {
        PaymentViewController *child = (PaymentViewController *)[segue destinationViewController];
        [child setClaim:_claim];
        [child setPaymentTypes:_paymentTypes];
    }
}

@end
