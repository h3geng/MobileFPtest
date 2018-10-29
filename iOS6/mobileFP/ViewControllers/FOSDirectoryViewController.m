//
//  FOSDirectoryViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-10-11.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import "FOSDirectoryViewController.h"
#import "UserProfileViewController.h"

@interface FOSDirectoryViewController ()

@end

@implementation FOSDirectoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _items = [[NSMutableArray alloc] init];
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.dimsBackgroundDuringPresentation = NO;
    _searchController.searchBar.delegate = self;
    _searchController.delegate = self;
    
    self.tableView.tableHeaderView = _searchController.searchBar;
    self.definesPresentationContext = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setTitle:NSLocalizedStringFromTable(@"firstonsite_directory", [UTIL getLanguage], @"")];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [_searchController.searchBar setText:term];
    
    _items = [[NSMutableArray alloc] init];
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
                obj.parentId = [item valueForKey:@"Title"];
                obj.genericId = [item valueForKey:@"Id"];
                
                [self->_items addObject:obj];
            }
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
        }
        
        [self.tableView reloadData];
    }];
}

- (void)processShowProfile {
    _usr = [[User alloc] init];
    _usr.userId = _selectedUser.genericId;
    [_usr load:^(NSMutableArray *result) {
        [UTIL hideActivity];
        [self performSegueWithIdentifier:@"showUserProfile" sender:self];
    }];
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
    
    GenericObject *obj = [_items objectAtIndex:[indexPath row]];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:obj.code];
    NSArray *components = [obj.code componentsSeparatedByString:@" "];
    NSRange firstRange = [obj.code rangeOfString:[components objectAtIndex:0]];
    
    [attrString beginEditing];
    [attrString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:[UIFont labelFontSize]] range:firstRange];
    if (components.count > 1) {
        NSRange lastRange = [obj.code rangeOfString:[components objectAtIndex:1]];
        [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[UIFont labelFontSize]] range:lastRange];
    }
    [attrString endEditing];
    
    [cell.textLabel setAttributedText:attrString];
    [cell.detailTextLabel setText:obj.parentId];
    [cell.detailTextLabel setTextColor:[UIColor darkGrayColor]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedUser = [_items objectAtIndex:[indexPath row]];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [UTIL showActivity:@""];
    [self performSelector:@selector(processShowProfile) withObject:nil afterDelay:0.1f];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showUserProfile"]) {
        UserProfileViewController *child = (UserProfileViewController *)[segue destinationViewController];
        [child setUsr:_usr];
    }
}

@end
