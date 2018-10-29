//
//  ClaimNoteViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/13/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Phase.h"
#import "Note.h"

@interface ClaimNoteViewController : UITableViewController <UITextViewDelegate>

@property Claim *claim;
@property GenericObject *department;
@property GenericObject *phase;
@property GenericObject *alertPm;
@property NSString *note;
@property Note *noteObject;

- (IBAction)savePressed:(id)sender;

- (void)setPhaseObject:(GenericObject *)item;
- (void)setDepartmentObject:(GenericObject *)item;

@end
