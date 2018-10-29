//
//  PhotoDetailsViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/12/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClaimPhoto.h"

@interface PhotoDetailsViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate>

#define MINIMUM_SCALE 1.0
#define MAXIMUM_SCALE 6.0
@property CGPoint translation;
@property ClaimPhoto *photo;

@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UITextView *photoTextView;

@end
