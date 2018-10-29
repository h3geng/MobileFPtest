//
//  PinViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 3/27/15.
//  Copyright (c) 2015 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PinViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) IBOutlet UITextField *pin1;
@property (strong, nonatomic) IBOutlet UITextField *pin2;
@property (strong, nonatomic) IBOutlet UITextField *pin3;
@property (strong, nonatomic) IBOutlet UITextField *pin4;

@property NSString *first;
@property NSString *second;

@end
