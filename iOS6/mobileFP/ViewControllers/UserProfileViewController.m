//
//  UserProfileViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-10-11.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import "UserProfileViewController.h"

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _sourcePicker = [[UIImagePickerController alloc] init];
    [_sourcePicker setDelegate:self];
    [_sourcePicker setAllowsEditing:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"_UIImagePickerControllerUserDidCaptureItem" object:nil ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"_UIImagePickerControllerUserDidRejectItem" object:nil ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoPreviewResponse:) name:@"photoPreviewResponse" object:nil];
    
    _action = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraChanged:) name:@"AVCaptureDeviceDidStartRunningNotification" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tabBarController.tabBar setHidden:NO];
    [self setTitle:NSLocalizedStringFromTable(@"profile", [UTIL getLanguage], @"")];
    
    if ([_action isEqual:@"0"]) {
        _action = @"";
        //retake
        [_sourcePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        
        // Insert the overlay
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGSize screenSizeFixed = CGSizeMake(MIN(screenSize.width, screenSize.height), MAX(screenSize.width, screenSize.height));
        _overlay = [[CameraPictureOverlayView alloc] initWithFrame:CGRectMake(0, 0, screenSizeFixed.width, screenSizeFixed.height)];
        [_sourcePicker setCameraOverlayView:_overlay];
        
        [self presentViewController:_sourcePicker animated:YES completion:^{
            [self.tabBarController.tabBar setHidden:YES];
        }];
    }
    if ([_action isEqual:@"1"]) {
        _action = @"";
        //done
        [UTIL showActivity:@""];
        GenericObject *obj = [[GenericObject alloc] init];
        obj.code = _dataThumbnail;
        obj.value = _dataPhoto;
        [self performSelector:@selector(updateUserPicture:) withObject:obj afterDelay:0.1f];
    }
    
    [self.tableView reloadData];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    _selectedImage = info[UIImagePickerControllerOriginalImage];
    [self preparePhoto];
}

- (void)preparePhoto {
    CIImage *image = [CIImage imageWithCGImage:_selectedImage.CGImage];
    NSDictionary *opts = @{CIDetectorAccuracy: CIDetectorAccuracyHigh};
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:opts];
    
    NSNumber *orientation = [UTIL getImageOrientationWithImage:_selectedImage];
    opts = @{CIDetectorImageOrientation: orientation};
    NSArray *features = [detector featuresInImage:image options:opts];
    if ([features count] > 0) {
        CIFaceFeature *face = [features lastObject];
        // check face bounds
        CGSize ciImageSize = image.extent.size;
        CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
        transform = CGAffineTransformTranslate(transform, 0, -ciImageSize.height);
        
        // Apply the transform to convert the coordinates
        CGRect faceViewBounds = CGRectApplyAffineTransform(face.bounds, transform);
        
        // Calculate the actual position and size of the rectangle in the image view
        CGSize viewSize = [UIScreen mainScreen].bounds.size;
        CGFloat scale = MIN(viewSize.width / ciImageSize.width, viewSize.height / ciImageSize.height);
        CGFloat offsetX = (viewSize.width - ciImageSize.width * scale) / 2;
        CGFloat offsetY = (viewSize.height - ciImageSize.height * scale) / 2;
        
        faceViewBounds = CGRectApplyAffineTransform(faceViewBounds, CGAffineTransformMakeScale(scale, scale));
        faceViewBounds.origin.x += offsetX;
        faceViewBounds.origin.y += offsetY;
        
        // acceptable face frame
        CGFloat x = viewSize.width/5;
        CGFloat y = (viewSize.height/10) * 2;
        CGFloat xx = x + (viewSize.width - (2*viewSize.width/5));
        CGFloat yy = y + (viewSize.height/10) * 4.2;
        // actual face frame
        CGFloat delta = -20.0f;
        CGFloat xActual = faceViewBounds.origin.x - delta;
        CGFloat yActual = faceViewBounds.origin.y - delta;
        CGFloat xxActual = faceViewBounds.origin.x + faceViewBounds.size.width + delta;
        CGFloat yyActual = faceViewBounds.origin.y + faceViewBounds.size.height + delta;
        
        if (x < xActual && y < yActual && xx > xxActual && yy > yyActual) {
            // crop and upload image
            UIImage *originalImage = [UTIL cropImageByFace:[image CGImage] toRect:CGRectMake(0, (image.extent.size.height - image.extent.size.width)/2, image.extent.size.width, image.extent.size.width)];
            
            originalImage = [UIImage imageWithCGImage:[originalImage CGImage] scale:0.0 orientation:UIImageOrientationRight];
            UIImage *scaledImage = [UTIL cropImage:originalImage toRect:CGRectMake(0, (originalImage.size.height - originalImage.size.width)/2, originalImage.size.width, originalImage.size.width)];
            
            _thumbnail = [UTIL imageWithImage:scaledImage scaledToSize:CGSizeMake(USER_PHOTO_THUMB_SIZE, USER_PHOTO_THUMB_SIZE)];
            scaledImage = [UTIL imageWithImage:scaledImage scaledToSize:CGSizeMake(USER_PHOTO_SIZE, USER_PHOTO_SIZE)];
            
            _dataPhoto = [UTIL encodeToBase64String:scaledImage];
            _dataPhoto = [_dataPhoto stringByRemovingPercentEncoding];
            
            _dataThumbnail = [UTIL encodeToBase64String:_thumbnail];
            _dataThumbnail = [_dataThumbnail stringByRemovingPercentEncoding];
            
            [_sourcePicker dismissViewControllerAnimated:YES completion:^{
                self->_selectedImage = scaledImage;
                [self showPreview];
            }];
        } else {
            [_sourcePicker dismissViewControllerAnimated:YES completion:^{
                [self.tabBarController.tabBar setHidden:NO];
                
                [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"face_outside_frame", [UTIL getLanguage], @"")];
            }];
        }
    } else {
        [_sourcePicker dismissViewControllerAnimated:YES completion:^{
            [self.tabBarController.tabBar setHidden:NO];
            
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"no_face_detected", [UTIL getLanguage], @"")];
        }];
    }
}

- (void)showPreview {
    [self performSegueWithIdentifier:@"showMyPhoto" sender:self];
}

- (void)updateUserPicture:(GenericObject *)obj {
    NSString *base64Data = obj.value;
    NSString *base64DataThumbnail = obj.code;
    
    _usr.userDetail.picture = base64Data;
    _usr.userDetail.thumbnail = base64DataThumbnail;
    
    [_usr.userDetail updatePicture:_usr.userId completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        [self.tableView reloadData];
    }];
}

- (void)deletePhoto {
    _usr.userDetail.picture = @"";
    
    [_usr.userDetail deletePicture:_usr.userId completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleNotification:(NSNotification *)message {
    if ([[message name] isEqualToString:@"_UIImagePickerControllerUserDidCaptureItem"]) {
        // Remove overlay, so that it is not available on the preview view;
        [_sourcePicker setCameraOverlayView:nil];
    }
    
    if ([[message name] isEqualToString:@"_UIImagePickerControllerUserDidRejectItem"]) {
        // Retake button pressed on preview. Add overlay, so that is available on the camera again
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGSize screenSizeFixed = CGSizeMake(MIN(screenSize.width, screenSize.height), MAX(screenSize.width, screenSize.height));
        _overlay = [[CameraPictureOverlayView alloc] initWithFrame:CGRectMake(0, 0, screenSizeFixed.width, screenSizeFixed.height)];
        [_sourcePicker setCameraOverlayView:_overlay];
    }
}

- (void)photoPreviewResponse:(NSNotification *)notification {
    _action = [[notification userInfo] valueForKey:@"data"];
}

- (void)cameraChanged:(NSNotification *)notification {
    if (_sourcePicker.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
        _sourcePicker.cameraViewTransform = CGAffineTransformIdentity;
        _sourcePicker.cameraViewTransform = CGAffineTransformScale(_sourcePicker.cameraViewTransform, -1, 1);
    } else {
        _sourcePicker.cameraViewTransform = CGAffineTransformIdentity;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 3;
    
    if (USER.userDetail.canManageEmployeeOnCall) {
        numberOfRows = 4;
    }
    
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 158;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIImage *myImage = [UIImage imageNamed:@"Account"];
    
    if (![_usr.userDetail.thumbnail isEqual:@""]) {
        myImage = [UTIL decodeBase64ToImage:_usr.userDetail.thumbnail];
    }
    
    _imageView = [[UIImageView alloc] initWithImage:myImage];
    [_imageView setFrame:CGRectMake(self.tableView.frame.size.width/2 - 40, 14, 80, 80)];
    
    if (USER.userDetail.canManageEmployeePhotos) {
        UIButton *btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(0, 56, _imageView.frame.size.width, 24)];
        [btnEdit setTitle:[NSLocalizedStringFromTable(@"edit", [UTIL getLanguage], @"") uppercaseString] forState:UIControlStateNormal];
        [btnEdit.titleLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
        [btnEdit setBackgroundColor:[UIColor blackColor]];
        [btnEdit.titleLabel setTextColor:[UIColor whiteColor]];
        [btnEdit addTarget:self action:@selector(onTapEditPicture:) forControlEvents:UIControlEventTouchUpInside];
        
        [_imageView addSubview:btnEdit];
    }
    
    [_imageView setBackgroundColor:[UIColor whiteColor]];
    [_imageView.layer setCornerRadius:40.0f];
    [_imageView.layer setBorderWidth:2.0f];
    [_imageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_imageView setClipsToBounds:YES];
    [_imageView setNeedsLayout];
    
    if (USER.userDetail.canManageEmployeePhotos) {
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapEditPicture)];
        singleTap.numberOfTapsRequired = 1;
        [_imageView setUserInteractionEnabled:YES];
        [_imageView addGestureRecognizer:singleTap];
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 90)];
    [view addSubview:_imageView];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.tableView.frame.size.width, 28)];
    [lbl setText:_usr.userDetail.fullname];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    [lbl setFont:[UIFont boldSystemFontOfSize:21.0f]];
    [view addSubview:lbl];
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 128, self.tableView.frame.size.width, 20)];
    [lbl setText:[NSString stringWithFormat:@"%@@firstonsite.ca", _usr.userDetail.username]];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    [lbl setTextColor:[UIColor darkGrayColor]];
    [lbl setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [view addSubview:lbl];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    switch ([indexPath row]) {
        case 0: // region
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            [cell.textLabel setText:NSLocalizedStringFromTable(@"region", [UTIL getLanguage], @"")];
            [cell.detailTextLabel setText:_usr.userDetail.region];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            break;
        case 1: // branch
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            [cell.textLabel setText:NSLocalizedStringFromTable(@"branch", [UTIL getLanguage], @"")];
            [cell.detailTextLabel setText:_usr.userDetail.branch];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            break;
        case 2: // department
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            [cell.textLabel setText:NSLocalizedStringFromTable(@"department", [UTIL getLanguage], @"")];
            [cell.detailTextLabel setText:_usr.userDetail.department];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            break;
        default: // on call status
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            [cell.textLabel setText:NSLocalizedStringFromTable(@"on_call", [UTIL getLanguage], @"")];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            if (_usr.userDetail.onCall) {
                [cell.textLabel setTextColor:[UTIL darkRedColor]];
            }
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0 && [indexPath row] == 3) {
        [self performSegueWithIdentifier:@"showOnCall" sender:self];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showOnCall"]) {
        OnCallViewController *child = (OnCallViewController *)[segue destinationViewController];
        [child setUsr:_usr];
    }
    
    if ([[segue identifier] isEqualToString:@"showMyPhoto"]) {
        MyPhotoPreviewViewController *child = (MyPhotoPreviewViewController *)[segue destinationViewController];
        [child setPhoto:_selectedImage];
        [child setUsr:_usr];
    }
}

- (void)onTapEditPicture:(id)sender {
    [self onTapEditPicture];
}

- (void)onTapEditPicture {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"update_photo", [UTIL getLanguage], @"") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionItem;
    
    actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"use_camera", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self->_sourcePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        
        // Insert the overlay
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGSize screenSizeFixed = CGSizeMake(MIN(screenSize.width, screenSize.height), MAX(screenSize.width, screenSize.height));
        self->_overlay = [[CameraPictureOverlayView alloc] initWithFrame:CGRectMake(0, 0, screenSizeFixed.width, screenSizeFixed.height)];
        [self->_sourcePicker setCameraOverlayView:self->_overlay];
        
        [self presentViewController:self->_sourcePicker animated:YES completion:^{
            [self.tabBarController.tabBar setHidden:YES];
        }];
    }];
    [actionSheet addAction:actionItem];
    
    actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"use_library", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self->_sourcePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:self->_sourcePicker animated:YES completion:^{
            [self.tabBarController.tabBar setHidden:YES];
        }];
    }];
    [actionSheet addAction:actionItem];
    
    actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"delete_photo", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [ALERT promptWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"are_you_sure_you_want_to_delete_your_photo", [UTIL getLanguage], @"") completion:^(BOOL granted) {
            if (granted) {
                [UTIL showActivity:@""];
                [self performSelector:@selector(deletePhoto) withObject:nil afterDelay:0.1f];
            }
        }];
    }];
    [actionItem setValue:[UTIL darkRedColor] forKey:@"titleTextColor"];
    [actionSheet addAction:actionItem];
    
    actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", [UTIL getLanguage], @"") style:UIAlertActionStyleCancel handler:nil];
    [actionItem setValue:[UTIL darkRedColor] forKey:@"titleTextColor"];
    [actionSheet addAction:actionItem];
    
    if (IS_IPAD()) {
        UIPopoverPresentationController *popoverPresentationController = [actionSheet popoverPresentationController];
        [popoverPresentationController setSourceRect:_imageView.frame];
        [popoverPresentationController setSourceView:self.view];
        [actionSheet setModalPresentationStyle:UIModalPresentationPopover];
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

@end
