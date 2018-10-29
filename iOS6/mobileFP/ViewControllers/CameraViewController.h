//
//  CameraViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/10/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EquipmentDetailsViewController.h"
#import "InventoryViewController.h"

@interface CameraViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>

@property int mode; // 0-single, 1-batch
@property NSString *response;

@property UIView *highlightView;

@property AVCaptureSession *session;
@property AVCaptureDevice *device;
@property AVCaptureDeviceInput *input;
@property AVCaptureMetadataOutput *output;
@property AVCaptureVideoPreviewLayer *prevLayer;

- (IBAction)donePressed:(id)sender;

@end
