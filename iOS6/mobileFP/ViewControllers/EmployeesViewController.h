//
//  EmployeesViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/12/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmployeesViewController : UITableViewController <UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet UISearchBar *employeeSearchBar;

@property GenericObject *defaultEmployee;
@property NSMutableArray *items;

@end
