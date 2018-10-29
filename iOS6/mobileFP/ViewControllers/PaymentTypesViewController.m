//
//  PaymentTypesViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2016-01-26.
//  Copyright © 2016 FirstOnSite. All rights reserved.
//

#import "PaymentTypesViewController.h"

@interface PaymentTypesViewController ()

@end

@implementation PaymentTypesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setTitle:NSLocalizedStringFromTable(@"payment_types", [UTIL getLanguage], @"")];
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
    return _paymentTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    GenericObject *item = [_paymentTypes objectAtIndex:[indexPath row]];
    [cell.textLabel setText:item.value];
    
    if ([item.genericId isEqualToString:_selectedPaymentType.genericId]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    GenericObject *item = [_paymentTypes objectAtIndex:[indexPath row]];
    
    PaymentViewController *parent = (PaymentViewController *)[self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count - 2)];
    [parent setPaymentType:item];
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
