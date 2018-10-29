//
//  PhotoDetailsViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/12/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "PhotoDetailsViewController.h"

@interface PhotoDetailsViewController ()

@end

@implementation PhotoDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:NSLocalizedStringFromTable(@"photo_details", [UTIL getLanguage], @"")];
    
    //[_photoImageView setBackgroundColor:[UIColor blackColor]];
    [_photoImageView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapHandler:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [_imageScrollView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapHandler:)];
    doubleTap.numberOfTapsRequired =2 ;
    doubleTap.numberOfTouchesRequired = 1;
    [_imageScrollView addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    _imageScrollView.minimumZoomScale = MINIMUM_SCALE;
    _imageScrollView.maximumZoomScale = MAXIMUM_SCALE;
    _imageScrollView.contentSize = _photoImageView.frame.size;
    
    [UTIL showActivity:@""];
    [self performSelector:@selector(loadDetails) withObject:nil afterDelay:0.1f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _photoImageView;
}

- (void)singleTapHandler:(UITapGestureRecognizer *)gesture {
    /*UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"choose_action", [UTIL getLanguage], @"") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionSave = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"save_to_library", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [UTIL showActivity:@""];
        [self performSelector:@selector(saveToLibrary) withObject:nil afterDelay:0.1f];
    }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", [UTIL getLanguage], @"") style:UIAlertActionStyleCancel handler:nil];
    [actionCancel setValue:[UTIL darkRedColor] forKey:@"titleTextColor"];
    
    [actionSheet addAction:actionSave];
    [actionSheet addAction:actionCancel];
    
    if (IS_IPAD()) {
        UIPopoverPresentationController *popoverPresentationController = [actionSheet popoverPresentationController];
        [popoverPresentationController setSourceRect:_photoImageView.frame];
        [popoverPresentationController setSourceView:self.view];
        [actionSheet setModalPresentationStyle:UIModalPresentationPopover];
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];*/
}

- (void)saveToLibrary {
    UIImageWriteToSavedPhotosAlbum(_photoImageView.image, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *) error contextInfo:(void *)contextInfo {
    [UTIL hideActivity];
    if (error) {
        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"failed_to_save_the_image", [UTIL getLanguage], @"")];
    }
}

- (void)doubleTapHandler:(UITapGestureRecognizer *)gesture {
    if ([_imageScrollView zoomScale] > 1) {
        [_imageScrollView setZoomScale:1 animated:YES];
    } else {
        float newScale = [_imageScrollView zoomScale] * 2.5;
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
        [_imageScrollView zoomToRect:zoomRect animated:YES];
    }
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    CGRect zoomRect;

    zoomRect.size.height = [_imageScrollView frame].size.height / scale;
    zoomRect.size.width  = [_imageScrollView frame].size.width  / scale;
    
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

- (void)loadDetails {
    NSString *description = [NSString stringWithFormat:@"%@\n\n%@: %@", _photo.photoDescription, NSLocalizedStringFromTable(@"date_uploaded", [UTIL getLanguage], @""), _photo.dateUploaded];
    if ([[UTIL trim:_photo.photoDescription] isEqual: @""]) {
        description = [NSString stringWithFormat:@"%@: %@", NSLocalizedStringFromTable(@"date_uploaded", [UTIL getLanguage], @""), _photo.dateUploaded];
    }
    NSMutableAttributedString *attributedDescription = [[NSMutableAttributedString alloc] initWithString:description];
    
    NSString *imageUrl = @"";
    if (![_photo.imageURL isEqual:@""]) {
        imageUrl = _photo.imageURL;
    } else {
        if (![_photo.thumbURL isEqual:@""]) {
            imageUrl = _photo.thumbURL;
        }
    }
    
    if (![imageUrl isEqual: @""]) {
        imageUrl = [imageUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                [UTIL hideActivity];
                
                UIImage *photo = [UIImage imageWithData:data];
                [self->_photoImageView setImage:photo];
                [self->_photoTextView setAttributedText:attributedDescription];
                //NSTextAttachment *attachment = [NSTextAttachment new];
                
                /*CGFloat delta = (CGFloat)photo.size.width / (CGFloat)(_photoDetailsTextView.bounds.size.width - 10.0f);
                
                CGFloat width = photo.size.width / delta;
                CGFloat height = photo.size.height / delta;
                
                if (delta > 1) {
                    width /= delta;
                    height /= delta;
                }
                
                attachment.image = photo;
                attachment.bounds = CGRectMake(0, 0, width, height);
                NSAttributedString *attributedAttachment = [NSAttributedString attributedStringWithAttachment:attachment];
                
                [attributedDescription insertAttributedString:attributedAttachment atIndex:0];
                //[_photoDetailsTextView setAttributedText:attributedDescription];*/
            });
            
        }];
        
        [dataTask resume];
    } else {
        [UTIL hideActivity];
        [_photoTextView setAttributedText:attributedDescription];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
