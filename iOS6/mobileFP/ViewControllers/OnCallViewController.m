//
//  OnCallViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-09-05.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import "OnCallViewController.h"

@interface OnCallViewController ()

@end

@implementation OnCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setTitle:NSLocalizedStringFromTable(@"on_call", [UTIL getLanguage], @"")];
    _onCall = [_usr.userDetail onCall];
    _branches = [[NSMutableArray alloc] init];
}

- (void)getOnCallBranches {
    _branches = [[NSMutableArray alloc] init];
    
    [API getOnCallBranches:USER.sessionId userGUID:_usr.userId completion:^(NSMutableArray *result) {
        NSMutableArray *arr = ([result valueForKey:@"getOnCallBranchesResult"] != [NSNull null]) ?  (NSMutableArray *)[result valueForKey:@"getOnCallBranchesResult"] : [[NSMutableArray alloc] init];
        
        for (NSMutableArray *item in arr) {
            GenericObject *obj = [[GenericObject alloc] init];
            obj.parentId = [item valueForKey:@"Id"];
            obj.code = [item valueForKey:@"Code"];
            obj.value = [item valueForKey:@"Value"];
            
            [self->_branches addObject:obj];
        }
        
        [self.tableView reloadData];
        [UTIL hideActivity];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
- (void)receivedFOSBranches:(NSMutableArray *)items {
    [_branches addObjectsFromArray:items];
    
    [UTIL showActivity:NSLocalizedStringFromTable(@"please_wait", [UTIL getLanguage], @"")];
    [self performSelector:@selector(updateOnCallBranches) withObject:nil afterDelay:0.1f];
}
*/
#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *titleForHeader = @"";
    
    if (section == 0) {
        titleForHeader = NSLocalizedStringFromTable(@"status", [UTIL getLanguage], @"");
    } else {
        titleForHeader = NSLocalizedStringFromTable(@"branches", [UTIL getLanguage], @"");
    }
    
    return titleForHeader;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections = 1;
    
    if (_onCall) {
        numberOfSections = 2;
    }
    
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 1;
    
    if (section == 0) {
        if (_onCall) {
            numberOfRows = 2;
        }
    } else {
        if (section == 1) {
            numberOfRows = [ALLBRANCHES items].count;
        }
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    UILabel *onCallLabel;
    
    if ([indexPath section] == 0) {
        if ([indexPath row] == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"OnCallStatusCell" forIndexPath:indexPath];
            onCallLabel = (UILabel *)[cell viewWithTag:1];
            _onCallSwitch = (UISwitch *)[cell viewWithTag:2];
            [_onCallSwitch setOn:_onCall];
            [_onCallSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            
            [onCallLabel setText:NSLocalizedStringFromTable(@"on_call_status", [UTIL getLanguage], @"")];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            [cell.textLabel setText:NSLocalizedStringFromTable(@"phone", [UTIL getLanguage], @"")];
            if ([[UTIL trim:_usr.userDetail.phoneCell] isEqual:@""]) {
                [cell.detailTextLabel setText:@"-"];
            } else {
                [cell.detailTextLabel setText:[UTIL formatPhone:_usr.userDetail.phoneCell]];
            }
        }
    } else {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        
        GenericObject *go = (GenericObject *)[[ALLBRANCHES items] objectAtIndex:[indexPath row]];
        [cell.textLabel setText:go.value];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        if ([self branchSelected:go]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    }
    
    return cell;
}

- (bool)branchSelected:(GenericObject *)branch {
    bool selected = false;
    
    for (GenericObject *obj in _branches) {
        if ([obj.code isEqual:branch.code]) {
            selected = true;
        }
    }
    
    return selected;
}

- (void)unSelectBranch:(GenericObject *)branch {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (GenericObject *obj in _branches) {
        if (![obj.code isEqual:branch.code]) {
            [array addObject:obj];
        }
    }
    
    _branches = [NSMutableArray arrayWithArray:array];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0 && [indexPath row] == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self showNumberInput];
    }
    
    if ([indexPath section] == 1 && _onCallSwitch.isOn) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        GenericObject *br = [[ALLBRANCHES items] objectAtIndex:[indexPath row]];
        
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [self unSelectBranch:br];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            [_branches addObject:br];
        }
        
        [UTIL showActivity:@""];
        [self performSelector:@selector(updateOnCallBranches) withObject:nil afterDelay:0.1f];
    }
}

- (void)showNumberInput {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"phone", [UTIL getLanguage], @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertActionOk = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"ok", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (alertController.textFields.count > 0) {
            UITextField *textField = [alertController.textFields firstObject];
            
            NSString *regex = @"[0-9]{10}";
            NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
            
            if ([test evaluateWithObject:textField.text]) {
                [UTIL showActivity:NSLocalizedStringFromTable(@"please_wait", [UTIL getLanguage], @"")];
                [self performSelector:@selector(updatePhoneNumber:) withObject:textField.text afterDelay:0.1f];
            } else {
                [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"invalid_phone_number", [UTIL getLanguage], @"")];
            }
        }
    }];
    
    UIAlertAction *alertActionCancel = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:nil];
    
    [alertController addAction:alertActionOk];
    [alertController addAction:alertActionCancel];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedStringFromTable(@"phone", [UTIL getLanguage], @"");
        [textField setKeyboardType:UIKeyboardTypePhonePad];
    }];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)updatePhoneNumber:(NSString *)phone {
    _usr.userDetail.phoneCell = phone;
    [_usr.userDetail update:_usr.userId completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        [self.tableView reloadData];
    }];
}

- (void)switchChanged:(UISwitch *)sender {
    _onCall = sender.on;
    _usr.onCall = _onCall;
    _usr.userDetail.onCall = _onCall;
    
    [UTIL showActivity:NSLocalizedStringFromTable(@"please_wait", [UTIL getLanguage], @"")];
    [self performSelector:@selector(updateOnCallStatus) withObject:nil afterDelay:0.1f];
}

- (void)updateOnCallStatus {
    [API updateOnCallStatus:USER.sessionId userGUID:_usr.userId status:_onCall completion:^(NSMutableArray *result) {
        bool response = ([result valueForKey:@"updateOnCallStatusResult"] != [NSNull null]) ?  [result valueForKey:@"updateOnCallStatusResult"] : nil;
        
        if (!response) {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:@"Error occured, please try again later."];
        } else {
            [self.tableView reloadData];
        }
        
        [UTIL hideActivity];
    }];
}

- (void)updateOnCallBranches {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (GenericObject *item in _branches) {
        [items addObject:item.parentId];
    }
    
    [API updateOnCallBranches:USER.sessionId userGUID:_usr.userId branches:[items componentsJoinedByString:@"|"] completion:^(NSMutableArray *result) {
        bool response = ([result valueForKey:@"updateOnCallBranchesResult"] != [NSNull null]) ?  [result valueForKey:@"updateOnCallBranchesResult"] : nil;
        
        if (!response) {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:@"Error occured, please try again later."];
        } else {
            [self.tableView reloadData];
        }
        
        [UTIL hideActivity];
    }];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if ([indexPath section] == 1 && [indexPath row] > 0) {
        return YES;
    } else {
        return NO;
    }
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_branches removeObjectAtIndex:([indexPath row] - 1)];
        
        [UTIL showActivity:NSLocalizedStringFromTable(@"please_wait", [UTIL getLanguage], @"")];
        [self performSelector:@selector(updateOnCallBranches) withObject:nil afterDelay:0.1f];
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
