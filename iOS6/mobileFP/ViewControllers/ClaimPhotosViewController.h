//
//  ClaimPhotosViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/6/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClaimPhoto.h"
#import "ClaimNewPhotosViewController.h"

@interface ClaimPhotosViewController : UICollectionViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property Claim *claim;
@property NSMutableArray *photos;
@property NSMutableArray *photoItems;

//@property UIImagePickerController *sourcePicker;
@property ClaimPhoto *selectedPhoto;
@property UIImage *selectedImage;
@property int itemsInRow;

@property int photosPage;
@property int totalItems;
@property int perPage;
@property int currentPage;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *actionsButton;

@property int phaseIndex;
@property NSString *selectedPhaseName;
@property NSString *phaseName;
@property bool photosLoaded;

- (IBAction)actionsPressed:(id)sender;
- (void)loadPhotos;

@end
