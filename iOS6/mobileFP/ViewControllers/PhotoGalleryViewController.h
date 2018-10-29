//
//  ClaimNewPhotosViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-05-16.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "ClaimPhotoObject.h"
#import "TextReaderViewController.h"
#import "ClaimPhotosViewController.h"
#import "DBManager.h"

@interface PhotoGalleryViewController : UICollectionViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property NSMutableArray *selectedPhotoObjects;
@property CGFloat size_c;
@property int itemsInRow;

@property (nonatomic, strong) PHFetchResult *assets;
@property (nonatomic, strong) PHImageRequestOptions *phImageRequestOptions;
@property (nonatomic, strong) PHCachingImageManager *imageManager;

@property int claimIndx;
@property NSString *claimName;
@property int phaseIndx;
@property NSString *phaseName;

@property (nonatomic, strong) DBManager *dbManager;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionsButton;
- (IBAction)actionsPressed:(id)sender;

@end
