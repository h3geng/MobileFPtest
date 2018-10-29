//
//  HoursViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 1/8/15.
//  Copyright (c) 2015 FirstOnSite. All rights reserved.
//

#import "HoursViewController.h"
#import "TimesheetViewController.h"

@interface HoursViewController ()

@end

@implementation HoursViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self localize];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self localize];
    
    // set default dates
    UIDatePicker *start = (UIDatePicker *)[self.view viewWithTag:20];
    UIDatePicker *finish = (UIDatePicker *)[self.view viewWithTag:40];
    
    [start setDatePickerMode:UIDatePickerModeTime];
    [finish setDatePickerMode:UIDatePickerModeTime];
    
    [start setDate:_begin];
    [finish setDate:_end];
}

- (void)localize {
    [self setTitle:NSLocalizedStringFromTable(@"working_hours", [UTIL getLanguage], @"")];
    
    UILabel *lbl = (UILabel *)[self.view viewWithTag:10];
    [lbl setText:NSLocalizedStringFromTable(@"started", [UTIL getLanguage], @"")];
    
    lbl = (UILabel *)[self.view viewWithTag:30];
    [lbl setText:NSLocalizedStringFromTable(@"finished", [UTIL getLanguage], @"")];
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

- (IBAction)donePressed:(id)sender {
    UIDatePicker *start = (UIDatePicker *)[self.view viewWithTag:20];
    UIDatePicker *finish = (UIDatePicker *)[self.view viewWithTag:40];
    
    float hours = 0;
    if ([start.date compare:finish.date] == NSOrderedAscending) {
        hours = [finish.date timeIntervalSinceDate:start.date]/60/60;
    }
    
    TimesheetViewController *parent = (TimesheetViewController *)[APP_DELEGATE getPreviousScreen];
    [parent setHours:hours];
    [parent setDateStart:start.date];
    [parent setDateEnd:finish.date];
    
    [parent refreshTable];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
