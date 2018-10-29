//
//  FOSDirectoryViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-10-11.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FOSDirectoryViewController : BaseTableViewController <UISearchBarDelegate, UISearchControllerDelegate>

@property (strong, nonatomic) UISearchController *searchController;
@property NSMutableArray *items;
@property GenericObject *selectedUser;
@property User *usr;

@end
