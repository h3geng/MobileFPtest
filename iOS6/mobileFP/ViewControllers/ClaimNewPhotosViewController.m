//
//  ClaimNewPhotosViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-05-17.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import "ClaimNewPhotosViewController.h"
#import "PhotoGalleryViewController.h"

@interface ClaimNewPhotosViewController ()

@end

@implementation ClaimNewPhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setTitle:NSLocalizedStringFromTable(@"photo_queue", [UTIL getLanguage], @"")];
    
    // init db manager
    _dbManager = [[DBManager alloc] initWithDatabaseFilename:@"pendingdb.sql"];
    
    _photos = [[NSMutableArray alloc] init];
    //_isUploading = false;
    
    // is camera available
    _cameraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    _cameraPhotoPicker = [[UIImagePickerController alloc] init];
    [_cameraPhotoPicker setDelegate:self];
    [_cameraPhotoPicker setModalPresentationStyle:UIModalPresentationCurrentContext];
    
    //_uploadedPhotos = [[NSMutableArray alloc] init];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photosPickedFromGallery:) name:@"photosPickedFromGallery" object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    // Camera notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"_UIImagePickerControllerUserDidCaptureItem" object:nil ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"_UIImagePickerControllerUserDidRejectItem" object:nil ];
    
    if (!_loadFromStorage) {
        [self performSelector:@selector(showSources) withObject:nil afterDelay:0.1f];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UTIL showActivity:NSLocalizedStringFromTable(@"loading", [UTIL getLanguage], @"")];
    [self performSelector:@selector(loadPhotosFromStorage) withObject:nil afterDelay:0.1f];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    UIDevice* device = [UIDevice currentDevice];
    [device endGeneratingDeviceOrientationNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)orientationChanged:(NSNotification *)notification {
    if ([[APP_DELEGATE getCurrentScreen] isKindOfClass:[self class]] && !_photoCaptured) {
        @try {
            if ([[UIDevice currentDevice] orientation] != UIDeviceOrientationLandscapeLeft) {
                //[_cameraPhotoPicker setCameraOverlayView:_overlay];
                [self performSelector:@selector(updateCameraOverlay:) withObject:_overlay afterDelay:0.1f];
            } else {
                [self performSelector:@selector(updateCameraOverlay:) withObject:nil afterDelay:0.1f];
                //[_cameraPhotoPicker setCameraOverlayView:nil];
            }
        } @catch (NSException *exception) {
            //NSLog(@"%@", exception.debugDescription);
        } @finally {
            
        }
    }
}

- (void)handleNotification:(NSNotification *)message {
    if ([[message name] isEqualToString:@"_UIImagePickerControllerUserDidCaptureItem"]) {
        // Remove overlay, so that it is not available on the preview view;
        //[_cameraPhotoPicker setCameraOverlayView:nil];
        [self performSelector:@selector(updateCameraOverlay:) withObject:nil afterDelay:0.1f];
        _photoCaptured = YES;
    }
    if ([[message name] isEqualToString:@"_UIImagePickerControllerUserDidRejectItem"]) {
        // Retake button pressed on preview. Add overlay, so that is available on the camera again
        //[_cameraPhotoPicker setCameraOverlayView:_overlay];
        [self performSelector:@selector(updateCameraOverlay:) withObject:_overlay afterDelay:0.1f];
        _photoCaptured = NO;
    }
}

- (void)loadPhotosFromStorage {
    _photos = [[NSMutableArray alloc] init];
    
    NSString *query = [NSString stringWithFormat:@"select * from photoInfo where claimIndx=%d and phaseIndx=%d", _claim.claimIndx, _phaseIndex];
    NSArray *arrPhotoInfo = [[NSArray alloc] initWithArray:[_dbManager loadDataFromDB:query]];
    
    for (id item in arrPhotoInfo) {
        NSInteger indexOfSelfId = [_dbManager.arrColumnNames indexOfObject:@"selfId"];
        NSInteger indexOfClaimIndx = [_dbManager.arrColumnNames indexOfObject:@"claimIndx"];
        NSInteger indexOfPhaseIndx = [_dbManager.arrColumnNames indexOfObject:@"phaseIndx"];
        NSInteger indexOfPhaseName = [_dbManager.arrColumnNames indexOfObject:@"phaseName"];
        NSInteger indexOfPhotoDescription = [_dbManager.arrColumnNames indexOfObject:@"photoDescription"];
        NSInteger indexOfPhoto = [_dbManager.arrColumnNames indexOfObject:@"photo"];
        NSInteger indexOfThumbnail = [_dbManager.arrColumnNames indexOfObject:@"thumbnail"];
        
        ClaimPhotoObject *cp = [[ClaimPhotoObject alloc] init];
        cp.selfId = [[item objectAtIndex:indexOfSelfId] intValue];
        cp.claimIndx = [[item objectAtIndex:indexOfClaimIndx] intValue];
        cp.phaseIndx = [[item objectAtIndex:indexOfPhaseIndx] intValue];
        cp.phaseName = [item objectAtIndex:indexOfPhaseName];
        cp.photoDescription = [item objectAtIndex:indexOfPhotoDescription];
        cp.photo = [UTIL loadImage:[item objectAtIndex:indexOfPhoto]];
        cp.thumbnail = [UTIL scaleImageToSize:[UTIL loadImage:[item objectAtIndex:indexOfThumbnail]] newSize:CGSizeMake(CLAIM_PHOTO_THUMB_SIZE, CLAIM_PHOTO_THUMB_SIZE)];
        
        [_photos addObject:cp];
    }
    
    [UTIL hideActivity];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_photos.count > 0) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _photos.count;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 32.0f;
    } else {
        return 12.0f;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [NSString stringWithFormat:@"%@ - %@", _claim.claimNumber, _phaseName];
    } else {
        return @"";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        return 100.0f;
    } else {
        return UITableViewAutomaticDimension;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    // get photos from storage
    if ([indexPath section] == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"photoCell" forIndexPath:indexPath];
        ClaimPhotoObject *cp = (ClaimPhotoObject *)[_photos objectAtIndex:[indexPath row]];
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [imageView setClipsToBounds:YES];
        [imageView setImage:cp.thumbnail];
        
        UILabel *label = (UILabel *)[cell viewWithTag:2];
        [label setText:cp.photoDescription];
        if ([cp.photoDescription isEqual: @""]) {
            [label setAttributedText:[[NSAttributedString alloc] initWithString:NSLocalizedStringFromTable(@"no_description_entered", [UTIL getLanguage], @"") attributes: @{ NSFontAttributeName: [UIFont italicSystemFontOfSize: [UIFont systemFontSize]]}]];
            [label setTextColor:[UIColor redColor]];
        } else {
            [label setTextColor:[UIColor blackColor]];
        }
        
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    } else {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [cell.textLabel setText:NSLocalizedStringFromTable(@"upload", [UTIL getLanguage], @"")];
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        [cell setBackgroundColor:[UTIL greenColor]];
    }
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if ([indexPath section] == 0) {
        return YES;
    } else {
        return NO;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete && [indexPath section] == 0) {
        [ALERT promptWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"are_you_sure_you_want_to_remove_this_item", [UTIL getLanguage], @"") completion:^(BOOL granted) {
            if (granted) {
                ClaimPhotoObject *cp = (ClaimPhotoObject *)[self->_photos objectAtIndex:[indexPath row]];
                if (cp.selfId > 0) {
                    NSString *query = [NSString stringWithFormat:@"delete from photoInfo where selfId=%d", cp.selfId];
                    [self->_dbManager executeQuery:query];
                    
                    [self loadPhotosFromStorage];
                }
            }
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        _selectedPhoto = (ClaimPhotoObject *)[_photos objectAtIndex:[indexPath row]];
        [self performSegueWithIdentifier:@"showPhotoDescription" sender:self];
    } else {
        [UTIL showActivity:NSLocalizedStringFromTable(@"saving", [UTIL getLanguage], @"")];
        [self performSelector:@selector(upload) withObject:nil afterDelay:0.1f];
    }
}

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

- (void)showSources {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"choose_action", [UTIL getLanguage], @"") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionItem;
    
    actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"add_from_library", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self performSegueWithIdentifier:@"showGallery" sender:self];
    }];
    [actionSheet addAction:actionItem];
    
    actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"add_using_camera", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self addPhoto];
    }];
    [actionSheet addAction:actionItem];
    
    if (_photos.count > 0) {
        actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"upload", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [UTIL showActivity:NSLocalizedStringFromTable(@"saving", [UTIL getLanguage], @"")];
            [self performSelector:@selector(upload) withObject:nil afterDelay:0.1f];
        }];
        [actionSheet addAction:actionItem];
    }
    
    actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", [UTIL getLanguage], @"") style:UIAlertActionStyleCancel handler:nil];
    [actionItem setValue:[UTIL darkRedColor] forKey:@"titleTextColor"];
    [actionSheet addAction:actionItem];
    
    if (IS_IPAD()) {
        UIPopoverPresentationController *popoverPresentationController = [actionSheet popoverPresentationController];
        [popoverPresentationController setBarButtonItem:_actionsButton];
        [actionSheet setModalPresentationStyle:UIModalPresentationPopover];
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)addPhoto {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusAuthorized) { // authorized
        [self addPhotoProcess];
    } else if (status == AVAuthorizationStatusDenied) { // denied
        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"image_source_denied", [UTIL getLanguage], @"")];
    } else if (status == AVAuthorizationStatusRestricted) { // restricted
        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"image_source_denied", [UTIL getLanguage], @"")];
    } else if (status == AVAuthorizationStatusNotDetermined) { // not determined
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) { // Access has been granted
                [self addPhotoProcess];
            } else { // Access denied
                [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"image_source_denied", [UTIL getLanguage], @"")];
            }
        }];
    }
}

- (void)addPhotoProcess {
    if (_cameraAvailable) {
        // photo capture
        [_cameraPhotoPicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [_cameraPhotoPicker setAllowsEditing:NO];
        [_cameraPhotoPicker setToolbarHidden:YES];
        [_cameraPhotoPicker setNavigationBarHidden:YES];
        
        //[_cameraPhotoPicker setShowsCameraControls:NO];
        
        // Insert the overlay
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGSize screenSizeFixed = CGSizeMake(MIN(screenSize.width, screenSize.height), MAX(screenSize.width, screenSize.height));
        
        _overlay = [[CameraOverlayView alloc] initWithFrame:CGRectMake(0, 0, screenSizeFixed.width, screenSizeFixed.height)];
        [_cameraPhotoPicker setCameraOverlayView:_overlay];
        //[_overlay setCenter:_cameraPhotoPicker.view.center];
        // check device orientation
        /*if ([[UIDevice currentDevice] orientation] != UIDeviceOrientationLandscapeLeft) {
            [_cameraPhotoPicker setCameraOverlayView:_overlay];
            _overlayExists = YES;
        }*/
        _photoCaptured = NO;
        
        //[self orientationChanged:nil];
        
        /*dispatch_async(dispatch_get_main_queue(), ^ {
            //[self performSelector:@selector(showSource) withObject:nil afterDelay:0.1f];
            //[_cameraPhotoPicker setCameraOverlayView:_overlay];
            [self performSelector:@selector(updateCameraOverlay:) withObject:_overlay afterDelay:0.1f];
            [self presentViewController:_cameraPhotoPicker animated:YES completion:^ {
                [self.tabBarController.tabBar setHidden:YES];
            }];
        });*/
        [self performSelector:@selector(presentCamera) withObject:nil afterDelay:0.1f];
        
    }
}

- (void)presentCamera {
    [self presentViewController:_cameraPhotoPicker animated:YES completion:^ {
        [self.tabBarController.tabBar setHidden:YES];
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^ {
        [self.tabBarController.tabBar setHidden:NO];
        
        [UTIL showActivity:NSLocalizedStringFromTable(@"preparing_photo", [UTIL getLanguage], @"")];
        //[self performSelector:@selector(updateCollection) withObject:nil afterDelay:0.1f];
        dispatch_async(dispatch_get_main_queue(), ^ {
            for (Phase *item in self->_claim.phaseList) {
                if (item.phaseIndx == self->_phaseIndex) {
                    self->_phaseName = item.phaseCode;
                }
            }
            
            UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
            ClaimPhotoObject *cp = [[ClaimPhotoObject alloc] init];
            cp.claimIndx = self->_claim.claimIndx;
            cp.phaseIndx = self->_phaseIndex;
            cp.phaseName = self->_phaseName;
            cp.photo = [UTIL scaleImageToSize:selectedImage newSize:CGSizeMake(CLAIM_PHOTO_SIZE, CLAIM_PHOTO_SIZE)];
            cp.thumbnail = [UTIL scaleImageToSize:selectedImage newSize:CGSizeMake(CLAIM_PHOTO_THUMB_SIZE, CLAIM_PHOTO_THUMB_SIZE)];
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                NSString *query = [NSString stringWithFormat:@"insert into photoInfo values(null, %d, '%@', %d, '%@', '%@', '%@', '%@')", cp.claimIndx, self->_claim.claimNumber, cp.phaseIndx, cp.phaseName, cp.photoDescription, @"", @""];
                [self->_dbManager executeQuery:query];
                
                if (self->_dbManager.affectedRows != 0) {
                    NSLog(@"Query was executed successfully.");
                    cp.selfId = (int)self->_dbManager.lastInsertedRowID;
                    
                    [UTIL saveImage:cp.photo name:[NSString stringWithFormat:@"IMG-%d", cp.selfId]];
                    [self->_dbManager executeQuery:[NSString stringWithFormat:@"update photoInfo set photo='%@', thumbnail='%@' where selfId=%d", [NSString stringWithFormat:@"IMG-%d", cp.selfId], [NSString stringWithFormat:@"IMG-%d", cp.selfId], cp.selfId]];
                    
                    // delete photo for better visual
                    cp.photo = nil;
                    
                    [self->_photos addObject:cp];
                    [self.tableView reloadData];
                    [UTIL hideActivity];
                    //[self updateStorage];
                }
                else{
                    NSLog(@"Could not execute the query.");
                }
            });
            
            //UIImageWriteToSavedPhotosAlbum(selectedImage, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
            
            self->_cameraPhotoPicker = picker;
            self->_photoCaptured = NO;
        });
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            //[self performSelector:@selector(showSource) withObject:nil afterDelay:0.1f];
            [self presentViewController:picker animated:YES completion:^ {
                [self.tabBarController.tabBar setHidden:YES];
                [self orientationChanged:nil];
            }];
        });
    }];
}
/*
- (void)image:(UIImage *)image finishedSavingWithError:(NSError *) error contextInfo:(void *)contextInfo {
    if (error) {
        
    }
}
*/
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^ {
        [self.tabBarController.tabBar setHidden:NO];
    }];
}

- (void)upload {
    _uploadedPhotos = [[NSMutableArray alloc] init];
    //[UTIL showActivity:NSLocalizedStringFromTable(@"saving", [UTIL getLanguage], @"")];
    
    int index = 0;
    for (ClaimPhotoObject *item in _photos) {
        index++;
        
        // get item full photo from storage
        NSString *query = [NSString stringWithFormat:@"select photo from photoInfo where selfId=%d", item.selfId];
        NSArray *arrPhotoInfo = [[NSArray alloc] initWithArray:[_dbManager loadDataFromDB:query]];
        
        for (id dbItem in arrPhotoInfo) {
            NSInteger indexOfPhoto = [_dbManager.arrColumnNames indexOfObject:@"photo"];
            item.photo = [UTIL loadImage:[dbItem objectAtIndex:indexOfPhoto]];// [UTIL decodeBase64ToImage:[dbItem objectAtIndex:indexOfPhoto]];
        }
        
        [item upload:^(bool result) {
            if (result) {
                [self->_uploadedPhotos addObject:item];
                
                NSString *query = [NSString stringWithFormat:@"delete from photoInfo where selfId=%d", item.selfId];
                [self->_dbManager executeQuery:query];
                
                if (self->_uploadedPhotos.count == self->_photos.count) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [UTIL hideActivity];
                        [self performSelector:@selector(doneUploading) withObject:nil afterDelay:1.0f];
                    });
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UTIL hideActivity];
                    [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"error_upload", [UTIL getLanguage], @"")];
                });
            }
        }];
        
        /*dispatch_async(dispatch_get_main_queue(), ^ {
            [self performSelector:@selector(uploadPhoto:) withObject:item afterDelay:0.1f];
        });
        
        if (index == _photos.count) {
            dispatch_async(dispatch_get_main_queue(), ^ {
                //_isUploading = false;
                [self removeFromStorage];
                [self goBack];
            });
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                _isUploading = false;
                [self removeFromStorage];
            });
        }*/
        
        
    }
}
/*
- (void)uploadPhoto:(ClaimPhotoObject *)item {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    if ([APP_MODE isEqual: @"1"]) {
        [request setURL:[NSURL URLWithString:UPLOAD_PRODUCTION_URL]];
    } else {
        [request setURL:[NSURL URLWithString:UPLOAD_TEST_URL]];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"ddMMyyyyHHmmss"];
    
    NSString *boundary = [NSString stringWithFormat:@"---------------------------147378098314664%@", [formatter stringFromDate:[NSDate date]]];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    NSString *fileName = [NSString stringWithFormat:@"%d-%@-%d", _claim.claimIndx, [formatter stringFromDate:[NSDate date]], item.selfId];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSString stringWithFormat:@"%@", USER.sessionId] forKey:@"sessionId"];
    [params setObject:[NSString stringWithFormat:@"%d", USER.regionId] forKey:@"regionId"];
    [params setObject:[NSString stringWithFormat:@"%d", _claim.claimIndx] forKey:@"claimIndx"];
    [params setObject:[NSString stringWithFormat:@"%d", _phaseIndex] forKey:@"phaseIndx"];
    [params setObject:@"Image" forKey:@"fileType"];
    [params setObject:fileName forKey:@"fileName"];
    [params setObject:@"jpg" forKey:@"fileExt"];
    [params setObject:item.photoDescription forKey:@"description"];
    [params setObject:@"" forKey:@"fileBase64"];
    
    for (NSString *param in params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // resize image
    CGFloat max = 1280.0f;
    CGFloat scaleFactor = 1.0f;
    CGSize scaledSize = CGSizeMake(item.photo.size.width, item.photo.size.height);
    
    if (item.photo.size.width > item.photo.size.height) {
        if (item.photo.size.width > max) {
            scaleFactor = item.photo.size.width / item.photo.size.height;
            scaledSize.width = max;
            scaledSize.height = scaledSize.width / scaleFactor;
        }
    } else {
        if (item.photo.size.height > max) {
            scaleFactor = item.photo.size.height / item.photo.size.width;
            scaledSize.height = max;
            scaledSize.width = scaledSize.height / scaleFactor;
        }
    }
    
    UIGraphicsBeginImageContextWithOptions(scaledSize, YES, 1.0f);
    CGRect scaledImageRect = CGRectMake(0.0, 0.0, scaledSize.width, scaledSize.height);
    [item.photo drawInRect:scaledImageRect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // adding a watermark to all the photos being uploaded
    NSDateFormatter *formatterCurrentYear = [[NSDateFormatter alloc] init];
    [formatterCurrentYear setDateFormat:@"yyyy"];
    NSString *currentYearString = [formatterCurrentYear stringFromDate:[NSDate date]];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:scaledImageRect];
    [imageView setImage:scaledImage];
    [imageView setBackgroundColor:[UIColor whiteColor]];
    UILabel *watermarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, scaledImageRect.size.height - 30, scaledImageRect.size.width, 30)];
    watermarkLabel.text = [NSString stringWithFormat:@"   Copyright %@, FirstOnSite Restoration Limited", currentYearString];
    watermarkLabel.textAlignment = NSTextAlignmentLeft;
    watermarkLabel.textColor = [UIColor whiteColor];
    watermarkLabel.backgroundColor = [UIColor blackColor];
    [imageView addSubview:watermarkLabel];
    
    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *imageWithWatermark = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImageJPEGRepresentation(imageWithWatermark, 0.65f);
    //NSLog(@"Size of Image(bytes):%lu",(unsigned long)[imageData length]);
    
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.jpg\"\r\n", fileName, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    NSURLSessionDataTask *postDataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSData *resultsData;
        NSMutableArray *responseData;
        if (error) {
            resultsData = [[NSString stringWithFormat:@"{\"error\":\"%@\"}", [error localizedDescription]] dataUsingEncoding:NSUTF8StringEncoding];
            responseData = [NSJSONSerialization JSONObjectWithData:resultsData options:NSJSONReadingMutableContainers error:&error];
        } else {
            NSString *results = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            resultsData = [results dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            responseData = [NSJSONSerialization JSONObjectWithData:resultsData options:NSJSONReadingMutableLeaves error:&error];
        }
        
        if ([[responseData valueForKey:@"Status"] intValue] == 0) {
            [_uploadedPhotos addObject:item];
            
            if (_uploadedPhotos.count == _photos.count) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UTIL hideActivity];
                    [self removeFromStorage];
                    [self goBack];
                });
            }
        } else {
            [UTIL hideActivity];
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:[responseData valueForKey:@"Message"]];
        }
        
    }];
    
    [postDataTask resume];
}
*/

- (void)doneUploading {
    /*dispatch_async(dispatch_get_main_queue(), ^{
        
        
    });*/
    [ALERT alertWithHandler:NSLocalizedStringFromTable(@"information", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"claim_photos_have_been_uploaded_successfully", [UTIL getLanguage], @"") completion:^(BOOL granted) {
        // remove from storage
        NSString *query = [NSString stringWithFormat:@"delete from photoInfo where claimIndx=%d and phaseIndx=%d", self->_claim.claimIndx, self->_phaseIndex];
        [self->_dbManager executeQuery:query];
        /*[self.tableView reloadData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UTIL hideActivity];
        });*/
        
        UIViewController *parent = [APP_DELEGATE getPreviousScreen];
        if ([parent isKindOfClass:[ClaimPhotosViewController class]]) {
            ClaimPhotosViewController *claimPhotosViewController = (ClaimPhotosViewController *)parent;
            [claimPhotosViewController loadPhotos];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
}
/*
- (void)goBack {
    [UTIL hideActivity];
    
    UIViewController *parent = [APP_DELEGATE getPreviousScreen];
    if ([parent isKindOfClass:[ClaimPhotosViewController class]]) {
        ClaimPhotosViewController *claimPhotosViewController = (ClaimPhotosViewController *)parent;
        [claimPhotosViewController loadPhotos];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}
 

- (void)updateStorage {
    @autoreleasepool {
        if (_photos.count != _uploadedPhotos.count && _photos.count > 0) {
            NSString *query = @"select * from photoInfo";
            //NSArray *arrPhotoInfo = [[NSArray alloc] initWithArray:[_dbManager loadDataFromDB:query]];
            
            for (ClaimPhotoObject *cp in _photos) {
                query = [NSString stringWithFormat:@"insert into photoInfo values(null, %d, '%@', %d, '%@', '%@', '%@', '%@')", _claim.claimIndx, _claim.claimNumber, _phaseIndex, cp.phaseName, cp.photoDescription, [UTIL encodeToBase64String:cp.photo], [UTIL encodeToBase64String:cp.thumbnail]];
                [_dbManager executeQuery:query];
                
                if (_dbManager.affectedRows != 0) {
                    NSLog(@"Query was executed successfully.");
                }
                else{
                    NSLog(@"Could not execute the query.");
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"photosSetIntoStorage" object:nil userInfo:nil];
            _photos = [[NSMutableArray alloc] init];
        }
    }
}

- (void)removeFromStorage {
    NSString *query = [NSString stringWithFormat:@"delete from photoInfo where claimIndx=%d and phaseIndx=%d", _claim.claimIndx, _phaseIndex];
    [_dbManager executeQuery:query];
    
    [self.tableView reloadData];
}
*/
- (void)updateCameraOverlay:(CameraOverlayView *)overlay {
    @try {
        [_cameraPhotoPicker setCameraOverlayView:overlay];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showPhotoDescription"]) {
        PhotoNotesViewController *child = (PhotoNotesViewController *)[segue destinationViewController];
        [child setSelfId:_selectedPhoto.selfId];
        [child setNotes:_selectedPhoto.photoDescription];
    }
    
    if ([[segue identifier] isEqualToString:@"showGallery"]) {
        PhotoGalleryViewController *child = (PhotoGalleryViewController *)[segue destinationViewController];
        [child setClaimIndx:_claim.claimIndx];
        [child setClaimName:_claim.claimNumber];
        [child setPhaseIndx:_phaseIndex];
        [child setPhaseName:_phaseName];
    }
}

- (IBAction)actionsPressed:(id)sender {
    [self showSources];
}

@end
