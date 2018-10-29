//
//  DetailsViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 9/27/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "DetailsViewController.h"
#import "MyPhotoPreviewViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface DetailsViewController ()

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedStringFromTable(@"my_profile", [UTIL getLanguage], @"")];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"_UIImagePickerControllerUserDidCaptureItem" object:nil ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"_UIImagePickerControllerUserDidRejectItem" object:nil ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoPreviewResponse:) name:@"photoPreviewResponse" object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _sourcePicker = [[UIImagePickerController alloc] init];
    [_sourcePicker setDelegate:self];
    [_sourcePicker setAllowsEditing:NO];
    
    _action = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraChanged:) name:@"AVCaptureDeviceDidStartRunningNotification" object:nil];
}

- (void)photoPreviewResponse:(NSNotification *)notification {
    _action = [[notification userInfo] valueForKey:@"data"];
}
    
- (void)cameraChanged:(NSNotification *)notification {
    if (_sourcePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        if (_sourcePicker.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
            _sourcePicker.cameraViewTransform = CGAffineTransformIdentity;
            _sourcePicker.cameraViewTransform = CGAffineTransformScale(_sourcePicker.cameraViewTransform, -1, 1);
        } else {
            _sourcePicker.cameraViewTransform = CGAffineTransformIdentity;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tabBarController.tabBar setHidden:NO];
    // retake or done
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)updateUserPicture:(GenericObject *)obj {
    NSString *base64Data = obj.value;
    NSString *base64DataThumbnail = obj.code;
    
    USER.userDetail.picture = base64Data;
    USER.userDetail.thumbnail = base64DataThumbnail;
    
    [USER.userDetail updatePicture:USER.userId completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        [self.tableView reloadData];
    }];
}

- (void)handleNotification:(NSNotification *)message {
    if ([[message name] isEqualToString:@"_UIImagePickerControllerUserDidCaptureItem"]) {
        // Remove overlay, so that it is not available on the preview view;
        if (_sourcePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            [_sourcePicker setCameraOverlayView:nil];
        }
    }
    
    if ([[message name] isEqualToString:@"_UIImagePickerControllerUserDidRejectItem"]) {
        // Retake button pressed on preview. Add overlay, so that is available on the camera again
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGSize screenSizeFixed = CGSizeMake(MIN(screenSize.width, screenSize.height), MAX(screenSize.width, screenSize.height));
        _overlay = [[CameraPictureOverlayView alloc] initWithFrame:CGRectMake(0, 0, screenSizeFixed.width, screenSizeFixed.height)];
        [_sourcePicker setCameraOverlayView:_overlay];
    }
}

- (void)showPreview {
    [self performSegueWithIdentifier:@"showMyPhoto" sender:self];
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

- (void)deletePhoto {
    USER.userDetail.picture = @"";
    
    [USER.userDetail deletePicture:USER.userId completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 8;
    /*if (!USER.isCT) {
        numberOfRows = 5;
    }*/
    
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = UITableViewAutomaticDimension;
    
    if ([indexPath row] == 5) {
        LAContext *context = [[LAContext alloc] init];
        NSError *error = nil;
        
        if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        } else {
            height = 0.1f;
        }
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 158;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIImage *myImage = [UIImage imageNamed:@"Account"];
    
    if (![USER.userDetail.thumbnail isEqual:@""]) {
        myImage = [UTIL decodeBase64ToImage:USER.userDetail.thumbnail];
    }
    
    _imageView = [[UIImageView alloc] initWithImage:myImage];
    [_imageView setFrame:CGRectMake(self.tableView.frame.size.width/2 - 40, 14, 80, 80)];

    /*UIButton *btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(0, 56, _imageView.frame.size.width, 24)];
    [btnEdit setTitle:[NSLocalizedStringFromTable(@"edit", [UTIL getLanguage], @"") uppercaseString] forState:UIControlStateNormal];
    [btnEdit.titleLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [btnEdit setBackgroundColor:[UIColor blackColor]];
    [btnEdit.titleLabel setTextColor:[UIColor whiteColor]];
    [btnEdit addTarget:self action:@selector(onTapEditPicture:) forControlEvents:UIControlEventTouchUpInside];
    
    [_imageView addSubview:btnEdit];*/
    
    [_imageView setBackgroundColor:[UIColor whiteColor]];
    [_imageView.layer setCornerRadius:40.0f];
    [_imageView.layer setBorderWidth:2.0f];
    [_imageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_imageView setClipsToBounds:YES];
    [_imageView setNeedsLayout];
    
    /*UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapEditPicture)];
    singleTap.numberOfTapsRequired = 1;
    [_imageView setUserInteractionEnabled:YES];
    [_imageView addGestureRecognizer:singleTap];*/
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 90)];
    [view addSubview:_imageView];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.tableView.frame.size.width, 28)];
    [lbl setText:USER.userDetail.fullname];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    [lbl setFont:[UIFont boldSystemFontOfSize:21.0f]];
    [view addSubview:lbl];
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 128, self.tableView.frame.size.width, 20)];
    [lbl setText:[NSString stringWithFormat:@"%@@firstonsite.ca", USER.loginUsername]];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    [lbl setTextColor:[UIColor darkGrayColor]];
    [lbl setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [view addSubview:lbl];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    /*UIImageView *callView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Phone"]];
    [callView setContentMode:UIViewContentModeCenter];
    [callView setFrame:CGRectMake(callView.frame.origin.x, callView.frame.origin.x, callView.frame.size.width + 10, callView.frame.size.height)];
    */
    switch ([indexPath row]) {
        case 0:
            [cell.textLabel setText:NSLocalizedStringFromTable(@"current_region", [UTIL getLanguage], @"")];
            [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@", USER.region.value]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            break;
        case 1:
            [cell.textLabel setText:NSLocalizedStringFromTable(@"current_user", [UTIL getLanguage], @"")];
            [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@", USER.name]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            /*if (USER.onCall) {
                [cell setAccessoryView:callView];
            }*/
            break;
        case 2:
            if (USER.isCT) {
                if (USER.isProduction == 1) {
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"home_branch", [UTIL getLanguage], @"")];
                    [cell.detailTextLabel setText:USER.branch.value];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                } else {
                    [cell.textLabel setText:NSLocalizedStringFromTable(@"ct_user", [UTIL getLanguage], @"")];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@", USER.ctUser.value]];
                    
                    if ([USER.appCredentials count] > 1) {
                        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    } else {
                        [cell setAccessoryType:UITableViewCellAccessoryNone];
                        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    }
                }
            } else {
                [cell.textLabel setText:NSLocalizedStringFromTable(@"ct_user", [UTIL getLanguage], @"")];
                [cell.detailTextLabel setText:NSLocalizedStringFromTable(@"not_ct_user", [UTIL getLanguage], @"")];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            break;
        case 3:
            [cell.textLabel setText:NSLocalizedStringFromTable(@"home_branch", [UTIL getLanguage], @"")];
            if (USER.isCT) {
                [cell.detailTextLabel setText:USER.branch.value];
            } else {
                [cell.detailTextLabel setText:NSLocalizedStringFromTable(@"no_home_branch", [UTIL getLanguage], @"")];
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            break;
        case 4:
            [cell.textLabel setText:NSLocalizedStringFromTable(@"pin", [UTIL getLanguage], @"")];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            break;
        case 5:
        {
            LAContext *context = [[LAContext alloc] init];
            NSError *error = nil;
            
            if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
                [cell.textLabel setText:NSLocalizedStringFromTable(@"touch_id", [UTIL getLanguage], @"")];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                _useTouchID = [[UISwitch alloc] initWithFrame:CGRectZero];
                if ([[USER_DEFAULTS objectForKey:@"loginWithTouchID"] isEqual:@"1"]) {
                    [_useTouchID setOn:YES];
                }
                [_useTouchID addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
                [cell setAccessoryView:_useTouchID];
            } else {
                [cell.textLabel setText:@""];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
        }
            break;
        case 6:
            [cell.textLabel setText:NSLocalizedStringFromTable(@"language", [UTIL getLanguage], @"")];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            break;
        case 7:
            [cell.textLabel setText:NSLocalizedStringFromTable(@"on_call", [UTIL getLanguage], @"")];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            if (USER.onCall) {
                [cell.textLabel setTextColor:[UTIL darkRedColor]];
                //[cell setBackgroundColor:[UTIL lightRedColor]];
            }
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath row]) {
        case 2:
            if ([USER.appCredentials count] > 1) {
                [self showCTUsers];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
            break;
        case 4:
            [self performSegueWithIdentifier:@"showPinSetup" sender:self];
            break;
        case 5:
            /*[tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self setupTouchID];*/
            break;
        case 6:
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self showLanguages];
            break;
        case 7:
            [self performSegueWithIdentifier:@"showOnCall" sender:self];
            break;
    }
}

-(void)changeSwitch:(id)sender{
    UISwitch *uiSwitch = (UISwitch*)sender;
    if ([uiSwitch isOn]) {
        [self setupTouchID];
    } else {
        [USER_DEFAULTS setObject:@"0" forKey:@"loginWithTouchID"];
        [USER_DEFAULTS synchronize];
    }
}

- (void)setupTouchID {
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:NSLocalizedStringFromTable(@"scan_your_fingerprint_to_setup_touch", [UTIL getLanguage], @"") reply:^(BOOL success, NSError *error) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [USER_DEFAULTS setObject:@"1" forKey:@"loginWithTouchID"];
                    [USER_DEFAULTS synchronize];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->_useTouchID setOn:NO];
                    [self.tableView reloadData];
                });
            }
        }];
    } else {
        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"setup_touch_id_first_on_device", [UTIL getLanguage], @"")];
        [_useTouchID setOn:NO];
        [self.tableView reloadData];
        [USER_DEFAULTS setObject:@"0" forKey:@"loginWithTouchID"];
        [USER_DEFAULTS synchronize];
    }
}

- (void)showLanguages {
    NSString *currentLanguage = [UTIL getLanguage];
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"language", [UTIL getLanguage], @"") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([currentLanguage isEqual:@"fr"]) {
        UIAlertAction *actionEnglish = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"english", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [UTIL setLanguage:@"en"];
            [self performSelector:@selector(translate) withObject:nil afterDelay:0.1f];
        }];
        [actionSheet addAction:actionEnglish];
    } else {
        UIAlertAction *actionFrench = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"french", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [UTIL setLanguage:@"fr"];
            [self performSelector:@selector(translate) withObject:nil afterDelay:0.1f];
        }];
        [actionSheet addAction:actionFrench];
    }
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", [UTIL getLanguage], @"") style:UIAlertActionStyleCancel handler:nil];
    [actionCancel setValue:[UTIL darkRedColor] forKey:@"titleTextColor"];
    [actionSheet addAction:actionCancel];
    
    if (IS_IPAD()) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:5 inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        UIPopoverPresentationController *popoverPresentationController = [actionSheet popoverPresentationController];
        [popoverPresentationController setSourceRect:cell.frame];
        [popoverPresentationController setSourceView:self.view];
        [actionSheet setModalPresentationStyle:UIModalPresentationPopover];
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)translate {
    [self setTitle:NSLocalizedStringFromTable(@"my_details", [UTIL getLanguage], @"")];
    
    [self.tableView reloadData];
    
    UITabBarController *tabBarController = (UITabBarController*)self.tabBarController;
    [[tabBarController.viewControllers objectAtIndex:0] setTitle:NSLocalizedStringFromTable(@"home", [UTIL getLanguage], @"")];
    if (USER.isCT) {
        [[tabBarController.viewControllers objectAtIndex:1] setTitle:NSLocalizedStringFromTable(@"equipment", [UTIL getLanguage], @"")];
        [[tabBarController.viewControllers objectAtIndex:2] setTitle:NSLocalizedStringFromTable(@"claims", [UTIL getLanguage], @"")];
    }
    if ([APP_MODE isEqual:@"0"]) {
        if (USER.isCT) {
            [[tabBarController.viewControllers objectAtIndex:3] setTitle:NSLocalizedStringFromTable(@"timesheet", [UTIL getLanguage], @"")];
        } else {
            [[tabBarController.viewControllers objectAtIndex:1] setTitle:NSLocalizedStringFromTable(@"timesheet", [UTIL getLanguage], @"")];
        }
    }
}

- (void)showCTUsers {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"select_ct_user", [UTIL getLanguage], @"") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (id ctUser in USER.appCredentials) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:[ctUser valueForKey:@"CTUserCode"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            USER.ctUser = [[GenericObject alloc] init];
            USER.ctUser.value = [ctUser valueForKey:@"CTUserCode"];
            USER.ctUser.genericId = [ctUser valueForKey:@"CTUserId"];
            
            [self.tableView reloadData];
        }];
        [actionSheet addAction:action];
    }
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", [UTIL getLanguage], @"") style:UIAlertActionStyleCancel handler:nil];
    [actionCancel setValue:[UTIL darkRedColor] forKey:@"titleTextColor"];
    
    [actionSheet addAction:actionCancel];
    
    if (IS_IPAD()) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        UIPopoverPresentationController *popoverPresentationController = [actionSheet popoverPresentationController];
        [popoverPresentationController setSourceRect:cell.frame];
        [popoverPresentationController setSourceView:self.view];
        [actionSheet setModalPresentationStyle:UIModalPresentationPopover];
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
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
    if ([[segue identifier] isEqualToString:@"showMyPhoto"]) {
        MyPhotoPreviewViewController *child = (MyPhotoPreviewViewController *)[segue destinationViewController];
        [child setPhoto:_selectedImage];
        [child setUsr:USER];
    }
    if ([[segue identifier] isEqualToString:@"showOnCall"]) {
        OnCallViewController *child = (OnCallViewController *)[segue destinationViewController];
        [child setUsr:USER];
    }
}

@end
