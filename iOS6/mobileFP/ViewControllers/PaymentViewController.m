//
//  PaymentViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2016-01-26.
//  Copyright © 2016 FirstOnSite. All rights reserved.
//

#import "PaymentViewController.h"

@interface PaymentViewController ()

@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setTitle:NSLocalizedStringFromTable(@"payment", [UTIL getLanguage], @"")];
    
    // PayPal
    _payPalConfiguration = [[PayPalConfiguration alloc] init];
    _payPalConfiguration.rememberUser = NO;
    _payPalConfiguration.presentingInPopover = YES;
    _payPalConfiguration.merchantName = @"FirstOnSite Restoration LP";
    _payPalConfiguration.payPalShippingAddressOption = PayPalShippingAddressOptionNone;
    
    _paymentType = [[GenericObject alloc] init];
    if (_paymentTypes.count > 0) {
        _paymentType = (GenericObject *)[_paymentTypes objectAtIndex:0];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Start out working with the test environment! When you are ready, switch to PayPalEnvironmentProduction.
    [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentSandbox];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows;
    
    switch (section) {
        case 0:
            numberOfRows = 3;
            break;
        default:
            numberOfRows = 1;
            break;
    }
    
    return numberOfRows;
}
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"amountCell" forIndexPath:indexPath];
    
    return cell;
}
*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    switch ([indexPath section]) {
        case 0:
            if ([indexPath row] == 1) {
                [self performSegueWithIdentifier:@"showPaymentTypes" sender:self];
            }
            break;
        default:
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self processPayment];
            break;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        switch ([indexPath row]) {
            case 0:
                break;
            case 1:
                [_typeLabel setText:_paymentType.value];
                break;
            default:
                [_descriptionTextfield.layer setBorderColor:[[UIColor colorWithRed:220.0/255.0
                                                                             green:220.0/255.0
                                                                              blue:220.0/255.0
                                                                             alpha:1.0] CGColor]];
                [_descriptionTextfield.layer setBorderWidth:1.0];
                [_descriptionTextfield.layer setCornerRadius:5.0f];
                break;
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showPaymentTypes"]) {
        PaymentTypesViewController *child = (PaymentTypesViewController *)[segue destinationViewController];
        [child setPaymentTypes:_paymentTypes];
        [child setSelectedPaymentType:_paymentType];
    }
}

- (void)processPayment {
    UITextField *amt = (UITextField *)[self.tableView viewWithTag:1];
    if ([[UTIL trim:amt.text] isEqual:@""]) {
        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"amount_field_can_not_be_empty", [UTIL getLanguage], @"")];
    } else {
        // Create a PayPalPayment
        PayPalPayment *payment = [[PayPalPayment alloc] init];
        UITextField *amt = (UITextField *)[self.tableView viewWithTag:1];
        
        PayPalItem *item = [[PayPalItem alloc] init];
        item.name = [NSString stringWithFormat:@"Claim # %@", _claim.claimNumber];
        item.quantity = 1;
        item.currency = @"CAD";
        item.price = [[NSDecimalNumber alloc] initWithString:amt.text];
        item.sku = @"options here for payment";
        
        // Amount, currency, and description
        payment.amount = [[NSDecimalNumber alloc] initWithString:amt.text];
        payment.currencyCode = @"CAD";
        payment.invoiceNumber = @"inv0001";
        payment.shortDescription = _claim.claimNumber;
        payment.custom = @"Custom field"; // Optional text, for your tracking purposes. (up to 256 characters)
        payment.softDescriptor = @"FOS Canada"; // Optional text which will appear on the customer's credit card statement.
        payment.bnCode = @"123"; // Optional Build Notation code ("BN code")
        
        payment.items = @[item];
        
        // Use the intent property to indicate that this is a "sale" payment,
        // meaning combined Authorization + Capture.
        // To perform Authorization only, and defer Capture to your server,
        // use PayPalPaymentIntentAuthorize.
        // To place an Order, and defer both Authorization and Capture to
        // your server, use PayPalPaymentIntentOrder.
        // (PayPalPaymentIntentOrder is valid only for PayPal payments, not credit card payments.)
        payment.intent = PayPalPaymentIntentSale;
        
        // If your app collects Shipping Address information from the customer,
        // or already stores that information on your server, you may provide it here.
        // payment.shippingAddress = @""; // a previously-created PayPalShippingAddress object
        
        // Several other optional fields that you can set here are documented in PayPalPayment.h,
        // including paymentDetails, items, invoiceNumber, custom, softDescriptor, etc.
        
        // Check whether payment is processable.
        if (!payment.processable) {
            // If, for example, the amount was negative or the shortDescription was empty, then
            // this payment would not be processable. You would want to handle that here.
        }
        
        PayPalPaymentViewController *paymentViewController;
        paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment configuration:_payPalConfiguration delegate:self];
        
        // Present the PayPalPaymentViewController.
        [self presentViewController:paymentViewController animated:YES completion:nil];
    }
}

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    // Payment was processed successfully; send to server for verification and fulfillment.
    [self verifyCompletedPayment:completedPayment];
    
    // Dismiss the PayPalPaymentViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    // The payment was canceled; dismiss the PayPalPaymentViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)verifyCompletedPayment:(PayPalPayment *)completedPayment {
    // Send the entire confirmation dictionary
    NSData *confirmation = [NSJSONSerialization dataWithJSONObject:completedPayment.confirmation options:0 error:nil];
    
    // Send confirmation to your server; your server should verify the proof of payment
    // and give the user their goods or services. If the server is not reachable, save
    // the confirmation and try again later.
    [self sendCompletedPaymentToServer:confirmation];
}

#pragma mark Proof of payment validation

- (void)sendCompletedPaymentToServer:(NSData *)confirmation {
    [UTIL showActivity:NSLocalizedStringFromTable(@"loading", [UTIL getLanguage], @"")];
    [self performSelector:@selector(sendToServer:) withObject:confirmation afterDelay:0.1f];
}

- (void)sendToServer:(NSData *)confirmation {
    NSString *results = [[NSString alloc] initWithData:confirmation encoding:NSUTF8StringEncoding];
    NSData *resultsData = [results dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *responseData = [NSJSONSerialization JSONObjectWithData:resultsData options:NSJSONReadingMutableContainers error:nil];
    
    NSString *transactionId = [[responseData valueForKey:@"response"] valueForKey:@"id"];
    //NSString *state = [[responseData valueForKey:@"response"] valueForKey:@"state"];
    
    NSString *create_time = [[responseData valueForKey:@"response"] valueForKey:@"create_time"];
    create_time = [create_time stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    create_time = [create_time stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    
    UITextField *amt = (UITextField *)[self.tableView viewWithTag:1];
    
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd"];
    
    [API savePayment:USER.sessionId regionId:_claim.regionId claimIndx:_claim.claimIndx _paymentTypeId:[_paymentType.genericId intValue] customerName:_claim.projectName customerEmail:@"" amount:[amt.text floatValue] transactionId:transactionId transactionDate:create_time message:_descriptionTextfield.text deviceId:@"" deviceDate:[df stringFromDate:[NSDate date]] completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

@end
