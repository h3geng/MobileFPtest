//
//  OnCallViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-09-05.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OnCallViewController : UITableViewController

@property UISwitch *onCallSwitch;
@property bool onCall;
@property User *usr;
@property NSMutableArray *branches;

@end
