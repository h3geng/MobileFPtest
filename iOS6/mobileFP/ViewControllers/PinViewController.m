//
//  PinViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 3/27/15.
//  Copyright (c) 2015 FirstOnSite. All rights reserved.
//

#import "PinViewController.h"

@interface PinViewController ()

@end

@implementation PinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:NSLocalizedStringFromTable(@"pin", [UTIL getLanguage], @"")];
    
    [_pin1 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_pin2 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_pin3 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_pin4 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_pin1 becomeFirstResponder];
    
    [_pin1 setTintColor:[UIColor clearColor]];
    [_pin2 setTintColor:[UIColor clearColor]];
    [_pin3 setTintColor:[UIColor clearColor]];
    [_pin4 setTintColor:[UIColor clearColor]];
    
    [_pin1.layer setBorderColor:UTIL.darkBlueColor.CGColor];
    [_pin1.layer setBorderWidth:1.0f];
    [_pin2.layer setBorderColor:UTIL.darkBlueColor.CGColor];
    [_pin2.layer setBorderWidth:1.0f];
    [_pin3.layer setBorderColor:UTIL.darkBlueColor.CGColor];
    [_pin3.layer setBorderWidth:1.0f];
    [_pin4.layer setBorderColor:UTIL.darkBlueColor.CGColor];
    [_pin4.layer setBorderWidth:1.0f];
    
    _first = @"";
    _second = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField setText:@""];
    if (textField != _pin1 && [_pin1.text isEqual: @""]) {
        [_pin1 becomeFirstResponder];
    }
}

- (void)textFieldDidChange:(UITextField *)sender {
    long tag = [sender tag];
    switch (tag) {
        case 1:
            [_pin2 becomeFirstResponder];
            break;
        case 2:
            [_pin3 becomeFirstResponder];
            break;
        case 3:
            [_pin4 becomeFirstResponder];
            break;
        case 4:
            [self lastPin];
            break;
    }
}

- (void)lastPin {
    if ([_first isEqual: @""]) {
        _first = [NSString stringWithFormat:@"%@%@%@%@", _pin1.text, _pin2.text, _pin3.text, _pin4.text];
        [_textLabel setText:@"Re-enter PIN Digits"];
        
        [_pin1 setText:@""];
        [_pin2 setText:@""];
        [_pin3 setText:@""];
        [_pin4 setText:@""];
        [_pin1 becomeFirstResponder];
    } else {
        _second = [NSString stringWithFormat:@"%@%@%@%@", _pin1.text, _pin2.text, _pin3.text, _pin4.text];
        
        if ([_first isEqual: _second]) {
            // save pin and back
            [USER_DEFAULTS setObject:_second forKey:@"pin"];
            [USER_DEFAULTS synchronize];
            
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:@"PIN Digits do not match."];
            [_textLabel setText:@"Enter PIN Digits"];
            
            [_pin1 setText:@""];
            [_pin2 setText:@""];
            [_pin3 setText:@""];
            [_pin4 setText:@""];
            _first = @"";
            _second = @"";
            [_pin1 becomeFirstResponder];
        }
    }
}

@end
