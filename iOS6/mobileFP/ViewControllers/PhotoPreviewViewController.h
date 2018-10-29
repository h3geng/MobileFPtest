//
//  PhotoPreviewViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/12/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoPreviewViewController : UIViewController <UIActionSheetDelegate>

@property UIImage *photo;
@property Claim *claim;
@property NSString *notes;

@property (strong, nonatomic) IBOutlet UIImageView *mainImageView;
- (IBAction)actionPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *actionButton;

@end
