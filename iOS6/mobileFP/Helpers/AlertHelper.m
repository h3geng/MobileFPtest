//
//  AlertHelper.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 7/30/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "AlertHelper.h"
#import "UIAlertView+FOSAlertView.h"

@implementation AlertHelper

+ (AlertHelper *)getInstance {
    SHARED_INSTANCE_USING_BLOCK(^{
        return [[AlertHelper alloc] init];
    });
}

- (void)alertWithTitle:(NSString *)title message:(NSString *)message {
    [UIAlertController show:title message:[NSString stringWithFormat:@"\n%@", message] cancelButtonTitle:NSLocalizedStringFromTable(@"ok", [UTIL getLanguage], @"") otherButtonTitles:nil tapBlock:^(UIAlertController *alertController, NSInteger index) {
        [alertController dismissViewControllerAnimated:YES completion:^{
        }];
    }];
}

- (void)promptWithTitle:(NSString *)title message:(NSString *)message completion:(void(^)(BOOL granted))action {
    [UIAlertController show:title message:[NSString stringWithFormat:@"\n%@", message] cancelButtonTitle:NSLocalizedStringFromTable(@"no", [UTIL getLanguage], @"") otherButtonTitles:NSLocalizedStringFromTable(@"yes", [UTIL getLanguage], @"") tapBlock:^(UIAlertController *alertController, NSInteger index){
        if (index == 0){
            action(false);
        } else {
            if (index == 1){
                action(true);
            }
        }
        
        [alertController dismissViewControllerAnimated:YES completion:^{
        }];
    }];
}

- (void)alertWithHandler:(NSString *)title message:(NSString *)message completion:(void(^)(BOOL granted))action {
    [UIAlertController show:title message:[NSString stringWithFormat:@"\n%@", message] cancelButtonTitle:NSLocalizedStringFromTable(@"ok", [UTIL getLanguage], @"") otherButtonTitles:nil tapBlock:^(UIAlertController *alertController, NSInteger index){
        if (index == 0){
            action(true);
        }
        
        [alertController dismissViewControllerAnimated:YES completion:^{
        }];
    }];
}

@end
