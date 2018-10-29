//
//  ClaimPhotosViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/6/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "ClaimPhotosViewController.h"
#import "PhotoDetailsViewController.h"
#import "PhotoPreviewViewController.h"
#import "Phase.h"

@interface ClaimPhotosViewController ()

@end

@implementation ClaimPhotosViewController

static NSString * const reuseIdentifier = @"claimPhotoCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedStringFromTable(@"photos", [UTIL getLanguage], @"")];
    
    _itemsInRow = 3;
    _selectedPhaseName = NSLocalizedStringFromTable(@"all_phases", [UTIL getLanguage], @"");
    _photosLoaded = false;
    
    // Uncomment the following line to preserve selection between presentations
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    _phaseIndex = 0;
    _photos = [[NSMutableArray alloc] init];
    _photoItems = [[NSMutableArray alloc] init];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [self.collectionView setCollectionViewLayout:layout];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    
    _photosPage = 0;
    [UTIL showActivity:NSLocalizedStringFromTable(@"loading_photos", [UTIL getLanguage], @"")];
    [self performSelector:@selector(loadPhotos) withObject:nil afterDelay:0.1f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadPhotos {
    _photos = [[NSMutableArray alloc] init];
    _photoItems = [[NSMutableArray alloc] init];
    
    [API getClaimPhotos:USER.sessionId regionId:USER.regionId claimIndex:_claim.claimIndx phaseIndex:_phaseIndex page:_photosPage completion:^(NSMutableArray *result) {
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqualToString: @""]) {
            // get phase name
            for (Phase *item in self->_claim.phaseList) {
                if (item.phaseIndx ==self->_phaseIndex) {
                    self->_selectedPhaseName = [NSString stringWithFormat:NSLocalizedStringFromTable(@"view_phase_", [UTIL getLanguage], @""), item.phaseCode];
                }
            }
            
            NSMutableArray *responseData = [result valueForKey:@"d"];
            if ([responseData valueForKey:@"items"] && [responseData valueForKey:@"items"] != [NSNull null]) {
                NSMutableArray *itemsData = [responseData valueForKey:@"items"];
                
                self->_totalItems = [[responseData valueForKey:@"totalItems"] intValue];
                self->_perPage = [[responseData valueForKey:@"perPage"] intValue];
                self->_currentPage = [[responseData valueForKey:@"currentPage"] intValue];
                
                int ind = 0;
                for (id photo in itemsData) {
                    ind++;
                    
                    ClaimPhoto *cp = [[ClaimPhoto alloc] init];
                    [cp initWithData:photo];
                    
                    NSString *imageUrl = @"";
                    if (![cp.thumbURL isEqual:@""]) {
                        imageUrl = cp.thumbURL;
                    } else {
                        if (![cp.imageURL isEqual:@""]) {
                            imageUrl = cp.imageURL;
                        }
                    }
                    
                    if (![imageUrl isEqual: @""]) {
                        imageUrl = [imageUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                        NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                            if (data != nil) {
                                [self->_photoItems addObject:data];
                                [self->_photos addObject:cp];
                            }
                            
                            if (ind == itemsData.count) {
                                [UTIL hideActivity];
                                self->_photosLoaded = true;
                                
                                dispatch_async(dispatch_get_main_queue(), ^ {
                                    [self.collectionView reloadData];
                                });
                            }
                            //UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:data]];
                            
                            //[imgView setFrame:(CGRect){ 0, 0, IS_IPAD() ? CELL_SIZE_IPAD : CELL_SIZE_IPHONE } ];
                            //[cell.contentView addSubview:imgView];
                            
                        }];
                        [dataTask resume];
                    }
                }
                if (itemsData.count == 0) {
                    [UTIL hideActivity];
                    self->_photosLoaded = true;
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        [self.collectionView reloadData];
                    });
                }
            }
        } else {
            [UTIL hideActivity];
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
        }
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showPhoto"]) {
        PhotoDetailsViewController *child = (PhotoDetailsViewController *)[segue destinationViewController];
        [child setPhoto:_selectedPhoto];
    }
    if ([[segue identifier] isEqualToString:@"showPreview"]) {
        PhotoPreviewViewController *child = (PhotoPreviewViewController *)[segue destinationViewController];
        [child setPhoto:_selectedImage];
        [child setClaim:_claim];
    }
    if ([[segue identifier] isEqualToString:@"showNewPhotos"]) {
        ClaimNewPhotosViewController *child = (ClaimNewPhotosViewController *)[segue destinationViewController];
        [child setPhaseName:_phaseName];
        [child setPhaseIndex:_phaseIndex];
        [child setClaim:_claim];
        [child setLoadFromStorage:NO];
    }
}

- (void)loadMorePhotos {
    [UTIL showActivity:NSLocalizedStringFromTable(@"loading_photos", [UTIL getLanguage], @"")];
    [self performSelector:@selector(loadPhotos) withObject:nil afterDelay:0.1f];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photos.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
    
    if (kind == UICollectionElementKindSectionFooter) {
        view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer" forIndexPath:indexPath];
        if ((_currentPage + 1) * _perPage < _totalItems) {
            _photosPage += 1;
            
            UIButton *loadMoreButton = [[UIButton alloc] init];
            [loadMoreButton setTitle:NSLocalizedStringFromTable(@"load_more", [UTIL getLanguage], @"") forState:UIControlStateNormal];
            [loadMoreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [loadMoreButton setTintColor:[UTIL darkBlueColor]];
            [loadMoreButton setBackgroundColor:[UTIL darkBlueColor]];
            [loadMoreButton.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
            [loadMoreButton.layer setBorderWidth:1.5f];
            [loadMoreButton.layer setCornerRadius:5.0f];
            [loadMoreButton.layer setBorderColor:[UTIL darkBlueColor].CGColor];
            [loadMoreButton setTitleEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
            [loadMoreButton sizeToFit];
            [loadMoreButton addTarget:self action:@selector(loadMorePhotos) forControlEvents:UIControlEventTouchUpInside];
            [loadMoreButton setFrame:CGRectMake(self.view.bounds.size.width/2 - loadMoreButton.bounds.size.width/2 - 20, 9, loadMoreButton.bounds.size.width + 40, loadMoreButton.bounds.size.height)];
            [view addSubview:loadMoreButton];
        }
    } else {
        UILabel *label;
        UIButton *addButton;
        
        if ([view viewWithTag:1302]) {
            label = (UILabel *)[view viewWithTag:1302];
        } else {
            label = [[UILabel alloc] init];
            [label setTag:1302];
            [label setFrame:CGRectMake(20, 9, self.view.bounds.size.width, 36.0f)];
            [label setFont:[UIFont systemFontOfSize:17.0]];
            
            [view addSubview:label];
            [view setBackgroundColor:[UIColor colorWithRed:239.0/255.0f green:239.0/255.0f blue:244.0/255.0f alpha:1]];
            
            addButton = [[UIButton alloc] init];
            [addButton setTitle:[NSString stringWithFormat:@"+ %@", NSLocalizedStringFromTable(@"add_new", [UTIL getLanguage], @"")] forState:UIControlStateNormal];
            [addButton setTitleColor:[UTIL darkBlueColor] forState:UIControlStateNormal];
            [addButton setTintColor:[UTIL darkBlueColor]];
            [addButton.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
            [addButton.layer setBorderWidth:1.5f];
            [addButton.layer setCornerRadius:5.0f];
            [addButton.layer setBorderColor:[UTIL darkBlueColor].CGColor];
            [addButton setTitleEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
            [addButton sizeToFit];
            [addButton addTarget:self action:@selector(addPhotoPressed:) forControlEvents:UIControlEventTouchUpInside];
            [addButton setFrame:CGRectMake(self.view.bounds.size.width - addButton.bounds.size.width - 40, 9, addButton.bounds.size.width + 20, addButton.bounds.size.height)];
            [view addSubview:addButton];
        }
        
        if (_photos.count == 0 && _photosLoaded) {
            [label setText:[NSString stringWithFormat:@"%@ (%@)", _selectedPhaseName, NSLocalizedStringFromTable(@"no_photos", [UTIL getLanguage], @"")]];
        } else {
            [label setText:_selectedPhaseName];
        }
    }
    
    return view;
}

- (void)addPhotoPressed:(id)sender {
    if (_claim.phaseList.count > 0) {
        [self performSelector:@selector(showPhases) withObject:nil afterDelay:0.1f];
    } else {
        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"no_phases_photo", [UTIL getLanguage], @"")];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(self.view.bounds.size.width, 52.0f);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if ((_currentPage + 1) * _perPage < _totalItems) {
        return CGSizeMake(self.view.bounds.size.width, 52.0f);
    } else {
        return CGSizeZero;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if ([_photos count] > [indexPath row]) {
        ClaimPhoto *cp = (ClaimPhoto *)[_photos objectAtIndex:[indexPath row]];
        NSData *data = [_photoItems objectAtIndex:[indexPath row]];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:data]];
        [imgView setContentMode:UIViewContentModeScaleAspectFill];
        CGFloat size_c = (self.view.bounds.size.width - 40)/_itemsInRow - 10;
        [imgView setFrame:(CGRect){ 0, 0, CGSizeMake(size_c, size_c) } ];
        [imgView setClipsToBounds:YES];
        [imgView setContentMode:UIViewContentModeScaleAspectFill];
        [cell.contentView addSubview:imgView];
        
        UILabel *label;
        CGFloat left;
        CGFloat indicatorSize = 32.0f;
        // Has description label
        if (![cp.photoDescription isEqual: @""]) {
            label = [UTIL getPhotoLabel:@"D"];
            [label setFrame:CGRectMake(size_c - indicatorSize - 10, size_c - indicatorSize - 10, indicatorSize, indicatorSize)];
            
            [cell.contentView addSubview:label];
        }
        
        if (cp.sentToXASuccess == 1) {
            label = [UTIL getPhotoLabel:@"Xa"];
            left = size_c - indicatorSize - 10;
            if (![cp.photoDescription isEqual: @""]) {
                left -= indicatorSize - 6;
            }
            [label setFrame:CGRectMake(left, size_c - indicatorSize - 10, indicatorSize, indicatorSize)];
            
            [cell.contentView addSubview:label];
        }
        
        if (![cp.fileMetaData isEqual: @""]) {
            label = [UTIL getPhotoLabel:@"ISI"];
            left = size_c - indicatorSize - 10;
            if (![cp.photoDescription isEqual: @""]) {
                left -= indicatorSize - 6;
            }
            if (cp.sentToXASuccess == 1) {
                left -= indicatorSize - 6;
            }
            [label setFrame:CGRectMake(left, size_c - indicatorSize - 10, indicatorSize, indicatorSize)];
            
            [cell.contentView addSubview:label];
        }
        
        [cell.contentView.layer setCornerRadius:2.0f];
        
        [cell.layer setBorderColor:[[UTIL lightGrayColor] CGColor]];
        [cell.layer setBorderWidth:1.2f];
        [cell.layer setCornerRadius:2.0f];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat size_c = (self.view.bounds.size.width - 40)/_itemsInRow - 10;
    return CGSizeMake(size_c, size_c);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(20, 22, 30, 22);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _selectedPhoto = (ClaimPhoto *)[_photos objectAtIndex:[indexPath row]];
    [self performSegueWithIdentifier:@"showPhoto" sender:self];
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

- (IBAction)actionsPressed:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"choose_phase", [UTIL getLanguage], @"") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    /*UIAlertAction *actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"add_new", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
        [self performSelector:@selector(showPhases) withObject:nil afterDelay:0.1f];
    }];
    [actionSheet addAction:actionItem];*/
    
    UIAlertAction *actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"all_phases", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        self->_phaseIndex = 0;
        self->_selectedPhaseName = NSLocalizedStringFromTable(@"all_phases", [UTIL getLanguage], @"");
        [UTIL showActivity:NSLocalizedStringFromTable(@"loading_photos", [UTIL getLanguage], @"")];
        [self performSelector:@selector(loadPhotos) withObject:nil afterDelay:0.1f];
    }];
    [actionSheet addAction:actionItem];
    
    for (Phase *item in _claim.phaseList) {
        actionItem = [UIAlertAction actionWithTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"view_phase_", [UTIL getLanguage], @""), item.phaseCode] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            self->_phaseIndex = item.phaseIndx;
            self->_selectedPhaseName = [NSString stringWithFormat:NSLocalizedStringFromTable(@"view_phase_", [UTIL getLanguage], @""), item.phaseCode];
            
            [UTIL showActivity:NSLocalizedStringFromTable(@"loading_photos", [UTIL getLanguage], @"")];
            [self performSelector:@selector(loadPhotos) withObject:nil afterDelay:0.1f];
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

- (void)showPhases {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"select_phase", [UTIL getLanguage], @"") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionItem;
    
    for (Phase *item in _claim.phaseList) {
        actionItem = [UIAlertAction actionWithTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"view_phase_", [UTIL getLanguage], @""), item.phaseCode] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            self->_phaseIndex = item.phaseIndx;
            self->_phaseName = item.phaseCode;
            //[self performSelector:@selector(showSources) withObject:nil afterDelay:0.1f];
            [self performSegueWithIdentifier:@"showNewPhotos" sender:self];
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

@end
