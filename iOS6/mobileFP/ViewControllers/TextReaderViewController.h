//
//  TextReaderViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/8/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextReaderViewController : UIViewController <UITextViewDelegate>

@property NSString *headerTitle;
@property NSString *text;
@property bool allowEdit;
@property (strong, nonatomic) IBOutlet UITextView *textTextView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
- (IBAction)savePressed:(id)sender;

@end
