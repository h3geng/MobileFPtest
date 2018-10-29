//
//  DeviceContactsViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-09-08.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Contacts/Contacts.h>
#import "Note.h"
#import "NoteShareViewController.h"

@interface DeviceContactsViewController : BaseTableViewController <UISearchBarDelegate, UISearchControllerDelegate>

@property NoteShareViewController *parent;

@property (strong, nonatomic) UISearchController *searchController;
@property Note *note;

@property NSMutableArray *deviceContacts;
@property NSMutableArray *fosContacts;

@property NSMutableArray *defaultDeviceContacts;

@end
