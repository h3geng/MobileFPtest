//
//  NotesViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/6/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Claim.h"
#import "Note.h"

@interface NotesViewController : BaseTableViewController

@property Claim *claim;
@property NSMutableArray *notes;
@property bool notesLoaded;
@property bool reload;

@property Note *selectedNote;
- (IBAction)addPressed:(id)sender;

@end
