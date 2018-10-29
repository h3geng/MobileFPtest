//
//  PaymentViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2016-01-26.
//  Copyright © 2016 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayPalMobile.h"
#import "PaymentTypesViewController.h"

@interface PaymentViewController : UITableViewController <PayPalPaymentDelegate>

@property (nonatomic, strong, readwrite) PayPalConfiguration *payPalConfiguration;
@property Claim *claim;

@property NSMutableArray *paymentTypes;
@property GenericObject *paymentType;

@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *typeCell;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;

@property (weak, nonatomic) IBOutlet UITextField *amountTextfield;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextfield;

@end
