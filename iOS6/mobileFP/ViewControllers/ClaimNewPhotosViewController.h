//
//  ClaimNewPhotosViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-05-17.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "ClaimPhotoObject.h"
#import "ClaimPhotosViewController.h"
#import "PhotoNotesViewController.h"
#import "PhotoGalleryViewController.h"
#import "CameraOverlayView.h"
#import "PendingPhoto.h"

#import "DBManager.h"

@interface ClaimNewPhotosViewController : BaseTableViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property Claim *claim;
@property int phaseIndex;
@property NSString *phaseName;
@property NSMutableArray *photos;
@property NSMutableArray *uploadedPhotos;

@property ClaimPhotoObject *selectedPhoto;
@property UIImagePickerController *cameraPhotoPicker;
@property BOOL cameraAvailable;
@property CameraOverlayView *overlay;
@property BOOL loadFromStorage;
@property BOOL photoCaptured;

@property (nonatomic, strong) DBManager *dbManager;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionsButton;
- (IBAction)actionsPressed:(id)sender;

@end
