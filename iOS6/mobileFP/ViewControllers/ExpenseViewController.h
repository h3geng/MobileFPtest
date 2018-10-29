//
//  ExpenseViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-03-16.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Expense.h"
#import "Claim.h"
#import "ExpenseCollectionsViewController.h"
#import "ReceiptViewController.h"

@interface ExpenseViewController : BaseTableViewController <UITextFieldDelegate, UITextViewDelegate>

@property Expense *expense;

@property BOOL expenseMethodsVisible;

@property int expenseType; // 0-simple, 1-job
@property BOOL expenseTypesVisible;

@property UIDatePicker *pickerDate;
@property BOOL expenseDatePickerVisible;

@property int collectionType;
@property NSString *selectedId;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionsButton;
- (IBAction)actionsPressed:(id)sender;

@end
