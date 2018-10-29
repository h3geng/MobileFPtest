//
//  NoteDetailsViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/13/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@interface NoteDetailsViewController : BaseTableViewController

@property Note *note;
@property bool readOnly;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;

- (IBAction)sharePressed:(id)sender;

@end
