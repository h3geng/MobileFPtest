//
//  DeviceContactsViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-09-08.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import "DeviceContactsViewController.h"

@interface DeviceContactsViewController ()

@end

@implementation DeviceContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setTitle:NSLocalizedStringFromTable(@"my_contacts", [UTIL getLanguage], @"")];
    
    _parent = (NoteShareViewController *)[APP_DELEGATE getPreviousScreen];
    
    _defaultDeviceContacts = [[NSMutableArray alloc] init];
    _deviceContacts = [[NSMutableArray alloc] init];
    _fosContacts = [[NSMutableArray alloc] init];
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.dimsBackgroundDuringPresentation = NO;
    _searchController.searchBar.delegate = self;
    _searchController.delegate = self;
    
    self.tableView.tableHeaderView = _searchController.searchBar;
    self.definesPresentationContext = YES;
    
    [UTIL showActivity:NSLocalizedStringFromTable(@"loading", [UTIL getLanguage], @"")];
    [self performSelector:@selector(loadContacts) withObject:nil afterDelay:0.1f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadContacts {
    CNContactStore *store = [[CNContactStore alloc] init];
    
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted == YES) {
            NSArray *keys = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactEmailAddressesKey];
            NSString *containerId = store.defaultContainerIdentifier;
            NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
            NSError *error;
            
            NSArray *cnContacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
            if (error) {
                NSLog(@"error fetching contacts %@", error);
                [UTIL hideActivity];
            } else {
                GenericObject *obj;
                NSString *firstName;
                NSString *lastName;
                
                for (CNContact *contact in cnContacts) {
                    obj = [[GenericObject alloc] init];
                    
                    firstName = contact.givenName;
                    lastName = contact.familyName;
                    
                    if (lastName == nil) {
                        obj.code = [NSString stringWithFormat:@"%@",firstName];
                        obj.parentId = [NSString stringWithFormat:@"%@",firstName];
                    } else if (firstName == nil) {
                        obj.code = [NSString stringWithFormat:@"%@",lastName];
                        obj.parentId = [NSString stringWithFormat:@"%@",lastName];
                    } else {
                        obj.code = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
                        obj.parentId = [NSString stringWithFormat:@"%@",lastName];
                    }
                    
                    if (contact.emailAddresses.count > 0) {
                        CNLabeledValue *label = [contact.emailAddresses objectAtIndex:0];
                        obj.value = label.value;
                    }
                    
                    if (![obj.value isEqual:@""]) {
                        [self->_defaultDeviceContacts addObject:obj];
                    }
                    
                    // sort
                    NSArray *sortedArray = [self->_defaultDeviceContacts sortedArrayUsingComparator:^NSComparisonResult(GenericObject *obj1, GenericObject *obj2) {
                        return [obj1.parentId compare:obj2.parentId];
                    }];
                    
                    self->_defaultDeviceContacts = [NSMutableArray arrayWithArray:sortedArray];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UTIL hideActivity];
                });
            }
        } else {
            [UTIL hideActivity];
        }
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (![[UTIL trim:[searchBar text]] isEqual:@""]) {
        [UTIL showActivity:NSLocalizedStringFromTable(@"loading", [UTIL getLanguage], @"")];
        [self performSelector:@selector(searchForContacts:) withObject:[UTIL trim:[searchBar text]] afterDelay:0.1f];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setText:@""];
}

- (void)searchForContacts:(NSString *)term {
    [self.searchController setActive:NO];
    
    _deviceContacts = [[NSMutableArray alloc] init];
    _fosContacts = [[NSMutableArray alloc] init];
    
    NSArray *filtered = [_defaultDeviceContacts filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        GenericObject *obj = (GenericObject*)evaluatedObject;
        return [[obj.code lowercaseString] containsString:[term lowercaseString]] || [[obj.value lowercaseString] containsString:[term lowercaseString]] ;
    }]];
    
    _deviceContacts = [NSMutableArray arrayWithArray:filtered];
    
    // fos directory
    [API searchFOSEmployee:USER.sessionId searchStr:term completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqualToString: @""]) {
            NSMutableArray *responseData = ([result valueForKey:@"searchFOSEmployeeResult"] != [NSNull null]) ?  [result valueForKey:@"searchFOSEmployeeResult"] : nil;
            
            for (NSMutableArray *item in responseData) {
                GenericObject *obj = [[GenericObject alloc] init];
                obj.code = [item valueForKey:@"FullName"];
                obj.value = [item valueForKey:@"Email"];
                
                [self->_fosContacts addObject:obj];
            }
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
        }
        
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"";
    
    switch (section) {
        case 0:
            if (_deviceContacts.count > 0) {
                title = NSLocalizedStringFromTable(@"my_contacts", [UTIL getLanguage], @"");
            }
            break;
        default:
            if (_fosContacts.count > 0) {
                title = NSLocalizedStringFromTable(@"firstonsite_directory", [UTIL getLanguage], @"");
            }
            break;
    }
    
    return title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    
    if (section == 0) {
        numberOfRows = _deviceContacts.count;
    } else {
        numberOfRows = _fosContacts.count;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    GenericObject *obj;
    if ([indexPath section] == 0) {
        obj = [_deviceContacts objectAtIndex:[indexPath row]];
    } else {
        obj = [_fosContacts objectAtIndex:[indexPath row]];
    }
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:obj.code];
    NSArray *components = [obj.code componentsSeparatedByString:@" "];
    NSRange firstRange = [obj.code rangeOfString:[components objectAtIndex:0]];
    
    [attrString beginEditing];
    [attrString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:[UIFont labelFontSize]] range:firstRange];
    if ([components count] > 1) {
        NSRange lastRange = [obj.code rangeOfString:[components objectAtIndex:1]];
        [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[UIFont labelFontSize]] range:lastRange];
    }
    [attrString endEditing];
    
    [cell.textLabel setAttributedText:attrString];
    
    [cell.detailTextLabel setText:obj.value];
    [cell.detailTextLabel setTextColor:[UIColor darkGrayColor]];
    
    if ([self contains:obj]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GenericObject *obj;
    if ([indexPath section] == 0) {
        obj = [_deviceContacts objectAtIndex:[indexPath row]];
    } else {
        obj = [_fosContacts objectAtIndex:[indexPath row]];
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        obj.genericId = @"1";
        [_parent.contacts addObject:obj];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [self removeObject:obj];
    }
}

- (bool)contains:(GenericObject *)item {
    for (GenericObject *obj in _parent.contacts) {
        if ([obj.code isEqual:item.code] && [obj.value isEqual:item.value]) {
            return true;
        }
    }
    
    return false;
}

- (void)removeObject:(GenericObject *)item {
    NSInteger index = 0;
    NSInteger existingIndex = -1;
    
    for (GenericObject *obj in _parent.contacts) {
        if ([obj.code isEqual:item.code] && [obj.value isEqual:item.value]) {
            existingIndex = index;
        }
        index++;
    }
    
    if (existingIndex > -1) {
        [_parent.contacts removeObjectAtIndex:existingIndex];
    }
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
