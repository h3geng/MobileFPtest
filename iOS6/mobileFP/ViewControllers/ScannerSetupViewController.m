//
//  ScannerSetupViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 4/15/15.
//  Copyright (c) 2015 FirstOnSite. All rights reserved.
//

#import "ScannerSetupViewController.h"

@interface ScannerSetupViewController ()

@end

@implementation ScannerSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedStringFromTable(@"scanner", [UTIL getLanguage], @""), NSLocalizedStringFromTable(@"setup", [UTIL getLanguage], @"")]];
    
    UILabel *lbl = (UILabel *)[self.view viewWithTag:10];
    [lbl setNumberOfLines:0];
    
    lbl = (UILabel *)[self.view viewWithTag:11];
    [lbl setNumberOfLines:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.tabBarController.tabBar setHidden:NO];
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
