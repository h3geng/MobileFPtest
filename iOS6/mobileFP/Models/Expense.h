//
//  Expense.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-03-21.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface Expense : BaseModel

@property int selfId;
@property NSString *employeeGUID;
@property double totalAmount;
@property double tip;
@property NSString *dateExpense;
@property int expenseMethodId;
@property NSString *merchant;
@property int mileage;
@property int mileageTypeId;
@property NSString *comments;
@property NSString *destinations;
@property NSString *expenseMethodName;
@property int creditCardId;
@property NSString *cardNumber;
@property NSString *province;
@property NSString *provinceName;
@property int branchId;
@property NSString *branchName;
@property int departmentId;
@property NSString *departmentName;
@property int gpCategoryId;
@property NSString *expenseCategoryName;
@property int currencyId;
@property int claimIndx;
@property NSString *claimName;
@property int phaseIndx;
@property NSString *phaseName;
@property NSString *jobDepartmentId;
@property NSString *jobDepartmentName;
@property NSString *typeId;
@property NSString *typeName;
@property NSString *costCategoryId;
@property NSString *costCategoryName;
@property int expStatus;

+ (Expense *)getInstance;
- (id)init;
- (void)initWithData:(NSMutableArray *)data;
- (void)load:(void(^)(NSMutableArray *result))callback;
- (void)save:(void(^)(NSMutableArray *result))callback;

@end
