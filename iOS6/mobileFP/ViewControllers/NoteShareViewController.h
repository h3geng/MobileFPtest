//
//  NoteShareViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-09-07.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@interface NoteShareViewController : UITableViewController

@property Note *note;

@property NSMutableArray *contacts;
@property NSMutableArray *claimContacts;

@property NSMutableArray *recent;
@property NSMutableArray *recentToShow;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
- (IBAction)addPressed:(id)sender;

@end
