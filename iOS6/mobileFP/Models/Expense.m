//
//  Expense.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-03-21.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import "Expense.h"

@implementation Expense

+ (Expense *)getInstance {
    SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id)init {
    self = [super init];
    if (self) {
        _selfId = 0;
        _employeeGUID = @"";
        _totalAmount = 0;
        _tip = 0;
        _dateExpense = [UTIL formatDateOnly:[NSDate date] format:@"yyyy-MM-dd"];
        _expenseMethodId = 0;
        _merchant = @"";
        _mileage = 0;
        _mileageTypeId = 1;
        _comments = @"";
        _destinations = @"";
        _expenseMethodName = @"";
        _creditCardId = 0;
        _cardNumber = @"";
        _province = @"";
        _provinceName = @"";
        _branchId = 0;
        _branchName = @"";
        _departmentId = 0;
        _departmentName = @"";
        _gpCategoryId = 0;
        _expenseCategoryName = @"";
        _currencyId = 0;
        _claimIndx = 0;
        _claimName = @"";
        _phaseIndx = 0;
        _phaseName = @"";
        _jobDepartmentId = @"";
        _jobDepartmentName = @"";
        _typeId = @"";
        _typeName = @"";
        _costCategoryId = @"";
        _costCategoryName = @"";
        _expStatus = 1;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:_selfId forKey:@"selfId"];
    [encoder encodeObject:_employeeGUID forKey:@"employeeGUID"];
    [encoder encodeDouble:_totalAmount forKey:@"totalAmount"];
    [encoder encodeDouble:_tip forKey:@"tip"];
    [encoder encodeObject:_dateExpense forKey:@"dateExpense"];
    [encoder encodeInt:_expenseMethodId forKey:@"expenseMethodId"];
    [encoder encodeObject:_merchant forKey:@"merchant"];
    [encoder encodeInt:_mileage forKey:@"mileage"];
    [encoder encodeInt:_mileageTypeId forKey:@"mileageTypeId"];
    [encoder encodeObject:_comments forKey:@"comments"];
    [encoder encodeObject:_destinations forKey:@"destinations"];
    [encoder encodeObject:_expenseMethodName forKey:@"expenseMethodName"];
    [encoder encodeInt:_creditCardId forKey:@"creditCardId"];
    [encoder encodeObject:_cardNumber forKey:@"cardNumber"];
    [encoder encodeObject:_province forKey:@"province"];
    [encoder encodeObject:_provinceName forKey:@"provinceName"];
    [encoder encodeInt:_branchId forKey:@"branchId"];
    [encoder encodeObject:_branchName forKey:@"branchName"];
    [encoder encodeInt:_departmentId forKey:@"departmentId"];
    [encoder encodeObject:_departmentName forKey:@"departmentName"];
    [encoder encodeInt:_gpCategoryId forKey:@"gpCategoryId"];
    [encoder encodeObject:_expenseCategoryName forKey:@"expenseCategoryName"];
    [encoder encodeInt:_currencyId forKey:@"currencyId"];
    [encoder encodeInt:_claimIndx forKey:@"claimIndx"];
    [encoder encodeObject:_claimName forKey:@"claimName"];
    [encoder encodeInt:_phaseIndx forKey:@"phaseIndx"];
    [encoder encodeObject:_phaseName forKey:@"phaseName"];
    [encoder encodeObject:_jobDepartmentId forKey:@"jobDepartmentId"];
    [encoder encodeObject:_jobDepartmentName forKey:@"jobDepartmentName"];
    [encoder encodeObject:_typeId forKey:@"typeId"];
    [encoder encodeObject:_typeName forKey:@"typeName"];
    [encoder encodeObject:_costCategoryId forKey:@"costCategoryId"];
    [encoder encodeObject:_costCategoryName forKey:@"costCategoryName"];
    [encoder encodeInt:_expStatus forKey:@"expStatus"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _selfId = [decoder decodeIntForKey:@"selfId"];
        _employeeGUID = [decoder decodeObjectForKey:@"employeeGUID"];
        _totalAmount = [decoder decodeDoubleForKey:@"totalAmount"];
        _tip = [decoder decodeDoubleForKey:@"tip"];
        _dateExpense = [decoder decodeObjectForKey:@"dateExpense"];
        _expenseMethodId = [decoder decodeIntForKey:@"expenseMethodId"];
        _merchant = [decoder decodeObjectForKey:@"merchant"];
        _mileage = [decoder decodeIntForKey:@"mileage"];
        _mileageTypeId = [decoder decodeIntForKey:@"mileageTypeId"];
        _comments = [decoder decodeObjectForKey:@"comments"];
        _destinations = [decoder decodeObjectForKey:@"destinations"];
        _expenseMethodName = [decoder decodeObjectForKey:@"expenseMethodName"];
        _creditCardId = [decoder decodeIntForKey:@"creditCardId"];
        _cardNumber = [decoder decodeObjectForKey:@"cardNumber"];
        _province = [decoder decodeObjectForKey:@"province"];
        _provinceName = [decoder decodeObjectForKey:@"provinceName"];
        _branchId = [decoder decodeIntForKey:@"branchId"];
        _branchName = [decoder decodeObjectForKey:@"branchName"];
        _departmentId = [decoder decodeIntForKey:@"departmentId"];
        _departmentName = [decoder decodeObjectForKey:@"departmentName"];
        _gpCategoryId = [decoder decodeIntForKey:@"gpCategoryId"];
        _expenseCategoryName = [decoder decodeObjectForKey:@"expenseCategoryName"];
        _currencyId = [decoder decodeIntForKey:@"currencyId"];
        _claimIndx = [decoder decodeIntForKey:@"claimIndx"];
        _claimName = [decoder decodeObjectForKey:@"claimName"];
        _phaseIndx = [decoder decodeIntForKey:@"phaseIndx"];
        _phaseName = [decoder decodeObjectForKey:@"phaseName"];
        _jobDepartmentId = [decoder decodeObjectForKey:@"jobDepartmentId"];
        _jobDepartmentName = [decoder decodeObjectForKey:@"jobDepartmentName"];
        _typeId = [decoder decodeObjectForKey:@"typeId"];
        _typeName = [decoder decodeObjectForKey:@"typeName"];
        _costCategoryId = [decoder decodeObjectForKey:@"costCategoryId"];
        _costCategoryName = [decoder decodeObjectForKey:@"costCategoryName"];
        _expStatus = [decoder decodeIntForKey:@"expStatus"];
    }
    return self;
}

- (void)initWithData:(NSMutableArray *)data {
    if (data) {
        _selfId = [[data valueForKey:@"Id"] intValue];
        _employeeGUID = [data valueForKey:@"EmployeeGUID"];
        _totalAmount = [[data valueForKey:@"TotalAmount"] doubleValue];
        _tip = [[data valueForKey:@"Tip"] doubleValue];
        
        NSArray *stringDateArray = [[data valueForKey:@"DateExpense"] componentsSeparatedByString: @" "];
        _dateExpense = stringDateArray[0];
        
        _expenseMethodId = [[data valueForKey:@"ExpenseMethodId"] intValue];
        _merchant = [[data valueForKey:@"Merchant"] isEqual:[NSNull null]] ? @"" : [data valueForKey:@"Merchant"];
        
        _mileage = [[data valueForKey:@"Mileage"] intValue];
        _mileageTypeId = [[data valueForKey:@"MileageTypeId"] intValue];
        _comments = [data valueForKey:@"Comments"];
        _destinations = [data valueForKey:@"Destinations"];
        _expenseMethodName = [data valueForKey:@"ExpenseMethodName"];
        _creditCardId = [[data valueForKey:@"CreditCardId"] intValue];
        _cardNumber = [data valueForKey:@"CardNumber"];
        _province = [data valueForKey:@"Province"];
        _provinceName = [data valueForKey:@"ProvinceName"];
        _branchId = [[data valueForKey:@"BranchId"] intValue];
        _branchName = [data valueForKey:@"BranchName"];
        _departmentId = [[data valueForKey:@"DepartmentId"] intValue];
        _departmentName = [data valueForKey:@"DepartmentName"];
        _gpCategoryId = [[data valueForKey:@"GPCategoryId"] intValue];
        _expenseCategoryName = [data valueForKey:@"ExpenseCategoryName"];
        _currencyId = [[data valueForKey:@"CurrencyId"] intValue];
        _claimIndx = [[data valueForKey:@"ClaimIndx"] intValue];
        _claimName = [data valueForKey:@"ClaimName"];
        _phaseIndx = [[data valueForKey:@"PhaseIndx"] intValue];
        _phaseName = [data valueForKey:@"PhaseName"];
        _jobDepartmentId = [data valueForKey:@"JobDepartmentId"];
        _jobDepartmentName = [data valueForKey:@"JobDepartmentName"];
        _typeId = [data valueForKey:@"TypeId"];
        _typeName = [data valueForKey:@"TypeName"];
        _costCategoryId = [data valueForKey:@"CostCategoryId"];
        _costCategoryName = [data valueForKey:@"CostCategoryName"];
        _expStatus = [[data valueForKey:@"ExpStatus"] intValue];
    }
}

- (void)load:(void(^)(NSMutableArray *result))callback {
    [API getExpense:USER.sessionId expenseId:_selfId completion:^(NSMutableArray *result) {
        //[self initWithData:[result valueForKey:@"getExpenseResult"]];
        callback([result valueForKey:@"getExpenseResult"]);
    }];
}

- (void)save:(void(^)(NSMutableArray *result))callback {
    NSError* error = nil;
    NSDictionary *selfDictionary = [self dictionaryReflectFromAttributes];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:selfDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    [API saveExpense:USER.sessionId expenseObject:jsonString completion:^(NSMutableArray *result) {
        callback(result);
    }];
}

@end
