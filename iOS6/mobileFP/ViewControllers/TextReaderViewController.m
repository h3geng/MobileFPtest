//
//  TextReaderViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/8/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "TextReaderViewController.h"
#import "TimesheetViewController.h"
#import "PhotoPreviewViewController.h"
#import "ClaimNewPhotosViewController.h"

@interface TextReaderViewController ()

@end

@implementation TextReaderViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.headerTitle = NSLocalizedStringFromTable(@"notes", [UTIL getLanguage], @"");
        self.text = @"";
        self.allowEdit = false;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:_headerTitle];
    
    [_textTextView setText:_text];
    [_textTextView setEditable:_allowEdit];
    
    if (!_allowEdit) {
        [self.navigationItem setRightBarButtonItem:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_textTextView scrollRangeToVisible:NSMakeRange(0, 1)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_textTextView becomeFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)savePressed:(id)sender {
    UIViewController *parent = [APP_DELEGATE getPreviousScreen];
    if ([parent isKindOfClass:[TimesheetViewController class]]) {
        TimesheetViewController *child = (TimesheetViewController *)parent;
        [child setNotes:_textTextView.text];
    }
    
    if ([parent isKindOfClass:[PhotoPreviewViewController class]]) {
        PhotoPreviewViewController *child = (PhotoPreviewViewController *)parent;
        [child setNotes:_textTextView.text];
    }
    
    if ([parent isKindOfClass:[ClaimNewPhotosViewController class]]) {
        ClaimNewPhotosViewController *child = (ClaimNewPhotosViewController *)parent;
        [child.selectedPhoto setPhotoDescription:_textTextView.text];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
