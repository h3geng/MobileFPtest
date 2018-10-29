//
//  ExpensesViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-01-17.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Expense.h"
#import "ExpenseViewController.h"

@interface ExpensesViewController : BaseTableViewController

@property NSMutableArray *items;
@property NSMutableArray *corporateItems;
@property NSMutableArray *mileageItems;
@property NSMutableArray *personalItems;

@property Expense *selectedExpense;
@property int statusFilter;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
- (IBAction)addPressed:(id)sender;

@end
