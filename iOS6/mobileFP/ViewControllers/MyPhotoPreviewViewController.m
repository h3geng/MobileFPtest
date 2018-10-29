//
//  MyPhotoPreviewViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-10-10.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import "MyPhotoPreviewViewController.h"

@interface MyPhotoPreviewViewController ()

@end

@implementation MyPhotoPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:NSLocalizedStringFromTable(@"preview", [UTIL getLanguage], @"")];
    
    [_photoContainer setImage:_photo];
    [_photoContainer setContentMode:UIViewContentModeScaleAspectFit];
    [_lblName setText:_usr.userDetail.fullname];
    [_lblDepartment setText:_usr.userDetail.department];
    [_lblBranch setText:_usr.userDetail.branch];
    [_lblId setText:[NSString stringWithFormat:@"ID: %@", _usr.userDetail.payroll]];
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

- (IBAction)retakePressed:(id)sender {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"0" forKey:@"data"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"photoPreviewResponse" object:nil userInfo:userInfo];
    
    [self.navigationController popViewControllerAnimated:YES];
}
    
- (IBAction)donePressed:(id)sender {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"1" forKey:@"data"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"photoPreviewResponse" object:nil userInfo:userInfo];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
