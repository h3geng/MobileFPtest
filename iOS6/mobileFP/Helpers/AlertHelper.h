//
//  AlertHelper.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 7/30/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertHelper : NSObject

+ (AlertHelper *)getInstance;

- (void)alertWithTitle:(NSString *)title message:(NSString *)message;
- (void)promptWithTitle:(NSString *)title message:(NSString *)message completion:(void(^)(BOOL granted))action;
- (void)alertWithHandler:(NSString *)title message:(NSString *)message completion:(void(^)(BOOL granted))action;

@end
