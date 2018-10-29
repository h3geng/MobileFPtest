//
//  ApplicationViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 9/27/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "ApplicationViewController.h"

@interface ApplicationViewController ()

@end

@implementation ApplicationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [self.navigationItem setHidesBackButton:YES];
    
    UITabBarController *tabBarController = (UITabBarController*)self.navigationController.topViewController;
    [tabBarController setDelegate:self];
    
    NSArray *items = tabBarController.viewControllers;
    NSMutableArray *modifyableArray;
    // check if CT user
    if (!USER.isCT) {
        modifyableArray = [[NSMutableArray alloc] initWithObjects:[items objectAtIndex:0], [items lastObject], nil];
    } else {
        modifyableArray = [[NSMutableArray alloc] initWithArray:items];
    }
    // hide timesheets for production
    if (![APP_MODE isEqual: @"0"]) {
        [modifyableArray removeLastObject];
    }
    items = [[NSArray alloc] initWithArray:modifyableArray];
    [tabBarController setViewControllers:items];
    
    [[UITabBar appearance] setTintColor:UTIL.darkBlueColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *selectedNavigationController = (UINavigationController *)viewController;
        [selectedNavigationController popToRootViewControllerAnimated:NO];
    }
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
