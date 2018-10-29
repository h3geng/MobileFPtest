//
//  PaymentTypesViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2016-01-26.
//  Copyright © 2016 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaymentViewController.h"

@interface PaymentTypesViewController : UITableViewController

@property NSMutableArray *paymentTypes;
@property GenericObject *selectedPaymentType;

@end
