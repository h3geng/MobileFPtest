//
//  PendingPhotosViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-06-01.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import "PendingPhotosViewController.h"

@interface PendingPhotosViewController ()

@end

@implementation PendingPhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setTitle:NSLocalizedStringFromTable(@"pending_photo_uploads", [UTIL getLanguage], @"")];
    
    // init db manager
    _dbManager = [[DBManager alloc] initWithDatabaseFilename:@"pendingdb.sql"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UTIL showActivity:NSLocalizedStringFromTable(@"loading", [UTIL getLanguage], @"")];
    [self performSelector:@selector(loadPending) withObject:nil afterDelay:0.1f];
}

- (void)loadPending {
    _items = [[NSMutableArray alloc] init];
    
    NSString *query = @"select count(selfId) as cnt, claimIndx, phaseIndx, claimName, phaseName from photoInfo group by claimIndx, phaseIndx";
    NSArray *arrPhotoInfo = [[NSArray alloc] initWithArray:[_dbManager loadDataFromDB:query]];
    
    for (id item in arrPhotoInfo) {
        NSInteger indexOfCnt = [_dbManager.arrColumnNames indexOfObject:@"cnt"];
        NSInteger indexOfClaimIndx = [_dbManager.arrColumnNames indexOfObject:@"claimIndx"];
        NSInteger indexOfPhaseIndx = [_dbManager.arrColumnNames indexOfObject:@"phaseIndx"];
        NSInteger indexOfClaimName = [_dbManager.arrColumnNames indexOfObject:@"claimName"];
        NSInteger indexOfPhaseName = [_dbManager.arrColumnNames indexOfObject:@"phaseName"];
        
        PendingPhoto *pp = [[PendingPhoto alloc] init];
        pp.claimIndex = [[item objectAtIndex:indexOfClaimIndx] intValue];
        pp.claimName = [item objectAtIndex:indexOfClaimName];
        pp.phaseIndex = [[item objectAtIndex:indexOfPhaseIndx] intValue];
        pp.phaseName = [item objectAtIndex:indexOfPhaseName];
        
        pp.photos = [[item objectAtIndex:indexOfCnt] intValue];
        
        [_items addObject:pp];
    }
    
    [self.tableView reloadData];
    [UTIL hideActivity];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    PendingPhoto *pp = [_items objectAtIndex:[indexPath row]];
    
    [cell.textLabel setText:[NSString stringWithFormat:@"%@-%@", pp.claimName, pp.phaseName]];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)pp.photos]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedItem = [_items objectAtIndex:[indexPath row]];
    
    [UTIL showActivity:NSLocalizedStringFromTable(@"loading", [UTIL getLanguage], @"")];
    _claim = [[Claim alloc] init];
    _claim.claimIndx = _selectedItem.claimIndex;
    [self performSelector:@selector(loadDetails) withObject:nil afterDelay:0.1f];
}

- (void)loadDetails {
    [_claim load:^(bool result) {
        [UTIL hideActivity];        
        if (result) {
            [self performSelector:@selector(showNewPhotos) withObject:nil afterDelay:0.1f];
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"job_not_loaded", [UTIL getLanguage], @"")];
        }
    }];
}

- (void)showNewPhotos {
    [self performSegueWithIdentifier:@"showNewPhotos" sender:self];
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
    if ([[segue identifier] isEqualToString:@"showNewPhotos"]) {
        ClaimNewPhotosViewController *child = (ClaimNewPhotosViewController *)[segue destinationViewController];
        [child setPhaseName:_selectedItem.phaseName];
        [child setPhaseIndex:_selectedItem.phaseIndex];
        [child setClaim:_claim];
        [child setLoadFromStorage:YES];
    }
}

- (IBAction)trashPressed:(id)sender {
    [ALERT promptWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"do_you_want_to_remove_pending_photo_uploads", [UTIL getLanguage], @"") completion:^(BOOL granted) {
        if (granted) {
            [self->_dbManager executeQuery:@"delete from photoInfo"];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

@end
