//
//  HomeViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 9/27/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WhatsNewView.h"
#import "DBManager.h"

@interface HomeViewController : BaseTableViewController <UIActionSheetDelegate>

@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, strong) NSMutableArray *myClaims;
@property (nonatomic, weak) Inventory *scannedInventory;
@property (nonatomic, weak) NSString *appBuild;
@property (nonatomic, strong) WhatsNewView *overlay;

@property int pendingPhotoCount;

- (IBAction)actionsPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *actionsButton;

@end
