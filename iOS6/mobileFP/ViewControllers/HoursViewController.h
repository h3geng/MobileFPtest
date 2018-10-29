//
//  HoursViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 1/8/15.
//  Copyright (c) 2015 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HoursViewController : UIViewController

- (IBAction)donePressed:(id)sender;

@property NSDate *begin;
@property NSDate *end;

@end
