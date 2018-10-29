//
//  AlertViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/12/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "AlertViewController.h"
#import "ClaimDetailsViewController.h"

@interface AlertViewController ()

@end

@implementation AlertViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        _items = [[NSMutableArray alloc] init];
        _mainTitle = NSLocalizedStringFromTable(@"file_alert_details", [UTIL getLanguage], @"");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setTitle:_mainTitle];
    
    _viewItems = [[NSMutableArray alloc] init];
    for (Claim *item in _items) {
        if ([item isKindOfClass:[Claim class]]) {
            [item load:^(bool result) {
                if (result) {
                    [self->_viewItems addObject:item];
                    [self.tableView reloadData];
                }
            }];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"";
    if (_viewItems.count == 0) {
        title = NSLocalizedStringFromTable(@"nothing_found", [UTIL getLanguage], @"");
    }
    
    if (_headerText && ![_headerText isEqual: @""]) {
        if ([title isEqual:@""]) {
            title = _headerText;
        } else {
            title = [NSString stringWithFormat:@"%@\n%@", _headerText, title];
        }
    }
    
    return title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _viewItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    Claim *claim = (Claim *)[_viewItems objectAtIndex:[indexPath row]];
    
    NSArray *dateComponents = [[NSString stringWithFormat:@"%@", claim.dateJobOpen] componentsSeparatedByString: @" "];
    NSString *day = [dateComponents objectAtIndex: 0];
    
    [cell setTag:claim.claimIndx];
    [cell.textLabel setText:[NSString stringWithFormat:@"%@ (%@)",claim.claimNumber,day]];
    [cell.detailTextLabel setNumberOfLines:2];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@\n%@",claim.projectName, claim.address.fullAddress]];
    [cell.detailTextLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    if (claim.claimIndx != 0) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.tag > 0) {
        [UTIL showActivity:NSLocalizedStringFromTable(@"loading", [UTIL getLanguage], @"")];
        [self performSelector:@selector(loadClaim:) withObject:cell afterDelay:0.1f];
    }
}

- (void)loadClaim:(UITableViewCell *)cell {
    _selectedClaim = [[Claim alloc] init];
    _selectedClaim.claimIndx = (int)cell.tag;
    
    [_selectedClaim load:^(bool result) {
        if (result) {
            [UTIL hideActivity];
            [self performSegueWithIdentifier:@"showDetails" sender:self];
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"job_not_loaded", [UTIL getLanguage], @"")];
        }
    }];
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
    if ([[segue identifier] isEqualToString:@"showDetails"]) {
        ClaimDetailsViewController *child = (ClaimDetailsViewController *)[segue destinationViewController];
        [child setClaim:_selectedClaim];
    }
}

@end
