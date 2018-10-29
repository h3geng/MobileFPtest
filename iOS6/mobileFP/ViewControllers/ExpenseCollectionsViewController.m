//
//  ExpenseCollectionsViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-03-22.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import "ExpenseCollectionsViewController.h"

@interface ExpenseCollectionsViewController ()

@end

@implementation ExpenseCollectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _items = [[NSMutableArray alloc] init];
    
    switch (_collectionType) {
        case 1: // departments
            [self setTitle:NSLocalizedStringFromTable(@"department", [UTIL getLanguage], @"")];
            [self getExpenseDepartments];
            break;
        case 2: // provinces
            [self setTitle:NSLocalizedStringFromTable(@"province", [UTIL getLanguage], @"")];
            [self getProvinces];
            break;
        case 3: // categories
            [self setTitle:NSLocalizedStringFromTable(@"category", [UTIL getLanguage], @"")];
            [self getCategories];
            break;
        case 5: // branch
            [self setTitle:NSLocalizedStringFromTable(@"branch", [UTIL getLanguage], @"")];
            [self getBranches];
            break;
        case 7: // phase
            [self setTitle:NSLocalizedStringFromTable(@"phase", [UTIL getLanguage], @"")];
            [self getPhases];
            break;
        case 8: // currency
            [self setTitle:NSLocalizedStringFromTable(@"currency", [UTIL getLanguage], @"")];
            [self getCurrencies];
            break;
        case 9: // type
            [self setTitle:NSLocalizedStringFromTable(@"type", [UTIL getLanguage], @"")];
            [self getTypes];
            break;
        case 10: // cost category
            [self setTitle:NSLocalizedStringFromTable(@"cost_category", [UTIL getLanguage], @"")];
            [self getCostCategories];
            break;
        case 11: // job departments
            [self setTitle:NSLocalizedStringFromTable(@"department", [UTIL getLanguage], @"")];
            [self getJobDepartments];
            break;
    }
}

- (void)getJobDepartments {
    [UTIL showActivity:@""];
    [API getJobDepartments:USER.sessionId regionId:_regionId completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSMutableArray *items = [result valueForKey:@"getJobDepartmentsResult"];
        
        for (id item in items) {
            GenericObject *obj = [[GenericObject alloc] init];
            obj.genericId = [item valueForKey:@"Id"];
            obj.value = [item valueForKey:@"Value"];
            obj.code = [item valueForKey:@"Code"];
            [self->_items addObject:obj];
        }
        
        [self.tableView reloadData];
    }];
}

- (void)getCostCategories {
    [UTIL showActivity:@""];
    
    [API getJobCostCategories:USER.sessionId regionId:_regionId departmentId:_departmentId jobCostTypeId:_jobCostTypeId completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSMutableArray *items = [result valueForKey:@"getJobCostCategoriesResult"];
        
        for (id item in items) {
            GenericObject *obj = [[GenericObject alloc] init];
            obj.genericId = [item valueForKey:@"Id"];
            obj.value = [item valueForKey:@"Value"];
            obj.code = [item valueForKey:@"Code"];
            [self->_items addObject:obj];
        }
        
        [self.tableView reloadData];
    }];
}

- (void)getTypes {
    [UTIL showActivity:@""];
    
    [API getJobCostTypes:USER.sessionId regionId:_regionId completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSMutableArray *items = [result valueForKey:@"getJobCostTypesResult"];
        
        for (id item in items) {
            GenericObject *obj = [[GenericObject alloc] init];
            obj.genericId = [item valueForKey:@"Id"];
            obj.value = [item valueForKey:@"Value"];
            obj.code = [item valueForKey:@"Code"];
            [self->_items addObject:obj];
        }
        
        [self.tableView reloadData];
    }];
}

- (void)getExpenseDepartments {
    [UTIL showActivity:@""];
    
    [API getExpenseDepartments:USER.sessionId regionId:_regionId branchId:_branchId categoryId:_categoryId completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSMutableArray *items = [result valueForKey:@"getExpenseDepartmentsResult"];
        
        for (id item in items) {
            GenericObject *obj = [[GenericObject alloc] init];
            obj.genericId = [item valueForKey:@"Id"];
            obj.value = [item valueForKey:@"Value"];
            obj.code = [item valueForKey:@"Code"];
            [self->_items addObject:obj];
        }
        
        [self.tableView reloadData];
    }];
}

- (void)getCategories {
    [UTIL showActivity:@""];
    
    [API getCategories:USER.sessionId completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSMutableArray *items = [result valueForKey:@"getCategoriesResult"];
        
        for (id item in items) {
            GenericObject *obj = [[GenericObject alloc] init];
            obj.genericId = [item valueForKey:@"Id"];
            obj.value = [item valueForKey:@"Value"];
            [self->_items addObject:obj];
        }
        
        [self.tableView reloadData];
    }];
}

- (void)getProvinces {
    [UTIL showActivity:@""];
    
    [API getProvinces:USER.sessionId completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSMutableArray *items = [result valueForKey:@"getProvincesResult"];
        
        for (id item in items) {
            GenericObject *obj = [[GenericObject alloc] init];
            obj.genericId = [item valueForKey:@"Id"];
            obj.value = [item valueForKey:@"Value"];
            obj.code = [item valueForKey:@"Code"];
            [self->_items addObject:obj];
        }
        
        [self.tableView reloadData];
    }];
}

- (void)getBranches {
    for (GenericObject *item in [ALLBRANCHES items]) {
        [_items addObject:item];
    }
    
    [self.tableView reloadData];
}

- (void)getCurrencies {
    GenericObject *obj = [[GenericObject alloc] init];
    obj.genericId = @"1";
    obj.value = @"CAD";
    obj.code = @"Canada";
    [_items addObject:obj];
    
    obj = [[GenericObject alloc] init];
    obj.genericId = @"2";
    obj.value = @"USD";
    obj.code = @"United States";
    [_items addObject:obj];
    
    [self.tableView reloadData];
}

- (void)getPhases {
    if (_selectedId > 0) {
        Claim *claim = [[Claim alloc] init];
        claim.claimIndx = [_selectedId intValue];
        [UTIL showActivity:@""];
        
        [claim load:^(bool result) {
            [UTIL hideActivity];
            
            for (Phase *item in claim.phaseList) {
                GenericObject *obj = [[GenericObject alloc] init];
                obj.genericId = [NSString stringWithFormat:@"%d", item.phaseIndx];
                obj.code = item.phaseDesc;
                obj.value = item.phaseCode;
                [self->_items addObject:obj];
            }
            [self.tableView reloadData];
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    GenericObject *item = (GenericObject *)[_items objectAtIndex:[indexPath row]];
    [cell.textLabel setText:item.value];
    [cell.detailTextLabel setText:item.code];
    if ([_selectedId isEqual:item.genericId]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *notificationObjects = [[NSMutableArray alloc] init];
    [notificationObjects addObject:[NSString stringWithFormat:@"%d", _collectionType]];
    [notificationObjects addObject:[_items objectAtIndex:[indexPath row]]];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:notificationObjects forKey:@"collectionItem"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"collectionItemSelected" object:nil userInfo:dictionary];
    
    [self.navigationController popViewControllerAnimated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
