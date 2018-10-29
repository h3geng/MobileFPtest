//
//  Api.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 7/30/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Api : NSObject

@property NSString *url;

+ (Api *)getInstance;
- (id)init;
- (void)call:(NSString *)path action:(NSString *)action type:(NSString *)type params:(NSString *)params completion:(void(^)(NSMutableArray* result))completion;
- (void)login:(NSString *)username password:(NSString *)password regionId:(int)regionId location:(CLLocation *)location completion:(void(^)(NSMutableArray* result))completion;
- (void)getRegions:(void(^)(NSMutableArray* result))completion;
- (void)updateDeviceLocation:(NSString *)sessionId location:(CLLocation *)location completion:(void(^)(NSMutableArray* result))completion;
- (void)loginWithUserName:(NSString *)username password:(NSString *)password regionId:(int)regionId location:(CLLocation *)location completion:(void(^)(NSMutableArray* result))completion;
- (void)loadUser:(NSString *)sessionId userGUID:(NSString *)userGUID completion:(void(^)(NSMutableArray* result))completion;
- (void)registerNotify:(NSString *)sessionId userGUID:(NSString *)userGUID deviceToken:(NSString *)deviceToken completion:(void(^)(NSMutableArray* result))completion;
- (void)unregisterNotify:(NSString *)sessionId userGUID:(NSString *)userGUID deviceToken:(NSString *)deviceToken completion:(void(^)(NSMutableArray* result))completion;
- (void)findItem:(NSString *)sessionId regionId:(int)regionId branchName:(NSString *)branchName searchString:(NSString *)searchString completion:(void(^)(NSMutableArray* result))completion;
- (void)findItemExact:(NSString *)sessionId regionId:(int)regionId branchName:(NSString *)branchName searchString:(NSString *)searchString completion:(void(^)(NSMutableArray* result))completion;
- (void)findJob:(NSString *)sessionId regionId:(int)regionId branchCode:(NSString *)branchCode userCode:(NSString *)userCode searchString:(NSString *)searchString completion:(void(^)(NSMutableArray* result))completion;
- (void)findUserClaims:(NSString *)sessionId regionId:(int)regionId branchCode:(NSString *)branchCode userName:(NSString *)userName completion:(void(^)(NSMutableArray* result))completion;
- (void)findClosestJobs:(NSString *)sessionId regionId:(int)regionId brnachCode:(NSString *)branchCode userCode:(NSString *)userCode location:(CLLocation *)location completion:(void(^)(NSMutableArray* result))completion;
- (void)getJob:(NSString *)sessionId regionId:(int)regionId claimIndex:(int)claimIndex completion:(void(^)(NSMutableArray* result))completion;
- (void)reloadCompany:(int)companyId completion:(void(^)(NSMutableArray* result))completion;
- (void)getClaimPhotos:(NSString *)sessionId regionId:(int)regionId claimIndex:(int)claimIndex phaseIndex:(int)phaseIndex page:(int)page completion:(void(^)(NSMutableArray* result))completion;
- (void)getJobNotes:(NSString *)sessionId regionId:(int)regionId claimIndex:(int)claimIndex phaseIndex:(int)phaseIndex departmentCode:(NSString *)departmentCode page:(int)page completion:(void(^)(NSMutableArray* result))completion;
- (void)getBranches:(NSString *)sessionId regionId:(int)regionId completion:(void(^)(NSMutableArray* result))completion;
- (void)getClasses:(NSString *)sessionId regionId:(int)regionId completion:(void(^)(NSMutableArray* result))completion;
- (void)getModels:(NSString *)sessionId regionId:(int)regionId classIndex:(int)classIndex completion:(void(^)(NSMutableArray* result))completion;
- (void)getStatusList:(NSString *)sessionId regionId:(int)regionId completion:(void(^)(NSMutableArray* result))completion;
- (void)getEquipmentCostCategories:(NSString *)sessionId regionId:(int)regionId completion:(void(^)(NSMutableArray* result))completion;
- (void)scanItem:(NSString *)sessionId location:(CLLocation *)location searchString:(NSString *)searchString completion:(void(^)(NSMutableArray* result))completion;
- (void)getItem:(NSString *)sessionId regionId:(int)regionId inventoryId:(int)inventoryId completion:(void(^)(NSMutableArray* result))completion;
- (void)saveItem:(NSString *)sessionId regionId:(int)regionId location:(CLLocation *)location serviceRelatedContent:(NSString *)sercviceRelatedContent completion:(void(^)(NSMutableArray* result))completion;
- (void)replaceAssetTag:(NSString *)sessionId regionId:(int)regionId inventoryId:(int)inventoryId newTag:(NSString *)tag completion:(void(^)(NSMutableArray* result))completion;
- (void)getFileAlertSummary:(NSString *)sessionId ctUserId:(NSString *)ctUserId completion:(void(^)(NSMutableArray* result))completion;
- (void)getFileAlertDetail:(NSString *)sessionId regionId:(int)regionId alertId:(int)alertId ctUserId:(NSString *)ctUserId completion:(void(^)(NSMutableArray* result))completion;
- (void)findContact:(NSString *)sessionId regionId:(int)regionId branchId:(int)branchId searchString:(NSString *)searchString typeList:(NSString *)typeList userType:(int)userType page:(int)page completion:(void(^)(NSMutableArray* result))completion;
- (void)findProductionEmployees:(NSString *)sessionId searchString:(NSString *)searchString completion:(void(^)(NSMutableArray* result))completion;
- (void)getNonBillableCategories:(NSString *)sessionId completion:(void(^)(NSMutableArray* result))completion;
- (void)saveTimeSheet:(NSString *)sessionId entryId:(int)entryId categoryId:(int)categoryId regionId:(int)regionId branchId:(int)branchId claimIndx:(int)claimIndx phaseIndx:(int)phaseIndx projectName:(NSString *)projectName costCategoryId:(NSString *)costCategoryId employeeId:(NSString *)employeeId dateStart:(NSString *)dateStart dateStop:(NSString *)dateStop hours:(double)hours note:(NSString *)note latitude:(float)latitude longitude:(float)longitude isMobile:(int)isMobile enteredById:(NSString *)enteredById modifiedById:(NSString *)modifiedById completion:(void(^)(NSMutableArray* result))completion;
- (void)GetTimesheet:(NSString *)sessionId day:(NSString *)day completion:(void(^)(NSMutableArray* result))completion;
- (void)deleteTimeSheetEntry:(NSString *)sessionId entryId:(int)entryId completion:(void(^)(NSMutableArray* result))completion;
- (void)getNoteDepartment:(NSString *)sessionId regionId:(int)regionId completion:(void(^)(NSMutableArray* result))completion;
- (void)addNoteToJob:(NSString *)sessionId regionId:(int)regionId claimIndex:(int)claimIndex phaseIndex:(int)phaseIndex departmentCode:(NSString *)departmentCode note:(NSString *)note alertPM:(NSString *)alertPM completion:(void(^)(NSMutableArray* result))completion;
- (void)updateStatus:(NSString *)sessionId transactionList:(NSString *)transactionList completion:(void(^)(NSMutableArray* result))completion;
- (void)getJobWorkorders:(NSString *)sessionId claimIndx:(int)claimIndx completion:(void(^)(NSMutableArray* result))completion;
- (void)getPaymentTypes:(NSString *)sessionId completion:(void(^)(NSMutableArray* result))completion;
- (void)savePayment:(NSString *)sessionId regionId:(int)regionId claimIndx:(int)claimIndx _paymentTypeId:(int)_paymentTypeId customerName:(NSString *)customerName customerEmail:(NSString *)customerEmail amount:(float)amount transactionId:(NSString *)transactionId transactionDate:(NSString *)transactionDate message:(NSString *)message deviceId:(NSString *)deviceId deviceDate:(NSString *)deviceDate completion:(void(^)(NSMutableArray* result))completion;
- (void)getTransactionList:(NSString *)sessionId regionId:(int)regionId claimIndx:(int)claimIndx completion:(void(^)(NSMutableArray* result))completion;
- (void)projectChats:(NSString *)sessionId regionId:(int)regionId claimIndx:(int)claimIndx completion:(void(^)(NSMutableArray* result))completion;
- (void)projectLastMessage:(NSString *)sessionId regionId:(int)regionId claimIndx:(int)claimIndx completion:(void(^)(NSMutableArray* result))completion;
- (void)sendMessage:(NSString *)sessionId claimIndx:(NSString *)claimIndx messageBody:(NSString *)messageBody parentId:(int)parentId regionId:(NSString *)regionId subject:(NSString *)subject completion:(void(^)(NSMutableArray* result))completion;

- (void)getExpenseTypes:(NSString *)sessionId completion:(void(^)(NSMutableArray* result))completion;
- (void)getExpenseDepartments:(NSString *)sessionId regionId:(int)regionId branchId:(int)branchId categoryId:(int)categoryId completion:(void(^)(NSMutableArray* result))completion;
- (void)getCreditCards:(NSString *)sessionId userId:(NSString *)userId completion:(void(^)(NSMutableArray* result))completion;
- (void)getCategories:(NSString *)sessionId completion:(void(^)(NSMutableArray* result))completion;
- (void)getProvinces:(NSString *)sessionId completion:(void(^)(NSMutableArray* result))completion;
- (void)getExpenses:(NSString *)sessionId userGUID:(NSString *)userGUID status:(NSString *)status completion:(void(^)(NSMutableArray* result))completion;
- (void)getExpense:(NSString *)sessionId expenseId:(int)expenseId completion:(void(^)(NSMutableArray* result))completion;
- (void)getExpenseReceipt:(NSString *)sessionId expenseId:(int)expenseId completion:(void(^)(NSMutableArray* result))completion;
- (void)getExpenseMileageRate:(NSString *)sessionId completion:(void(^)(NSMutableArray* result))completion;
- (void)saveExpense:(NSString *)sessionId expenseObject:(NSString *)expenseObject completion:(void(^)(NSMutableArray* result))completion;
- (void)getJobDepartments:(NSString *)sessionId regionId:(int)regionId completion:(void(^)(NSMutableArray* result))completion;
- (void)getJobCostTypes:(NSString *)sessionId regionId:(int)regionId completion:(void(^)(NSMutableArray* result))completion;
- (void)getJobCostCategories:(NSString *)sessionId regionId:(int)regionId departmentId:(NSString *)departmentId jobCostTypeId:(NSString *)jobCostTypeId completion:(void(^)(NSMutableArray* result))completion;
- (void)getOnCallBranches:(NSString *)sessionId userGUID:(NSString *)userGUID completion:(void(^)(NSMutableArray* result))completion;
- (void)updateOnCallStatus:(NSString *)sessionId userGUID:(NSString *)userGUID status:(Boolean)status completion:(void(^)(NSMutableArray* result))completion;
- (void)updateOnCallBranches:(NSString *)sessionId userGUID:(NSString *)userGUID branches:(NSString *)branches completion:(void(^)(NSMutableArray* result))completion;
- (void)getNoteDetails:(NSString *)sessionId regionId:(int)regionId claimId:(int)claimId noteId:(int)noteId completion:(void(^)(NSMutableArray* result))completion;
- (void)shareNote:(NSString *)sessionId shareObject:(Share *)shareObject completion:(void(^)(NSMutableArray* result))completion;
- (void)searchFOSEmployee:(NSString *)sessionId searchStr:(NSString *)searchStr completion:(void(^)(NSMutableArray* result))completion;
- (void)searchBranches:(NSString *)sessionId term:(NSString *)term completion:(void(^)(NSMutableArray* result))completion;
- (void)updateUserDetail:(NSString *)sessionId userGUID:(NSString *)userGUID phone:(NSString *)phone completion:(void(^)(NSMutableArray* result))completion;
- (void)updateUserPicture:(NSString *)sessionId userGUID:(NSString *)userGUID picture:(NSString *)picture thumbnail:(NSString *)thumbnail completion:(void(^)(NSMutableArray* result))completion;
- (void)deleteUserPicture:(NSString *)sessionId userGUID:(NSString *)userGUID completion:(void(^)(NSMutableArray* result))completion;
- (void)getRecents:(NSString *)sessionId userGUID:(NSString *)userGUID isFOS:(NSString *)isFOS completion:(void(^)(NSMutableArray* result))completion;
- (void)deleteRecent:(NSString *)sessionId userGUID:(NSString *)userGUID email:(NSString *)email completion:(void(^)(NSMutableArray* result))completion;

@end
