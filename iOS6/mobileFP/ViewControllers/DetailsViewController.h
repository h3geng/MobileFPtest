//
//  DetailsViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 9/27/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraPictureOverlayView.h"
#import "OnCallViewController.h"

@interface DetailsViewController : UITableViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property UISwitch *useTouchID;
@property UIImageView *imageView;
@property UIImagePickerController *sourcePicker;
@property UIImage *selectedImage;
@property CameraPictureOverlayView *overlay;
@property NSString *dataPhoto;
@property NSString *action;
@property UIImage *thumbnail;
@property NSString *dataThumbnail;

@end
