//
//  LoginViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 9/27/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "LoginViewController.h"
#import "ApplicationViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface LoginViewController ()
    
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // delete param which was used before for pending photos
    [USER_DEFAULTS removeObjectForKey:@"pendingPhotos"];
    [USER_DEFAULTS synchronize];
    
    if ([APP_MODE isEqual: @"0"]) {
        [_loginButton setBackgroundColor:[UTIL darkRedColor]];
        [_loginButton setTintColor:[UIColor whiteColor]];
    }
    
    // add overlay for test version
    /*if ([APP_MODE isEqual: @"0"]) {
        UIView *overlayTestView = [[UIView alloc] initWithFrame: CGRectMake(0,-[UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 34)];
        [overlayTestView setBackgroundColor:[UTIL darkRedColor]];
        [overlayTestView setAutoresizesSubviews:YES];
        [overlayTestView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, [UIScreen mainScreen].bounds.size.width, 38)];
        [label setFont:[UIFont systemFontOfSize:12]];
        [label setTextColor:[UIColor whiteColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor whiteColor]];
        [label setText:NSLocalizedStringFromTable(@"test_version", [UTIL getLanguage], @"")];
        
        [overlayTestView addSubview:label];
        [label setAlpha:0];
        
        [UIView animateWithDuration:1 animations:^{overlayTestView.center = CGPointMake(overlayTestView.center.x, roundf(overlayTestView.bounds.size.height/2.));[label setAlpha:1.0];}];
        
        [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:overlayTestView];
    }*/
    
    if ([USER_DEFAULTS objectForKey:@"pin"]) {
        NSString *pin = [USER_DEFAULTS objectForKey:@"pin"];
        if (pin.length == 4) {
            [_usePinSwitch setOn:YES];
            [_passwordTextField setKeyboardType:UIKeyboardTypeNumberPad];
            [_passwordTextField setPlaceholder:@"4 Digit PIN"];
        } else {
            [_usePinSwitch setOn:NO];
            [_passwordTextField setKeyboardType:UIKeyboardTypeDefault];
            [_passwordTextField setPlaceholder:@"Password"];
        }
    } else {
        [_usePinSwitch setOn:NO];
        [_passwordTextField setKeyboardType:UIKeyboardTypeDefault];
        [_passwordTextField setPlaceholder:@"Password"];
    }
    
    if ([USER_DEFAULTS objectForKey:@"autologin"]) {
        bool autoLogin = [[USER_DEFAULTS objectForKey:@"autologin"] boolValue];
        if (autoLogin) {
            [_usernameTextField setText:[USER_DEFAULTS objectForKey:@"loginUsername"]];
            [_passwordTextField setText:[USER_DEFAULTS objectForKey:@"loginPassword"]];
            
            _selectedRegion = [NSKeyedUnarchiver unarchiveObjectWithData:[USER_DEFAULTS objectForKey:@"loginRegion"]];
            _selectedCtUser = [NSKeyedUnarchiver unarchiveObjectWithData:[USER_DEFAULTS objectForKey:@"loginCTUser"]];
            
            if (![[UTIL trim:_usernameTextField.text] isEqual: @""] && ![[UTIL trim:_passwordTextField.text] isEqual: @""] && _selectedRegion && _selectedCtUser) {
                [UTIL showActivity:NSLocalizedStringFromTable(@"loging_in", [UTIL getLanguage], @"")];
                [self performSelector:@selector(autologin) withObject:nil afterDelay:.1f];
            } else {
                [self loadDefaults];
            }
        } else {
            [self loadDefaults];
        }
    } else {
        [self loadDefaults];
    }
    
    [[LOCATION locationManager] startUpdatingLocation];
}

- (void)loadDefaults {
    // load regions each time login screen will be opened unless cached
    if ([USER_DEFAULTS objectForKey:@"regions"] && ![APP_MODE isEqual: @"0"]) {
        _regions = [[NSMutableArray alloc] init];
        NSMutableArray *regs = [NSKeyedUnarchiver unarchiveObjectWithData:[USER_DEFAULTS objectForKey:@"regions"]];
        for (GenericObject *region in regs) {
            NSRange range = [region.value rangeOfString:@"Test"];
            if (range.location == NSNotFound) {
                [_regions addObject:region];
            }
        }
        
        [_regionsPickerView reloadAllComponents];
    } else {
        [UTIL showActivity:NSLocalizedStringFromTable(@"loading_regions", [UTIL getLanguage], @"")];
        [self performSelector:@selector(loadRegions) withObject:nil afterDelay:.1f];
    }
}

- (void)autologin {
    NSString *passText = _passwordTextField.text;
    if ([_usePinSwitch isOn]) {
        passText = [USER_DEFAULTS objectForKey:@"loginPassword"];
    }
    
    [USER login:_usernameTextField.text password:passText region:[_selectedRegion.genericId intValue] location:LOCATION.lastSavedLocation completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if (![error isEqualToString: @""]) {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:error];
        } else {
            if ([USER.sessionId isEqual: [NSNull null]]) {
                [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"invalid_credentials", [UTIL getLanguage], @"")];
            } else {
                [self openApp];
            }
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // fingerprint
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    
    if ([[USER_DEFAULTS objectForKey:@"loginWithTouchID"] isEqual:@"1"]) {
        [_useTouchButton setHidden:NO];
    } else {
        [_useTouchButton setHidden:YES];
    }
    
    // read username from cache if any
    NSString *loginUsername = [USER_DEFAULTS objectForKey:@"loginUsername"];
    if (loginUsername != nil) {
        [_usernameTextField setText:loginUsername];
        [_passwordTextField becomeFirstResponder];
    }
    
    _selectedRegion = [[GenericObject alloc] init];
    GenericObject *loginRegion;
    id regionObject = [USER_DEFAULTS objectForKey:@"loginRegion"];
    if (regionObject != nil) {
        loginRegion = (GenericObject *)[NSKeyedUnarchiver unarchiveObjectWithData:regionObject];
    }
    if (loginRegion) {
        _selectedRegion = loginRegion;
    } else {
        _selectedRegion.genericId = @"0";
        _selectedRegion.value = NSLocalizedStringFromTable(@"select_region", [UTIL getLanguage], @"");
    }
    [_regionTextField setText:_selectedRegion.value];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    _regionsPickerView = [[UIPickerView alloc] init];
    _regionsPickerView.delegate = self;
    _regionsPickerView.dataSource = self;
    
    _regionTextField.inputView = _regionsPickerView;
    
    _pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(handleCancelTap:)];
    UIBarButtonItem *flexibleSpacebutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(handleDoneTap:)];
    _pickerToolbar.tintColor = [UTIL darkBlueColor];
    
    [_pickerToolbar setItems:[NSArray arrayWithObjects:cancelButton, flexibleSpacebutton, doneButton, nil] animated:YES];
    _regionTextField.inputAccessoryView = _pickerToolbar;
    
    [self localize];
    
    // execute touch id if necessary
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [self touchID];
    } else {
        [_useTouchButton setHidden:YES];
    }
}

- (void)localize {
    [_loginButton setTitle:NSLocalizedStringFromTable(@"login", [UTIL getLanguage], @"") forState:UIControlStateNormal];
}

- (void)touchID {
    if ([[USER_DEFAULTS objectForKey:@"loginWithTouchID"] isEqual:@"1"]) {
        LAContext *context = [[LAContext alloc] init];
        NSError *error = nil;
        
        if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:NSLocalizedStringFromTable(@"scan_your_fingerprint_to_login", [UTIL getLanguage], @"") reply:^(BOOL success, NSError *error) {
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self->_usernameTextField setText:[USER_DEFAULTS objectForKey:@"loginUsername"]];
                        [self->_passwordTextField setText:[USER_DEFAULTS objectForKey:@"loginPassword"]];
                        
                        self->_selectedRegion = [NSKeyedUnarchiver unarchiveObjectWithData:[USER_DEFAULTS objectForKey:@"loginRegion"]];
                        self->_selectedCtUser = [NSKeyedUnarchiver unarchiveObjectWithData:[USER_DEFAULTS objectForKey:@"loginCTUser"]];
                        
                        if (![[UTIL trim:self->_usernameTextField.text] isEqual: @""] && ![[UTIL trim:self->_passwordTextField.text] isEqual: @""] && self->_selectedRegion && self->_selectedCtUser) {
                            [UTIL showActivity:NSLocalizedStringFromTable(@"loging_in", [UTIL getLanguage], @"")];
                            [self performSelector:@selector(autologin) withObject:nil afterDelay:.1f];
                        }
                    });
                }
            }];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadRegions {
    _regions = [[NSMutableArray alloc] init];
    NSMutableArray *_cachedRegions = [[NSMutableArray alloc] init];
    [API getRegions:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSString *error = @"";
        if ([result valueForKey:@"error"]) {
            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
        }
        
        if ([error isEqualToString: @""]) {
            NSMutableArray *responseData = [result valueForKey:@"getRegionsResult"];
            
            GenericObject *item = [[GenericObject alloc] init];
            item.value = NSLocalizedStringFromTable(@"select_region", [UTIL getLanguage], @"");
            item.genericId = @"0";
            [self->_regions addObject:item];
            
            if ([responseData count] > 0) {
                for (id region in responseData) {
                    item = [[GenericObject alloc] init];
                    [item initWithData:region];
                    
                    NSRange range = [item.value rangeOfString:@"Test"];
                    if (range.location == NSNotFound) {
                        [self->_regions addObject:item];
                    }
                    
                    [_cachedRegions addObject:item];
                }
                [USER_DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:_cachedRegions] forKey:@"regions"];
            }
        } else {
            [ALERT alertWithTitle:@"Error" message:error];
        }
        
        [self->_regionsPickerView reloadAllComponents];
    }];
}

- (void)handleCancelTap:(id)sender {
    [_regionTextField resignFirstResponder];
}

- (void)handleDoneTap:(id)sender {
    _selectedRegion = _tempSelectedRegion;
    if (!_selectedRegion && _regions.count > 0) {
        _selectedRegion = [_regions objectAtIndex:0];
    }
    [_regionTextField resignFirstResponder];
    [_regionTextField setText:_selectedRegion.value];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([_usePinSwitch isOn] && range.location == 3 && textField.text.length == 3 && textField.tag == 0) {
        [_passwordTextField setText:[NSString stringWithFormat:@"%@%@", _passwordTextField.text, string]];
        [UTIL showActivity:NSLocalizedStringFromTable(@"loging_in", [UTIL getLanguage], @"")];
        [self performSelector:@selector(login) withObject:nil afterDelay:.1f];
        return [_passwordTextField resignFirstResponder];
    } else {
        return YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (!_moved && !(IS_IPAD())) {
        [self animateViewToPosition:self.view directionUP:YES];
        _moved = YES;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (!(IS_IPAD())) {
        [self animateViewToPosition:self.view directionUP:NO];
        _moved = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    long tag = [textField tag];
    if (tag == 1) {
        return [_passwordTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        
        [UTIL showActivity:NSLocalizedStringFromTable(@"loging_in", [UTIL getLanguage], @"")];
        [self performSelector:@selector(login) withObject:nil afterDelay:.1f];
        
        return YES;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    _activeTextField = textField;
    long tag = [textField tag];
    if (tag == 11) {
        if (_regions.count == 0) {
            [UTIL showActivity:NSLocalizedStringFromTable(@"loading_regions", [UTIL getLanguage], @"")];
            [self performSelector:@selector(loadRegions) withObject:nil afterDelay:.1f];
        } else {
            NSInteger selIndex = [self findRegionIndex:_selectedRegion];
            [_regionsPickerView selectRow:selIndex inComponent:0 animated:YES];
        }
    }
    return YES;
}

- (NSInteger)findRegionIndex:(GenericObject *)region {
    NSInteger index = 0;
    
    NSInteger ind = 0;
    for (GenericObject *item in _regions) {
        if ([item.genericId isEqual:region.genericId]) {
            index = ind;
        }
        ind++;
    }
    
    return index;
}

- (void)animateViewToPosition:(UIView *)viewToMove directionUP:(BOOL)up {
    int movementDistance = 0; // tweak as needed
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (screenRect.size.height <= 480) {
        movementDistance = -110;
    }
    const float movementDuration = 0.3f;
    
    int movement = (up ? movementDistance : -movementDistance);
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    viewToMove.frame = CGRectOffset(viewToMove.frame, 0, movement);
    [UIView commitAnimations];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _tempSelectedRegion = [_regions objectAtIndex:row];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_regions count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    GenericObject *go = (GenericObject *)[_regions objectAtIndex:row];
    return go.value;
}

#pragma mark - Login

- (IBAction)loginPressed:(id)sender {
    [_usernameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    
    [UTIL showActivity:NSLocalizedStringFromTable(@"loging_in", [UTIL getLanguage], @"")];
    [self performSelector:@selector(login) withObject:nil afterDelay:.1f];
}

- (void)login {
    NSString *username = @"";
    NSString *password = @"";
    
    if ([_usePinSwitch isOn]) {
        NSString *savedPin = [USER_DEFAULTS objectForKey:@"pin"];
        if ([savedPin isEqual: _passwordTextField.text]) {
            username = [USER_DEFAULTS objectForKey:@"loginUsername"];
            password = [USER_DEFAULTS objectForKey:@"loginPassword"];
            
            [USER login:username password:password region:[_selectedRegion.genericId intValue] location:LOCATION.lastSavedLocation completion:^(NSMutableArray *result) {
                [UTIL hideActivity];
                
                NSString *error = @"";
                if ([result valueForKey:@"error"]) {
                    error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
                }
                
                if (![error isEqualToString: @""]) {
                    [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:error];
                } else {
                    if ([USER.sessionId isEqual: [NSNull null]]) {
                        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"invalid_credentials", [UTIL getLanguage], @"")];
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            [self processLoginResult];
                        });
                    }
                }
            }];
        } else {
            [UTIL hideActivity];
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"invalid_pin", [UTIL getLanguage], @"")];
            [_passwordTextField becomeFirstResponder];
        }
    } else {
        if ([[UTIL trim:_usernameTextField.text] isEqual: @""]) {
            [UTIL hideActivity];
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"username_empty", [UTIL getLanguage], @"")];
        } else {
            if ([[UTIL trim:_passwordTextField.text] isEqual: @""]) {
                [UTIL hideActivity];
                [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"password_empty", [UTIL getLanguage], @"")];
            } else {
                if ([_selectedRegion.genericId isEqual: @"0"]) {
                    [UTIL hideActivity];
                    [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"select_region", [UTIL getLanguage], @"")];
                } else {
                    username = [UTIL trim:_usernameTextField.text];
                    password = [UTIL trim:_passwordTextField.text];
                    
                    [USER login:username password:password region:[_selectedRegion.genericId intValue] location:LOCATION.lastSavedLocation completion:^(NSMutableArray *result) {
                        [UTIL hideActivity];
                        
                        NSString *error = @"";
                        if ([result valueForKey:@"error"]) {
                            error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
                        }
                        
                        if (![error isEqualToString: @""]) {
                            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:error];
                        } else {
                            if ([USER.sessionId isEqual: [NSNull null]]) {
                                [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"invalid_credentials", [UTIL getLanguage], @"")];
                            } else {
                                dispatch_async(dispatch_get_main_queue(), ^ {
                                    [self processLoginResult];
                                });
                            }
                        }
                    }];
                }
            }
        }
    }
}

- (void)processLoginResult {
    if ([USER.appCredentials count] > 1) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"select_ct_user", [UTIL getLanguage], @"") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", [UTIL getLanguage], @"") style:UIAlertActionStyleCancel handler:nil];
        [actionCancel setValue:[UTIL darkRedColor] forKey:@"titleTextColor"];
        
        for (id ctUser in USER.appCredentials) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:[ctUser valueForKey:@"CTUserCode"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                self->_selectedCtUser = [[GenericObject alloc] init];
                self->_selectedCtUser.value = [ctUser valueForKey:@"CTUserCode"];
                self->_selectedCtUser.genericId = [ctUser valueForKey:@"CTUserId"];
                
                [self openApp];
            }];
            [actionSheet addAction:action];
            //[actionSheet addButtonWithTitle:[ctUser valueForKey:@"CTUserCode"]];
        }
        
        [actionSheet addAction:actionCancel];
        
        if (IS_IPAD()) {
            UIPopoverPresentationController *popoverPresentationController = [actionSheet popoverPresentationController];
            [popoverPresentationController setSourceRect:_loginButton.frame];
            [popoverPresentationController setSourceView:self.view];
            [actionSheet setModalPresentationStyle:UIModalPresentationPopover];
        }
        
        [self presentViewController:actionSheet animated:YES completion:nil];
    } else {
        if (USER.isProduction == 1) {
            [self openApp];
        } else {
            if ([USER.appCredentials count] == 1) {
                _selectedCtUser = [[GenericObject alloc] init];
                _selectedCtUser.value = [[USER.appCredentials objectAtIndex:0] valueForKey:@"CTUserCode"];
                _selectedCtUser.genericId = [[USER.appCredentials objectAtIndex:0] valueForKey:@"CTUserId"];
                
                //[self openApp];
            } else {
                //[ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"invalid_credentials", [UTIL getLanguage], @"")];
            }
            [self openApp];
        }
    }
}

- (void)openApp {
    USER.deviceToken = UTIL.deviceToken;
    USER.ctUser = (USER.isProduction) ? nil : _selectedCtUser;
    USER.region = _selectedRegion;
    
    if ([_usePinSwitch isOn]) {
        USER.password = [USER_DEFAULTS objectForKey:@"loginPassword"];
    } else {
        USER.password = _passwordTextField.text;
    }
    [USER registerForNotifications];
    
    [USER_DEFAULTS setObject:USER.loginUsername forKey:@"loginUsername"];
    [USER_DEFAULTS setObject:USER.password forKey:@"loginPassword"];
    [USER_DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:_selectedRegion] forKey:@"loginRegion"];
    [USER_DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:USER.ctUser] forKey:@"loginCTUser"];
    [USER_DEFAULTS synchronize];
    
    // todo: send login info to server
    
    [self performSegueWithIdentifier:@"showApplication" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (IBAction)usePinChanged:(id)sender {
    UISwitch *switcher = (UISwitch *)sender;
    if ([switcher isOn]) {
        [_passwordTextField setKeyboardType:UIKeyboardTypeNumberPad];
        [_passwordTextField setPlaceholder:@"4 Digit PIN"];
    } else {
        [_passwordTextField setKeyboardType:UIKeyboardTypeDefault];
        [_passwordTextField setPlaceholder:@"Password"];
    }
    [_passwordTextField setText:@""];
    
    if (_activeTextField == _passwordTextField) {
        [_passwordTextField resignFirstResponder];
        [_passwordTextField becomeFirstResponder];
    }
}

- (IBAction)useTouchPressed:(id)sender {
    [self touchID];
}

@end
