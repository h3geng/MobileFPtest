//
//  PaymentsViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2016-01-26.
//  Copyright © 2016 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaymentViewController.h"

@interface PaymentsViewController : UITableViewController

@property NSMutableArray *payments;
@property NSMutableArray *paymentTypes;
@property Claim *claim;

@end
