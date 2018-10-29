//
//  HomeViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 9/27/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "HomeViewController.h"
#import "BatchViewController.h"
#import "LoginViewController.h"
#import "AlertViewController.h"
#import "InventoryViewController.h"
#import "NoteDetailsViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([APP_MODE isEqual: @"0"]) {
        [self.tabBarController.tabBar setTintColor:[UTIL darkBlueColor]];
        [self.tabBarController.tabBar setBarTintColor:[UTIL darkRedColor]];
        [self.tabBarController.tabBar setUnselectedItemTintColor:[UIColor whiteColor]];
    }
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setupNotifications];
    [self setupCollections];
    
    // init db manager
    _dbManager = [[DBManager alloc] initWithDatabaseFilename:@"pendingdb.sql"];
    
    USER.deviceToken = APP_DELEGATE.strDeviceToken;
    [USER registerForNotifications];
    
    [self checkAppArguments];
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noteDismissed:) name:@"noteDismissed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNoteShare:) name:@"receivedNoteShare" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedExternalScannerResponse:) name:@"externalScannerResponse" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whatsNewDismissed:) name:@"whatsNewDismissed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photosSetIntoStorage:) name:@"photosSetIntoStorage" object:nil];
}

- (void)setupCollections {
    [BRANCHES performSelectorInBackground:@selector(loadItems) withObject:nil];
    [ALLBRANCHES performSelectorInBackground:@selector(loadItems) withObject:nil];
    [CLASSES performSelectorInBackground:@selector(loadItems) withObject:nil];
    [MODELS performSelectorInBackground:@selector(loadItems) withObject:nil];
    [DEPARTMENTS performSelectorInBackground:@selector(loadItems) withObject:nil];
    [STATUSES performSelectorInBackground:@selector(loadItems) withObject:nil];
    [JOBCOSTCATS performSelectorInBackground:@selector(loadItems) withObject:nil];
    
    [SCANNER initialize];
    SCANNER.scanApi = [[ScanApiHelper alloc] init];
    [SCANNER.scanApi setDelegate:SCANNER];
    [SCANNER.scanApi open];
    [NSTimer scheduledTimerWithTimeInterval:.5f target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            NSLog(@"AVCaptureDevice access granted");
        }
    }];
}

- (void)checkAppArguments {
    if (APP_DELEGATE.launchOptions != nil) {
        NSDictionary *options = [APP_DELEGATE.launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
        if (options != nil) {
            [UTIL processAppOptions:options];
        }
    } else {
        if (APP_DELEGATE.receivedPushNotification != nil) {
            [UTIL processAppOptions:APP_DELEGATE.receivedPushNotification];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setTitle:NSLocalizedStringFromTable(@"home", [UTIL getLanguage], @"")];
    
    [self performSelector:@selector(refreshPendingPhotosCount) withObject:nil];
    
    [self showWhatsNew];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)whatsNewDismissed:(NSNotification *)notification {
    // update preferences
    [USER_DEFAULTS setObject:_appBuild forKey:@"whatsnew"];
    [USER_DEFAULTS synchronize];
    [_overlay removeFromSuperview];
}

- (void)refreshPendingPhotosCount {
    @autoreleasepool {
        NSString *query = @"select selfId from photoInfo";
        NSArray *arrPhotoInfo = [[NSArray alloc] initWithArray:[_dbManager loadDataFromDB:query]];
        _pendingPhotoCount = (int)arrPhotoInfo.count;
        
        [self.tableView reloadData];
    }
}

- (void)photosSetIntoStorage:(NSNotification *)notification {
    [self performSelector:@selector(refreshPendingPhotosCount) withObject:nil];
}

- (void)onTimer:(NSTimer*)theTimer {
    [SCANNER.scanApi doScanApiReceive];
}

- (void)showWhatsNew {
    // Insert what's new overlay if not seen
    _appBuild = @"";
    NSURL *legalUrl = [[NSBundle mainBundle] URLForResource:@"Legal" withExtension:@"plist" subdirectory:@"Settings.bundle"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfURL:legalUrl];
    NSMutableArray *array = [dictionary objectForKey:@"PreferenceSpecifiers"];
    for (id val in array) {
        if ([[val objectForKey:@"Key"] isEqualToString:@"appBuild"]) {
            _appBuild = [val objectForKey:@"DefaultValue"];
        }
    }
    
    if (![[USER_DEFAULTS objectForKey:@"whatsnew"] isEqual:_appBuild]) {
        _overlay = [[WhatsNewView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.tabBarController.view addSubview:_overlay];
    }
}

- (void)noteDismissed:(NSNotification *) notification {
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)receivedNoteShare:(NSNotification *) notification {
    Note *note = [[notification userInfo] valueForKey:@"data"];
    
    [UTIL showActivity:@""];
    [self performSelector:@selector(processNoteShare:) withObject:note afterDelay:0.1f];
}

- (void)processNoteShare:(Note *)note {
    [note.claim load:^(bool result) {
        if (result) {
            [note load:^(bool result) {
                [UTIL hideActivity];
                
                if (result) {
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    NoteDetailsViewController *viewController = (NoteDetailsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"noteDetails"];
                    viewController.note = note;
                    viewController.readOnly = true;
                    
                    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
                    
                    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
                    [navController setModalPresentationStyle:UIModalPresentationCurrentContext];
                    [navController.navigationBar setBarTintColor:[UIColor colorWithRed:0/255.0f green:45/255.0f blue:87/255.0f alpha:1.0f]];
                    [navController.navigationBar setTintColor:[UIColor whiteColor]];
                    [navController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
                    [navController.navigationBar setTranslucent:NO];
                    
                    [self presentViewController:navController animated:YES completion:^{
                        [self.tabBarController.tabBar setHidden:YES];
                    }];
                } else {
                    [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"note_could_not_be_loaded", [UTIL getLanguage], @"")];
                }
            }];
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"note_could_not_be_loaded", [UTIL getLanguage], @"")];
        }
    }];
}

- (void)receivedExternalScannerResponse:(NSNotification *) notification {
    _scannedInventory = [[notification userInfo] valueForKey:@"data"];
    if ([[APP_DELEGATE getCurrentScreen] isKindOfClass:[self class]]) {
        [self performSegueWithIdentifier:@"showInventory" sender:self];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections = 1;
    
    if (USER.isCT) {
        numberOfSections = 2;
    }
    
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    
    switch (section) {
        case 0:
            if (USER.isCT) {
                if ([APP_MODE isEqual: @"1"]) {
                    rows = 3;
                } else {
                    rows = 5;
                }
            } else {
                if ([APP_MODE isEqual: @"1"]) {
                    rows = 1;
                } else {
                    rows = 3;
                }
            }
            break;
        case 1:
            rows = 2;
            break;
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    switch ([indexPath section]) {
        case 0:
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            switch ([indexPath row]) {
                case 0:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"my_profile", [UTIL getLanguage], @"")]; // [USER name] if required
                    if (USER.onCall) {
                        UIImageView *callView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Phone"]];
                        [callView setContentMode:UIViewContentModeCenter];
                        [cell setAccessoryView:callView];
                    } else {
                        [cell setAccessoryView:nil];
                        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    }
                    break;
                case 1:
                    if (USER.isCT) {
                        [cell.textLabel setText:NSLocalizedStringFromTable(@"file_alerts", [UTIL getLanguage], @"")];
                    } else {
                        [cell.textLabel setText:NSLocalizedStringFromTable(@"expenses", [UTIL getLanguage], @"")];
                    }
                    break;
                case 2:
                    if (USER.isCT) {
                        [cell.textLabel setText:NSLocalizedStringFromTable(@"my_jobs", [UTIL getLanguage], @"")];
                    } else {
                        [cell.textLabel setText:NSLocalizedStringFromTable(@"my_day", [UTIL getLanguage], @"")];
                    }
                    break;
                case 3:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"expenses", [UTIL getLanguage], @"")];
                    break;
                case 4:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"my_day", [UTIL getLanguage], @"")];
                    break;
            }
            break;
        case 1:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            switch ([indexPath row]) {
                case 0:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"transactions", [UTIL getLanguage], @"")];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)TRANSACTIONS.items.count]];
                    break;
                case 1:
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"photo_uploads", [UTIL getLanguage], @"")];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%d", _pendingPhotoCount]];
                    break;
            }
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath section]) {
        case 0:
            switch ([indexPath row]) {
                case 0:
                    [self performSegueWithIdentifier:@"showDetails" sender:self];
                    break;
                case 1:
                    if (USER.isCT) {
                        [self performSegueWithIdentifier:@"showAlerts" sender:self];
                    } else {
                        [self performSegueWithIdentifier:@"showExpenses" sender:self];
                    }
                    break;
                case 2:
                    if (USER.isCT) {
                        [UTIL showActivity:NSLocalizedStringFromTable(@"loading", [UTIL getLanguage], @"")];
                        [self performSelector:@selector(showMyClaims) withObject:nil afterDelay:0.1f];
                    } else {
                        [self performSegueWithIdentifier:@"showMyDay" sender:self];
                    }
                    break;
                case 3:
                    [self performSegueWithIdentifier:@"showExpenses" sender:self];
                    break;
                case 4:
                    [self performSegueWithIdentifier:@"showMyDay" sender:self];
                    break;
            }
            break;
        case 1:
            switch ([indexPath row]) {
                case 0:
                    [self performSegueWithIdentifier:@"showTransactions" sender:self];
                    break;
                default:
                    if (_pendingPhotoCount > 0) {
                        [self performSegueWithIdentifier:@"showPendingPhotos" sender:self];
                    } else {
                        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                    }
                    break;
            }
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"";
    
    switch (section) {
        case 1:
            title = NSLocalizedStringFromTable(@"pending", [UTIL getLanguage], @"");
            break;
    }
    
    return title;
}

- (void)showMyClaims {
    _myClaims = [[NSMutableArray alloc] init];
    
    [API findUserClaims:USER.sessionId regionId:USER.regionId branchCode:@"" userName:USER.username completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqualToString: @""]) {
            NSMutableArray *responseData = ([result valueForKey:@"findUserClaimsResult"] != [NSNull null]) ?  [result valueForKey:@"findUserClaimsResult"] : nil;
            for (NSMutableArray *claim in responseData) {
                Claim *item = [[Claim alloc] init];
                item.claimIndx = [[claim valueForKey:@"ClaimIndx"] intValue];
                item.claimNumber = [claim valueForKey:@"ClaimNumber"];
                item.projectName = [claim valueForKey:@"ProjectName"];
                item.dateJobOpen = [claim valueForKey:@"DateJobOpen"];
                item.addressString = [claim valueForKey:@"Address"];
                item.city = [claim valueForKey:@"City"];
                item.address.address = item.addressString;
                item.address.city = item.city;
                [item.address prepareFullAddress];
                
                [self->_myClaims addObject:item];
            }
            [self performSegueWithIdentifier:@"showMyClaims" sender:self];
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
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
    if ([[segue identifier] isEqualToString:@"showTransactions"]) {
        BatchViewController *child = (BatchViewController *)[segue destinationViewController];
        [child setSimpleMode:true];
    }
    if ([[segue identifier] isEqualToString:@"showMyClaims"]) {
        AlertViewController *child = (AlertViewController *)[segue destinationViewController];
        [child setItems:_myClaims];
        [child setMainTitle:NSLocalizedStringFromTable(@"my_jobs", [UTIL getLanguage], @"")];
    }
    if ([[segue identifier] isEqualToString:@"showInventory"]) {
        InventoryViewController *child = (InventoryViewController *)[segue destinationViewController];
        [child setInventory:_scannedInventory];
    }
}

- (IBAction)actionsPressed:(id)sender {
    NSString *msg = NSLocalizedStringFromTable(@"scanner_setup_message", [UTIL getLanguage], @"");
    if (!USER.isCT) {
        msg = nil;
    }
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"choose_action", [UTIL getLanguage], @"") message:msg preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (USER.isCT) {
        UIAlertAction *actionSetup = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedStringFromTable(@"scanner", [UTIL getLanguage], @""), NSLocalizedStringFromTable(@"setup", [UTIL getLanguage], @"")] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self performSegueWithIdentifier:@"showScannerSetup" sender:self];
        }];
        [actionSheet addAction:actionSetup];
    }
    
    UIAlertAction *actionWhatsNew = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"whats_new", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        self->_overlay = [[WhatsNewView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.tabBarController.view addSubview:self->_overlay];
    }];
    [actionSheet addAction:actionWhatsNew];
    
    UIAlertAction *actionFOSDirectory = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"firstonsite_directory", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self performSegueWithIdentifier:@"showFosDirectory" sender:self];
    }];
    [actionSheet addAction:actionFOSDirectory];
    
    UIAlertAction *actionLogOut = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"logout", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [APP_DELEGATE logout];
    }];
    [actionLogOut setValue:[UTIL darkRedColor] forKey:@"titleTextColor"];
    [actionSheet addAction:actionLogOut];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", [UTIL getLanguage], @"") style:UIAlertActionStyleCancel handler:nil];
    [actionCancel setValue:[UTIL darkRedColor] forKey:@"titleTextColor"];
    [actionSheet addAction:actionCancel];
    
    if (IS_IPAD()) {
        UIPopoverPresentationController *popoverPresentationController = [actionSheet popoverPresentationController];
        popoverPresentationController.barButtonItem = _actionsButton;
        [actionSheet setModalPresentationStyle:UIModalPresentationPopover];
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

@end
