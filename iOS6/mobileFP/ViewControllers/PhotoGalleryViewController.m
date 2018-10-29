//
//  ClaimNewPhotosViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-05-16.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import "PhotoGalleryViewController.h"

@interface PhotoGalleryViewController ()

@end

@implementation PhotoGalleryViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    [self setTitle:NSLocalizedStringFromTable(@"gallery", [UTIL getLanguage], @"")];
    
    _itemsInRow = 3;
    _dbManager = [[DBManager alloc] initWithDatabaseFilename:@"pendingdb.sql"];
    
    [self.collectionView setAllowsMultipleSelection:YES];
    [self performSelector:@selector(showLibrary) withObject:nil afterDelay:0.1f];
}

- (void)showLibrary {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        // Access has been granted.
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self performSelector:@selector(showLibraryContent) withObject:nil afterDelay:0.1f];
        });
    } else if (status == PHAuthorizationStatusDenied) {
        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"image_source_denied", [UTIL getLanguage], @"")];
    } else if (status == PHAuthorizationStatusNotDetermined) {
        // Access has not been determined.
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                // Access has been granted.
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [self performSelector:@selector(showLibraryContent) withObject:nil afterDelay:0.1f];
                });
            } else {
                // Access has been denied.
                [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"image_source_denied", [UTIL getLanguage], @"")];
            }
        }];
    } else if (status == PHAuthorizationStatusRestricted) {
        // Restricted access
        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"image_source_denied", [UTIL getLanguage], @"")];
    }
}

- (void)showLibraryContent {
    _selectedPhotoObjects = [[NSMutableArray alloc] init];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    _assets = [PHAsset fetchAssetsWithOptions:options];
    
    _imageManager = [[PHCachingImageManager alloc] init];
    
    _phImageRequestOptions = [[PHImageRequestOptions alloc] init];
    _phImageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    _phImageRequestOptions.synchronous = YES;
    _phImageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showPhotoDescription"]) {
        TextReaderViewController *child = (TextReaderViewController *)[segue destinationViewController];
        [child setHeaderTitle:@"Photo Description"];
        [child setText:_selectedPhoto.photoDescription];
        [child setAllowEdit:YES];
    }
}
*/
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numberOfItems = 0;
    if (_assets != nil) {
        numberOfItems = _assets.count;
    }
    
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:999];
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:[cell bounds]];
        [imageView setTag:999];
        [imageView setClipsToBounds:YES];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        
        [cell addSubview:imageView];
    }
    PHAsset *asset = _assets[indexPath.item];
    [_imageManager requestImageForAsset:asset targetSize:imageView.frame.size contentMode:PHImageContentModeAspectFill options:_phImageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
         imageView.image = result;
    }];
    
    NSArray *arr = self.collectionView.indexPathsForSelectedItems;
    if ([arr indexOfObject:indexPath] == NSNotFound) {
        UIImageView *checkView = [cell viewWithTag:108];
        [checkView removeFromSuperview];
        [imageView setAlpha:1.0f];
    } else {
        UIImageView *checkView = [cell viewWithTag:108];
        if (!checkView) {
            checkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Check"]];
            [checkView setTag:108];
            [checkView setFrame:CGRectMake(cell.frame.size.width - checkView.frame.size.width - 10, cell.frame.size.height - checkView.frame.size.height - 10, checkView.frame.size.width, checkView.frame.size.height)];
            [cell addSubview:checkView];
        }
        [imageView setAlpha:0.5f];
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    UIImageView *checkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Check"]];
    [checkView setTag:108];
    [checkView setFrame:CGRectMake(cell.frame.size.width - checkView.frame.size.width - 10, cell.frame.size.height - checkView.frame.size.height - 10, checkView.frame.size.width, checkView.frame.size.height)];
    [cell addSubview:checkView];
    
    UIImageView *imageView = [cell viewWithTag:999];
    [imageView setAlpha:0.5f];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *checkView = [cell viewWithTag:108];
    [checkView removeFromSuperview];
    
    UIImageView *imageView = [cell viewWithTag:999];
    [imageView setAlpha:1.0f];
}
/*
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:NO];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}
*/
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat size_c = (self.view.bounds.size.width)/_itemsInRow - 1;
    return CGSizeMake(size_c, size_c);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

#pragma mark <UICollectionViewDelegate>


// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

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
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.collectionView.indexPathsForSelectedItems];
    
    if (arr.count > 0) {
        [UTIL showActivity:NSLocalizedStringFromTable(@"preparing_photos", [UTIL getLanguage], @"")];
        [self performSelector:@selector(updateCollection) withObject:nil afterDelay:0.1f];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)updateCollection {
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.collectionView.indexPathsForSelectedItems];
    
    int index = 0;
    for (NSIndexPath *indexPath in arr) {
        PHAsset *asset = [_assets objectAtIndex:[indexPath row]];
        index++;
        [_imageManager requestImageForAsset:asset targetSize:CGSizeMake(1280.0f, 1280.0f) contentMode:PHImageContentModeAspectFill options:_phImageRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                [self->_selectedPhotoObjects addObject:result];
                
                NSString *query = [NSString stringWithFormat:@"insert into photoInfo values(null, %d, '%@', %d, '%@', '%@', '%@', '%@')", self->_claimIndx, self->_claimName, self->_phaseIndx, self->_phaseName, @"", @"", @""];
                [self->_dbManager executeQuery:query];
                
                if (self->_dbManager.affectedRows != 0) {
                    int selfId = (int)self->_dbManager.lastInsertedRowID;
                    [UTIL saveImage:result name:[NSString stringWithFormat:@"IMG-%d", selfId]];
                    [self->_dbManager executeQuery:[NSString stringWithFormat:@"update photoInfo set photo='%@', thumbnail='%@' where selfId=%d", [NSString stringWithFormat:@"IMG-%d", selfId], [NSString stringWithFormat:@"IMG-%d", selfId], selfId]];
                }
            }
            
            if (index == arr.count) {
                [UTIL hideActivity];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

@end
