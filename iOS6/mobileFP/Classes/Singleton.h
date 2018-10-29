//
//  Singleton.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 7/30/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#ifndef __Singleton_h
#define __Singleton_h

#import <AVFoundation/AVFoundation.h>

#import "AppDelegate.h"
#import "BaseViewController.h"
#import "BaseTableViewController.h"
#import "ScanApiHelper.h"
#import "Share.h"
#import "Api.h"
#import "User.h"
#import "Location.h"
#import "Note.h"
#import "Contact.h"
#import "Util.h"
#import "Scanner.h"
#import "Branches.h"
#import "AllBranches.h"
#import "Classes.h"
#import "Models.h"
#import "Departments.h"
#import "Statuses.h"
#import "JobCostCats.h"
#import "Transactions.h"

#define APP_DELEGATE        ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define API                 [Api getInstance]
#define USER                [User getInstance]
#define LOCATION            [Location getInstance]
#define UTIL                [Util getInstance]
#define SCANNER             [Scanner getInstance]
#define BRANCHES            [Branches getInstance]
#define ALLBRANCHES         [AllBranches getInstance]
#define CLASSES             [Classes getInstance]
#define MODELS              [Models getInstance]
#define DEPARTMENTS         [Departments getInstance]
#define STATUSES            [Statuses getInstance]
#define JOBCOSTCATS         [JobCostCats getInstance]
#define TRANSACTIONS        [Transactions getInstance]
#define USER_DEFAULTS       [NSUserDefaults standardUserDefaults]
#define ALERT               [AlertHelper getInstance]

#endif
