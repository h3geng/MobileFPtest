//
//  PendingPhotosViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-06-01.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PendingPhoto.h"
#import "ClaimNewPhotosViewController.h"
#import "DBManager.h"

@interface PendingPhotosViewController : UITableViewController

@property PendingPhoto *selectedItem;
@property Claim *claim;
@property NSMutableArray *items;
@property (nonatomic, strong) DBManager *dbManager;

- (IBAction)trashPressed:(id)sender;

@end
