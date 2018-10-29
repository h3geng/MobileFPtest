//
//  PhotoPreviewViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/12/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "PhotoPreviewViewController.h"
#import "TextReaderViewController.h"
#import "ClaimPhotosViewController.h"

@interface PhotoPreviewViewController ()

@end

@implementation PhotoPreviewViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.photo = [[UIImage alloc] init];
        self.claim = [[Claim alloc] init];
        self.notes = @"";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:NSLocalizedStringFromTable(@"preview", [UTIL getLanguage], @"")];
    
    [_mainImageView setImage:_photo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showNotes"]) {
        TextReaderViewController *child = (TextReaderViewController *)[segue destinationViewController];
        [child setAllowEdit:true];
        [child setText:_notes];
    }
}

- (void)save {
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
    
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy-HH-mm-ss"];
    NSString *fileName = [NSString stringWithFormat:@"%d-%@", _claim.claimIndx, [formatter stringFromDate:[NSDate date]]];
    
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    [_params setObject:[NSString stringWithFormat:@"%@", USER.sessionId] forKey:@"sessionId"];
    [_params setObject:[NSString stringWithFormat:@"%d", USER.regionId] forKey:@"regionId"];
    [_params setObject:[NSString stringWithFormat:@"%d", _claim.claimIndx] forKey:@"claimIndx"];
    [_params setObject:@"0" forKey:@"phaseIndx"];
    [_params setObject:@"Image" forKey:@"fileType"];
    [_params setObject:fileName forKey:@"fileName"];
    [_params setObject:@"jpg" forKey:@"fileExt"];
    [_params setObject:_notes forKey:@"description"];
    [_params setObject:@"" forKey:@"fileBase64"];
    
    for (NSString *param in _params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // resize image
    float actualHeight = _photo.size.height;
    float actualWidth = _photo.size.width;
    float imgRatio = actualWidth / actualHeight;
    float maxRatio = 320.0 / 480.0;
    
    if(imgRatio != maxRatio) {
        if (imgRatio < maxRatio) {
            imgRatio = 480.0 / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = 480.0;
        } else {
            imgRatio = 320.0 / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = 320.0;
        }
    }
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [_photo drawInRect:rect];
    UIImage *imageResized = UIGraphicsGetImageFromCurrentImageContext();
    // end resize image
    
    // adding a watermark to all the photos being uploaded
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    imageView.image = imageResized;
    UILabel *watermarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, actualHeight - 30, actualWidth, actualHeight)];
    watermarkLabel.text = @"FirstOnSite";
    watermarkLabel.textAlignment = NSTextAlignmentLeft;
    watermarkLabel.textColor = [UIColor blackColor];
    watermarkLabel.backgroundColor = [UIColor clearColor];
    [imageView addSubview:watermarkLabel];
    
    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *imageWithWatermark = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImageJPEGRepresentation(imageWithWatermark, 100);
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", @"xyz"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [UTIL hideActivity];
        
        UIViewController *parent = [APP_DELEGATE getPreviousScreen];
        if ([parent isKindOfClass:[ClaimPhotosViewController class]]) {
            ClaimPhotosViewController *claimPhotosViewController = (ClaimPhotosViewController *)parent;
            [claimPhotosViewController loadPhotos];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [dataTask resume];
}

- (IBAction)actionPressed:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"choose_action", [UTIL getLanguage], @"") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionAddNote = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"add_notes", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self performSegueWithIdentifier:@"showNotes" sender:self];
    }];
    
    UIAlertAction *actionSave = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"save", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [UTIL showActivity:NSLocalizedStringFromTable(@"saving", [UTIL getLanguage], @"")];
        [self performSelector:@selector(save) withObject:nil afterDelay:0.1f];
    }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", [UTIL getLanguage], @"") style:UIAlertActionStyleCancel handler:nil];
    [actionCancel setValue:[UTIL darkRedColor] forKey:@"titleTextColor"];
    
    [actionSheet addAction:actionAddNote];
    [actionSheet addAction:actionSave];
    [actionSheet addAction:actionCancel];
    
    if (IS_IPAD()) {
        UIPopoverPresentationController *popoverPresentationController = [actionSheet popoverPresentationController];
        popoverPresentationController.barButtonItem = _actionButton;
        [actionSheet setModalPresentationStyle:UIModalPresentationPopover];
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

@end
