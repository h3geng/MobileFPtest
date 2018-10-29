//
//  PhotoNotesViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-06-01.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClaimNewPhotosViewController.h"

#import "DBManager.h"

@interface PhotoNotesViewController : UIViewController

@property int selfId;
@property NSString *notes;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (nonatomic, strong) DBManager *dbManager;

- (IBAction)donePressed:(id)sender;

@end
