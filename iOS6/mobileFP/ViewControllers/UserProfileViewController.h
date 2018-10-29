//
//  UserProfileViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-10-11.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraPictureOverlayView.h"
#import "OnCallViewController.h"
#import "MyPhotoPreviewViewController.h"

@interface UserProfileViewController : BaseTableViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property UIImagePickerController *sourcePicker;
@property User *usr;
@property UIImageView *imageView;
@property CameraPictureOverlayView *overlay;
@property NSString *dataPhoto;
@property NSString *action;
@property UIImage *selectedImage;
@property UIImage *thumbnail;
@property NSString *dataThumbnail;

@end
