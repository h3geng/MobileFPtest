//
//  Api.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 7/30/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "Api.h"

@implementation Api

/**
 * Gets the instance of self object.
 *
 * @return instance object.
 */
+ (Api *)getInstance {
    SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id)init {
    self = [super init];
    if (self) {
        if ([APP_MODE isEqual: @"1"]) {
            self.url = PRODUCTION_URL;
        } else {
            self.url = TEST_URL;
        }
    }
    return self;
}

- (void)call:(NSString *)path action:(NSString *)action type:(NSString *)type params:(NSString *)params completion:(void(^)(NSMutableArray* result))completion {
    NSString *url = [NSString stringWithFormat:self.url, path, action];
    NSData *postData = [params dataUsingEncoding:NSUTF8StringEncoding];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0f];
    [request setHTTPMethod:type];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data == nil) {
            completion(nil);
            return;
        }
        
        NSData *resultsData;
        NSMutableArray *responseData;
        if (error) {
            resultsData = [[NSString stringWithFormat:@"{\"error\":\"%@\"}", [error localizedDescription]] dataUsingEncoding:NSUTF8StringEncoding];
            responseData = [NSJSONSerialization JSONObjectWithData:resultsData options:NSJSONReadingMutableContainers error:&error];
        } else {
            NSString *results = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            resultsData = [results dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            responseData = [NSJSONSerialization JSONObjectWithData:resultsData options:NSJSONReadingMutableLeaves error:&error];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            completion(responseData);
        });
    }];
    
    [dataTask resume];
}

- (void)login:(NSString *)username password:(NSString *)password regionId:(int)regionId location:(CLLocation *)location completion:(void(^)(NSMutableArray* result))completion {
    NSString *devInfoString = [NSString stringWithFormat:@"{\"id\":\"\",\"lat\":%f,\"lon\":%f,\"debug\":\"\"}",(location) ? location.coordinate.latitude : 0.0, (location) ? location.coordinate.longitude : 0.0];
    NSString *stringParams = [NSString stringWithFormat:@"{\"username\":\"%@\",\"password\":\"%@\",\"regionId\":%d, \"info\":%@}", username, password, regionId, devInfoString];
    
    [self call:@"mobileservice.svc" action:@"login" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getRegions:(void(^)(NSMutableArray* result))completion {
    [self call:@"mobileservice.svc" action:@"getRegions" type:@"POST" params:@"" completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)updateDeviceLocation:(NSString *)sessionId location:(CLLocation *)location completion:(void(^)(NSMutableArray* result))completion {
    NSString *devInfoString = [NSString stringWithFormat:@"{\"id\":\"\",\"lat\":%f,\"lon\":%f,\"debug\":\"\"}", location.coordinate.latitude, location.coordinate.longitude];
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"info\":%@}", sessionId, devInfoString];
    [self call:@"mobileService.svc" action:@"updateDeviceLocation" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)loginWithUserName:(NSString *)username password:(NSString *)password regionId:(int)regionId location:(CLLocation *)location completion:(void(^)(NSMutableArray* result))completion {
    NSString *devInfoString = [NSString stringWithFormat:@"{\"id\":\"\",\"lat\":%f,\"lon\":%f,\"debug\":\"\"}",(location) ? location.coordinate.latitude : 0.0, (location) ? location.coordinate.longitude : 0.0];
    NSString *stringParams = [NSString stringWithFormat:@"{\"username\":\"%@\",\"password\":\"%@\",\"regionId\":%d, \"info\":%@}", username, password, regionId, devInfoString];
    [self call:@"mobileService.svc" action:@"login" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)loadUser:(NSString *)sessionId userGUID:(NSString *)userGUID completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"userGUID\":\"%@\"}", sessionId, userGUID];
    [self call:@"mobileService.svc" action:@"loadUser" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)registerNotify:(NSString *)sessionId userGUID:(NSString *)userGUID deviceToken:(NSString *)deviceToken completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"userGUID\":\"%@\",\"deviceId\":\"%@\"}", sessionId, userGUID, deviceToken];
    [self call:@"mobileService.svc" action:@"registerNotify" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)unregisterNotify:(NSString *)sessionId userGUID:(NSString *)userGUID deviceToken:(NSString *)deviceToken completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"userGUID\":\"%@\",\"deviceId\":\"%@\"}", sessionId, userGUID, deviceToken];
    [self call:@"mobileService.svc" action:@"unRegisterNotify" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)findItem:(NSString *)sessionId regionId:(int)regionId branchName:(NSString *)branchName searchString:(NSString *)searchString completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":%d,\"branchName\":\"%@\",\"searchStr\":\"%@\"}", sessionId, regionId, branchName, searchString];
    [self call:@"mobileService.svc" action:@"findItem" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)findItemExact:(NSString *)sessionId regionId:(int)regionId branchName:(NSString *)branchName searchString:(NSString *)searchString completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":%d,\"branchName\":\"%@\",\"searchStr\":\"%@\"}", sessionId, regionId, branchName, searchString];
    [self call:@"mobileService.svc" action:@"findItemExact" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)findJob:(NSString *)sessionId regionId:(int)regionId branchCode:(NSString *)branchCode userCode:(NSString *)userCode searchString:(NSString *)searchString completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":%d,\"branchCode\":\"%@\",\"userCode\":\"%@\",\"searchStr\":\"%@\"}",sessionId, regionId, branchCode, userCode, searchString];
    [self call:@"mobileService.svc" action:@"findJob" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)findUserClaims:(NSString *)sessionId regionId:(int)regionId branchCode:(NSString *)branchCode userName:(NSString *)userName completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":%d,\"branchCode\":\"%@\",\"userName\":\"%@\"}",sessionId, regionId, branchCode, userName];
    [self call:@"mobileService.svc" action:@"findUserClaims" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)findClosestJobs:(NSString *)sessionId regionId:(int)regionId brnachCode:(NSString *)branchCode userCode:(NSString *)userCode location:(CLLocation *)location completion:(void(^)(NSMutableArray* result))completion {
    NSString *devInfoString = [NSString stringWithFormat:@"{\"id\":\"\",\"lat\":%f,\"lon\":%f,\"debug\":\"\"}", location.coordinate.latitude, location.coordinate.longitude];
    
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":%d,\"branchCode\":\"%@\",\"userCode\":\"%@\",\"info\":%@}", sessionId, regionId, branchCode, userCode, devInfoString];
    [self call:@"mobileService.svc" action:@"findClosestJobs" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getJob:(NSString *)sessionId regionId:(int)regionId claimIndex:(int)claimIndex completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":%d,\"claimIndx\":%d}", sessionId, regionId, claimIndex];
    [self call:@"mobileService.svc" action:@"getJob" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)reloadCompany:(int)companyId completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":%d,\"companyId\":%d,\"incContacts\":%@,\"incBranches\":%@}", USER.sessionId, USER.regionId, companyId, @"true", @"true"];
    [self call:@"mobileService.svc" action:@"getCompany" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getClaimPhotos:(NSString *)sessionId regionId:(int)regionId claimIndex:(int)claimIndex phaseIndex:(int)phaseIndex page:(int)page completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":%d,\"claimIndx\":%d,\"phaseIndx\":%d,\"page\":%d}", sessionId, regionId, claimIndex, phaseIndex, page];
    [self call:@"FileManager.aspx" action:@"getJobPhotos" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getJobNotes:(NSString *)sessionId regionId:(int)regionId claimIndex:(int)claimIndex phaseIndex:(int)phaseIndex departmentCode:(NSString *)departmentCode page:(int)page completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":%d,\"claimIndx\":%d,\"phaseIndx\":%d,\"deptId\":\"%@\",\"page\":%d}", sessionId, regionId, claimIndex, phaseIndex , departmentCode, page];
    [self call:@"messageService.svc" action:@"Get_JobNotes" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getBranches:(NSString *)sessionId regionId:(int)regionId completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":%d}", sessionId, regionId];
    [self call:@"mobileService.svc" action:@"getBranches" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getClasses:(NSString *)sessionId regionId:(int)regionId completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":%d}", sessionId, regionId];
    [self call:@"mobileService.svc" action:@"getClasses" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getModels:(NSString *)sessionId regionId:(int)regionId classIndex:(int)classIndex completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":%d,\"classIndx\":%d}", sessionId, regionId, classIndex];
    [self call:@"mobileService.svc" action:@"getModels" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getStatusList:(NSString *)sessionId regionId:(int)regionId completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":%d}", sessionId, regionId];
    [self call:@"mobileService.svc" action:@"getStatusList" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getEquipmentCostCategories:(NSString *)sessionId regionId:(int)regionId completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":%d}", sessionId, regionId];
    [self call:@"mobileService.svc" action:@"getEquipmentCostCategories" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)scanItem:(NSString *)sessionId location:(CLLocation *)location searchString:(NSString *)searchString completion:(void(^)(NSMutableArray* result))completion {
    NSString *devInfoString = [NSString stringWithFormat:@"{\"id\":\"\",\"lat\":%f,\"lon\":%f,\"debug\":\"\"}", location.coordinate.latitude, location.coordinate.longitude];
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"assetTag\":\"%@\",\"info\":%@}", sessionId, searchString, devInfoString];
    [self call:@"mobileService.svc" action:@"scanItem" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getItem:(NSString *)sessionId regionId:(int)regionId inventoryId:(int)inventoryId completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":%d,\"itemId\":%d}", sessionId, regionId, inventoryId];
    [self call:@"mobileService.svc" action:@"getItem" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)saveItem:(NSString *)sessionId regionId:(int)regionId location:(CLLocation *)location serviceRelatedContent:(NSString *)sercviceRelatedContent completion:(void(^)(NSMutableArray* result))completion {
    NSString *devInfoString = [NSString stringWithFormat:@"{\"id\":\"\",\"lat\":%f,\"lon\":%f,\"debug\":\"\"}", location.coordinate.latitude, location.coordinate.longitude];
    
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":%d,\"item\":%@,\"info\":%@}", sessionId, regionId, sercviceRelatedContent, devInfoString];
    [self call:@"mobileService.svc" action:@"saveItem" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)replaceAssetTag:(NSString *)sessionId regionId:(int)regionId inventoryId:(int)inventoryId newTag:(NSString *)tag completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":%d,\"itemId\":%d,\"newAssetTag\":\"%@\"}",sessionId,regionId,inventoryId, tag];
    [self call:@"mobileService.svc" action:@"replaceAssetTag" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getFileAlertSummary:(NSString *)sessionId ctUserId:(NSString *)ctUserId completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"CTUserId\":\"%@\"}",sessionId,ctUserId];
    [self call:@"mobileService.svc" action:@"getFileAlertSummary" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getFileAlertDetail:(NSString *)sessionId regionId:(int)regionId alertId:(int)alertId ctUserId:(NSString *)ctUserId completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":\"%d\",\"alertId\":%d,\"CTUserId\":\"%@\"}", sessionId, regionId, alertId,ctUserId];
    [self call:@"mobileService.svc" action:@"getFileAlertDetail" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)findContact:(NSString *)sessionId regionId:(int)regionId branchId:(int)branchId searchString:(NSString *)searchString typeList:(NSString *)typeList userType:(int)userType page:(int)page completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":%d,\"branchId\":%d,\"searchStr\":\"%@\",\"typelist\":\"%@\",\"userType\":%d,\"page\":%d}", sessionId, regionId, branchId, searchString, typeList, userType, page];
    [self call:@"mobileService.svc" action:@"findContact" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)findProductionEmployees:(NSString *)sessionId searchString:(NSString *)searchString completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"searchStr\":\"%@\"}", sessionId, searchString];
    [self call:@"mobileService.svc" action:@"findProductionEmployees" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

// TIMESHEET START

- (void)getNonBillableCategories:(NSString *)sessionId completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\"}", sessionId];
    [self call:@"timesheetService.svc" action:@"GetNonBillableCategories" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)saveTimeSheet:(NSString *)sessionId entryId:(int)entryId categoryId:(int)categoryId regionId:(int)regionId branchId:(int)branchId claimIndx:(int)claimIndx phaseIndx:(int)phaseIndx projectName:(NSString *)projectName costCategoryId:(NSString *)costCategoryId employeeId:(NSString *)employeeId dateStart:(NSString *)dateStart dateStop:(NSString *)dateStop hours:(double)hours note:(NSString *)note latitude:(float)latitude longitude:(float)longitude isMobile:(int)isMobile enteredById:(NSString *)enteredById modifiedById:(NSString *)modifiedById completion:(void(^)(NSMutableArray* result))completion {
    NSString *timesheetEntry = [NSString stringWithFormat:@"{\"entryId\":%d,\"categoryId\":%d,\"regionId\":%d,\"branchId\":%d,\"claimIndx\":%d,\"phaseIndx\":%d,\"projectName\":\"%@\",\"costCategoryId\":\"%@\",\"employeeId\":\"%@\",\"dateStart\":\"%@\",\"dateStop\":\"%@\",\"hours\":%0.1f,\"note\":\"%@\",\"latitude\":%f,\"longitude\":%f,\"isMobile\":%d,\"enteredById\":\"%@\",\"modifiedById\":\"%@\"}", entryId, categoryId, regionId, branchId, claimIndx, phaseIndx, projectName, costCategoryId, employeeId, dateStart, dateStop, hours, note, latitude, longitude, isMobile, enteredById, modifiedById];
    
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"timeEntry\":%@}", sessionId, timesheetEntry];
    [self call:@"timesheetService.svc" action:@"saveTimeSheetEntry" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)deleteTimeSheetEntry:(NSString *)sessionId entryId:(int)entryId completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"entryId\":%d}", sessionId, entryId];
    [self call:@"timesheetService.svc" action:@"deleteTimeSheetEntry" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)GetTimesheet:(NSString *)sessionId day:(NSString *)day completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\", \"day\":\"%@\"}", sessionId, day];
    [self call:@"timesheetService.svc" action:@"GetTimesheet" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

// TIMESHEET END

- (void)getNoteDepartment:(NSString *)sessionId regionId:(int)regionId completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":%d}", sessionId, regionId];
    [self call:@"Messaging.aspx" action:@"Get_NoteDepartments" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)addNoteToJob:(NSString *)sessionId regionId:(int)regionId claimIndex:(int)claimIndex phaseIndex:(int)phaseIndex departmentCode:(NSString *)departmentCode note:(NSString *)note alertPM:(NSString *)alertPM completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":%d,\"claimIndx\":%d,\"phaseIndx\":%d,\"departmentId\":\"%@\",\"note\":\"%@\",\"alertPM\":%@}", sessionId, regionId, claimIndex, phaseIndex, departmentCode, note, alertPM];
    [self call:@"Messaging.aspx" action:@"addNoteToJob" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)updateStatus:(NSString *)sessionId transactionList:(NSString *)transactionList completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"transactionList\":%@}", sessionId, transactionList];
    [self call:@"mobileService.svc" action:@"updateStatus" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getJobWorkorders:(NSString *)sessionId claimIndx:(int)claimIndx completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"claimIndx\":%d}", sessionId, claimIndx];
    [self call:@"mobileService.svc" action:@"getJobWorkorders" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getPaymentTypes:(NSString *)sessionId completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\"}", sessionId];
    [self call:@"webPayService.svc" action:@"getPaymentTypes" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)savePayment:(NSString *)sessionId regionId:(int)regionId claimIndx:(int)claimIndx _paymentTypeId:(int)_paymentTypeId customerName:(NSString *)customerName customerEmail:(NSString *)customerEmail amount:(float)amount transactionId:(NSString *)transactionId transactionDate:(NSString *)transactionDate message:(NSString *)message deviceId:(NSString *)deviceId deviceDate:(NSString *)deviceDate completion:(void(^)(NSMutableArray* result))completion {
    NSString *paymentEntry = [NSString stringWithFormat:@"{\"regionId\":%d,\"claimIndx\":%d,\"phaseIndx\":0,\"providerId\":1,\"paymentTypeId\":%d,\"customerName\":\"%@\",\"customerEmail\":\"%@\",\"isInterim\":false,\"amount\":%f,\"transactionId\":\"%@\",\"transactionDate\":\"%@\",\"statusId\":1,\"message\":\"%@\",\"deviceId\":\"%@\",\"deviceDate\":\"%@\"}", regionId, claimIndx, _paymentTypeId, customerName, customerEmail, amount, transactionId, transactionDate, message, deviceId, deviceDate];
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"transaction\":%@}", sessionId, paymentEntry];
    [self call:@"webPayService.svc" action:@"saveTransaction" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getTransactionList:(NSString *)sessionId regionId:(int)regionId claimIndx:(int)claimIndx completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":%d,\"claimIndx\":%d}", sessionId, regionId, claimIndx];
    [self call:@"webPayService.svc" action:@"getTransactionList" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)projectChats:(NSString *)sessionId regionId:(int)regionId claimIndx:(int)claimIndx completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"userGUID\":\"%@\",\"regionId\":%d,\"claimIndx\":%d}", sessionId, USER.userId, regionId, claimIndx];
    [self call:@"mobileService.svc" action:@"get_Messages" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)projectLastMessage:(NSString *)sessionId regionId:(int)regionId claimIndx:(int)claimIndx completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"userGUID\":\"%@\",\"regionId\":%d,\"claimIndx\":%d}", sessionId, USER.userId, regionId, claimIndx];
    [self call:@"mobileService.svc" action:@"get_LastMessage" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)sendMessage:(NSString *)sessionId claimIndx:(NSString *)claimIndx messageBody:(NSString *)messageBody parentId:(int)parentId regionId:(NSString *)regionId subject:(NSString *)subject completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\", \"message\": {\"ClaimIndx\":%@,\"MessageBody\":\"%@\",\"ParentId\":%d,\"RegionId\":%@,\"SenderGUID\":\"%@\",\"Subject\":\"%@\"}}", sessionId, claimIndx, messageBody, parentId, regionId, USER.userId, subject];
    [self call:@"mobileService.svc" action:@"save_Message" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getExpenseTypes:(NSString *)sessionId completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\"}", sessionId];
    [self call:@"mobileService.svc" action:@"getExpenseTypes" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getExpenseDepartments:(NSString *)sessionId regionId:(int)regionId branchId:(int)branchId categoryId:(int)categoryId completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":%d,\"branchId\":%d,\"categoryId\":%d}", sessionId, regionId, branchId, categoryId];
    [self call:@"mobileService.svc" action:@"getExpenseDepartments" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getCreditCards:(NSString *)sessionId userId:(NSString *)userId completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\", \"userId\":\"%@\"}", sessionId, userId];
    [self call:@"mobileService.svc" action:@"getCreditCards" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getCategories:(NSString *)sessionId completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\"}", sessionId];
    [self call:@"mobileService.svc" action:@"getCategories" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getProvinces:(NSString *)sessionId completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\"}", sessionId];
    [self call:@"mobileService.svc" action:@"getProvinces" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getExpenses:(NSString *)sessionId userGUID:(NSString *)userGUID status:(NSString *)status completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"userGUID\":\"%@\",\"status\":\"%@\"}", sessionId, userGUID, status];
    [self call:@"mobileService.svc" action:@"getExpenses" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getExpense:(NSString *)sessionId expenseId:(int)expenseId completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"id\":%d}", sessionId, expenseId];
    [self call:@"mobileService.svc" action:@"getExpense" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getExpenseReceipt:(NSString *)sessionId expenseId:(int)expenseId completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"id\":%d}", sessionId, expenseId];
    [self call:@"mobileService.svc" action:@"getExpenseReceipt" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getExpenseMileageRate:(NSString *)sessionId completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\"}", sessionId];
    [self call:@"mobileService.svc" action:@"getExpenseMileageRate" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)saveExpense:(NSString *)sessionId expenseObject:(NSString *)expenseObject completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"expense\":%@}", sessionId, expenseObject];
    [self call:@"mobileService.svc" action:@"saveExpense" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getJobDepartments:(NSString *)sessionId regionId:(int)regionId completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":%d}", sessionId, regionId];
    [self call:@"mobileService.svc" action:@"getJobDepartments" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getJobCostTypes:(NSString *)sessionId regionId:(int)regionId completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":%d}", sessionId, regionId];
    [self call:@"mobileService.svc" action:@"getJobCostTypes" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getJobCostCategories:(NSString *)sessionId regionId:(int)regionId departmentId:(NSString *)departmentId jobCostTypeId:(NSString *)jobCostTypeId completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":%d,\"departmentId\":\"%@\",\"jobCostTypeId\":\"%@\"}", sessionId, regionId, departmentId, jobCostTypeId];
    [self call:@"mobileService.svc" action:@"getJobCostCategories" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getOnCallBranches:(NSString *)sessionId userGUID:(NSString *)userGUID completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"userGUID\":\"%@\"}",sessionId, userGUID];
    [self call:@"mobileService.svc" action:@"getOnCallBranches" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)updateOnCallStatus:(NSString *)sessionId userGUID:(NSString *)userGUID status:(Boolean)status completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"userGUID\":\"%@\",\"status\":%hhu}",sessionId, userGUID, status];
    [self call:@"mobileService.svc" action:@"updateOnCallStatus" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)updateOnCallBranches:(NSString *)sessionId userGUID:(NSString *)userGUID branches:(NSString *)branches completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"userGUID\":\"%@\",\"branches\":\"%@\"}",sessionId, userGUID, branches];
    [self call:@"mobileService.svc" action:@"updateOnCallBranches" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getNoteDetails:(NSString *)sessionId regionId:(int)regionId claimId:(int)claimId noteId:(int)noteId completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"regionId\":%d,\"claimId\":%d,\"noteId\":%d}", sessionId, regionId, claimId, noteId];
    [self call:@"mobileService.svc" action:@"getNoteDetails" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)shareNote:(NSString *)sessionId shareObject:(Share *)shareObject completion:(void(^)(NSMutableArray* result))completion {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    for (GenericObject *item in shareObject.contacts) {
        [arr addObject:[NSString stringWithFormat:@"%@|%@", item.code, item.value]];
    }
    
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"senderGUID\":\"%@\",\"sendEmail\":%@,\"sendPushNotification\":%@,\"emails\":\"%@\",\"regionId\":%d,\"claimId\":%d,\"noteId\":%d}", sessionId, USER.userId, shareObject.sendEmail?@"true":@"false", shareObject.sendPushNotification?@"true":@"false", [arr componentsJoinedByString:@";"], shareObject.regionId, shareObject.claimId, shareObject.noteId];
    [self call:@"mobileService.svc" action:@"shareNote" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)searchFOSEmployee:(NSString *)sessionId searchStr:(NSString *)searchStr completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"searchStr\":\"%@\"}", sessionId, searchStr];
    [self call:@"mobileService.svc" action:@"searchFOSEmployee" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)searchBranches:(NSString *)sessionId term:(NSString *)term completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"term\":\"%@\"}", sessionId, term];
    [self call:@"mobileService.svc" action:@"searchBranches" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)updateUserDetail:(NSString *)sessionId userGUID:(NSString *)userGUID phone:(NSString *)phone completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"userGUID\":\"%@\",\"phone\":\"%@\"}", sessionId, userGUID, phone];
    [self call:@"mobileService.svc" action:@"updateUserDetail" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)updateUserPicture:(NSString *)sessionId userGUID:(NSString *)userGUID picture:(NSString *)picture thumbnail:(NSString *)thumbnail completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"userGUID\":\"%@\",\"picture\":\"%@\",\"thumbnail\":\"%@\"}", sessionId, userGUID, picture, thumbnail];
    [self call:@"mobileService.svc" action:@"updateUserPicture" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)deleteUserPicture:(NSString *)sessionId userGUID:(NSString *)userGUID completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"userGUID\":\"%@\"}", sessionId, userGUID];
    [self call:@"mobileService.svc" action:@"deleteUserPicture" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)getRecents:(NSString *)sessionId userGUID:(NSString *)userGUID isFOS:(NSString *)isFOS completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"userGUID\":\"%@\",\"isFOS\":%@}", sessionId, userGUID, isFOS];
    [self call:@"mobileService.svc" action:@"getRecents" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

- (void)deleteRecent:(NSString *)sessionId userGUID:(NSString *)userGUID email:(NSString *)email completion:(void(^)(NSMutableArray* result))completion {
    NSString *stringParams = [NSString stringWithFormat:@"{\"sessionId\":\"%@\",\"userGUID\":\"%@\",\"email\":\"%@\"}", sessionId, userGUID, email];
    [self call:@"mobileService.svc" action:@"deleteRecent" type:@"POST" params:stringParams completion:^(NSMutableArray *result) {
        completion(result);
    }];
}

@end
