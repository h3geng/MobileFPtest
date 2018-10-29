//
//  UIAlertView+FOSAlertView.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 7/30/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <objc/runtime.h>
#import "UIAlertView+FOSAlertView.h"

@implementation UIAlertController (NTAlertController)

+ (instancetype)show:(NSString *)title
             message:(NSString *)message
   cancelButtonTitle:(NSString *)cancelButtonTitle
   otherButtonTitles:(NSString *)otherButtonTitle
            tapBlock:(UIAlertCompletionBlock)tapBlock {
    
    UIAlertController *alertController = [self alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (cancelButtonTitle != nil) {
        UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            tapBlock(alertController, 0); // Cancel button callback
        }];
        
        [alertController addAction:cancelButton];
    }
    
    if (otherButtonTitle != nil) {
        UIAlertAction *otherButton = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            tapBlock(alertController, 1); // Other button callback
        }];
        
        [alertController addAction:otherButton];
    }
    
    [[APP_DELEGATE window].rootViewController presentViewController:alertController animated:YES completion:nil];
    
    return alertController;
}

@end
