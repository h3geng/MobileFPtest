//
//  MyPhotoPreviewViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-10-10.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyPhotoPreviewViewController : BaseViewController

@property User *usr;
@property UIImage *photo;
@property (weak, nonatomic) IBOutlet UIImageView *photoContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblBranch;
@property (weak, nonatomic) IBOutlet UILabel *lblId;
@property (weak, nonatomic) IBOutlet UILabel *lblDepartment;

- (IBAction)retakePressed:(id)sender;
- (IBAction)donePressed:(id)sender;
    
@end
