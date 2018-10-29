//
//  CameraViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/10/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "CameraViewController.h"
#import "EquipmentDetailsViewController.h"

@interface CameraViewController ()

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:NSLocalizedStringFromTable(@"camera", [UTIL getLanguage], @"")];
    
    if (!_mode) {
        _mode = 0;
    }
    
    [self.tabBarController.tabBar setHidden:YES];
    [self checkCameraAuthorization];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)checkCameraAuthorization {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusAuthorized) { // authorized
        [self initCamera];
    } else if (status == AVAuthorizationStatusDenied) { // denied
        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"image_source_denied", [UTIL getLanguage], @"")];
    } else if (status == AVAuthorizationStatusRestricted) { // restricted
        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"image_source_denied", [UTIL getLanguage], @"")];
    } else if (status == AVAuthorizationStatusNotDetermined) { // not determined
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) { // Access has been granted
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self initCamera];
                });
            } else { // Access denied
                [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"image_source_denied", [UTIL getLanguage], @"")];
            }
        }];
    }
}

- (void)initCamera {
    _highlightView = [[UIView alloc] init];
    _highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    _highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    _highlightView.layer.borderWidth = 3;
    [self.view addSubview:_highlightView];
    
    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (_input) {
        [_session addInput:_input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];
    
    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];
    
    _prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _prevLayer.frame = self.view.bounds;
    _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_prevLayer];
    
    [_session startRunning];
    
    [self.view bringSubviewToFront:_highlightView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        if ([barCodeTypes indexOfObjectIdenticalTo:metadata.type] != NSNotFound) {
            barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
            highlightViewRect = CGRectMake(barCodeObject.bounds.origin.x, barCodeObject.bounds.origin.y, barCodeObject.bounds.size.width, barCodeObject.bounds.size.height);
            detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
        }
        
        if (detectionString != nil) {
            _response = detectionString;
            [_session stopRunning];
            
            [self performSelector:@selector(captured) withObject:nil afterDelay:.1f];
            break;
        }
    }
    
    _highlightView.frame = highlightViewRect;
}

- (void)captured {
    UIViewController *referrer = [APP_DELEGATE getPreviousScreen];
    if ([referrer isKindOfClass:[EquipmentDetailsViewController class]] || [referrer isKindOfClass:[InventoryViewController class]]) {
        NSMutableArray* stringComponents = (NSMutableArray *)[_response componentsSeparatedByString: @"ID="];
        if (stringComponents.count > 1) {
            _response = [stringComponents objectAtIndex:(stringComponents.count - 1)];
        }
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:_response forKey:@"data"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeAssetTag" object:nil userInfo:userInfo];
        
        [self performSelector:@selector(stopCaptureCamera) withObject:nil afterDelay:.1f];
    } else {
        [SCANNER executeSearch:_response];
        if (_mode == 1) {
            [self performSelector:@selector(restartCaptureCamera) withObject:nil afterDelay:1.0f];
        } else {
            [self performSelector:@selector(stopCaptureCamera) withObject:nil afterDelay:.1f];
        }
    }
}

- (void)restartCaptureCamera {
    [_highlightView removeFromSuperview];
    [_prevLayer removeFromSuperlayer];
    [self initCamera];
}

- (void)stopCaptureCamera {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)donePressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
