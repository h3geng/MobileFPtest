//
//  LoginViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 9/27/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : BaseViewController <UIPickerViewDataSource, UIPickerViewDelegate, UIActionSheetDelegate, UITextFieldDelegate>

@property UITextField *activeTextField;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
- (IBAction)loginPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *regionTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UISwitch *usePinSwitch;
- (IBAction)usePinChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *useTouchButton;
- (IBAction)useTouchPressed:(id)sender;

@property NSMutableArray *regions;

@property UIPickerView *regionsPickerView;
@property UIToolbar *pickerToolbar;

@property GenericObject *selectedRegion;
@property GenericObject *tempSelectedRegion;
@property GenericObject *selectedCtUser;

@property BOOL moved;

@end
