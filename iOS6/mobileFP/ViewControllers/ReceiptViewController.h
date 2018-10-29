//
//  ReceiptViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-03-23.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReceiptViewController : BaseViewController <UIImagePickerControllerDelegate>

@property int expenseId;
@property (weak, nonatomic) IBOutlet UIWebView *expenseImage;
- (IBAction)cameraPressed:(id)sender;

@property UIView *highlightView;
@property UIImagePickerController *sourcePicker;
@property UIImage *selectedImage;

@end
