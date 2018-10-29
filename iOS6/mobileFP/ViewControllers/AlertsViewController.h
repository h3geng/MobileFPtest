//
//  AlertsViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/12/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertsViewController : UITableViewController

@property NSMutableArray *items;
@property bool itemsLoaded;
@property NSMutableArray *alertDetails;
@property GenericObject *selectedAlert;

@end
