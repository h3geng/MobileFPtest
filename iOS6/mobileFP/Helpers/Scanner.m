 //
//  Scanner.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/9/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "Scanner.h"
#import "InventoryViewController.h"
#import "LoginViewController.h"

#import "HomeViewController.h"
#import "EquipmentViewController.h"
#import "EquipmentDetailsViewController.h"
#import "ClaimEquipmentViewController.h"
#import "TransactionsViewController.h"
#import "BatchItemsViewController.h"
#import "InventoryViewController.h"
#import "CameraViewController.h"

@implementation Scanner

/**
 * Gets the instance of self object.
 *
 * @return instance object.
 */
+ (Scanner *)getInstance {
    SHARED_INSTANCE_USING_BLOCK(^{
        Scanner *scanner = [[Scanner alloc] init];
        scanner.identity = RANDOM_INT(100000, 999999);
        return scanner;
    });
}

- (void)initialize {
}

- (void)onErrorRetrievingScanObject:(SKTRESULT) result {
    NSLog(@"Error retrieving ScanObject:%ld", result);
}

- (void)onError:(SKTRESULT) result {
    NSLog(@"ScanAPI is reporting an error: %ld", result);
}

-(void)onDeviceArrival:(SKTRESULT)result device:(DeviceInfo*)deviceInfo {
    NSString *deviceName = [deviceInfo getName];
    _isConnected = true;
    
    // notification on top
    if (_overlayView == nil && ![[APP_DELEGATE getCurrentScreen] isKindOfClass:[LoginViewController class]]) {
        _overlayView = [[UIView alloc] initWithFrame: CGRectMake(0,-[UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 34)];
        [_overlayView setBackgroundColor:[UTIL greenColor]];
        [_overlayView setAutoresizesSubviews:YES];
        [_overlayView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, [UIScreen mainScreen].bounds.size.width, 38)];
        [_label setFont:[UIFont systemFontOfSize:12]];
        [_label setTextColor:[UIColor whiteColor]];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [_label setBackgroundColor:[UIColor clearColor]];
        if ([[APP_DELEGATE getCurrentScreen] isKindOfClass:[LoginViewController class]]) {
            [_label setTextColor:[UIColor whiteColor]];
        }
        [_label setText:NSLocalizedStringFromTable(@"external_scanner_connected", [UTIL getLanguage], @"")];
        
        [_overlayView addSubview:_label];
        [_label setAlpha:0];
        
        AudioServicesPlayAlertSound(1106);
        
        [UIView animateWithDuration:1 animations:^{self->_overlayView.center = CGPointMake(self->_overlayView.center.x, roundf(self->_overlayView.bounds.size.height/2.));[self->_label setAlpha:1.0];}];
        
        [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:_overlayView];
        
        _notifTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onNotifTimer:) userInfo:nil repeats:YES];
        _notifTimerEnd = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(onNotifTimerEnd:) userInfo:nil repeats:NO];
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:deviceName forKey:@"data"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"externalScannerConected" object:nil userInfo:userInfo];
}

- (void)onNotifTimer:(NSTimer*)theTimer {
    [UIView beginAnimations:@"fade out" context:nil];
    [UIView setAnimationDuration:1.0];
    
    if ([[APP_DELEGATE getCurrentScreen] isKindOfClass:[LoginViewController class]]) {
        [_label setTextColor:[UIColor clearColor]];
    } else {
        [_label setTextColor:[UIColor whiteColor]];
    }
    
    if ([_label alpha] == 1.0) {
        [_label setAlpha:.1];
    } else {
        [_label setAlpha:1.0];
    }
    
    [UIView commitAnimations];
}

- (void)onNotifTimerEnd:(NSTimer*)theTimer {
    [self hideNotificationHeader];
}

- (void)hideNotificationHeader {
    [UIView animateWithDuration:.5 animations:^{ [self->_overlayView setAlpha:0]; } completion: ^(BOOL finished) {
        [self->_overlayView removeFromSuperview];
        
        self->_overlayView = nil;
        
        [self->_notifTimer invalidate];
        self->_notifTimer = nil;
        
        [self->_notifTimerEnd invalidate];
        self->_notifTimerEnd = nil;
    }];
}

- (void)onDeviceRemoval:(DeviceInfo*) deviceRemoved {
    NSString *deviceName = [deviceRemoved getName];
    _isConnected = false;
    
    // notification on top
    if (_overlayView == nil && ![[APP_DELEGATE getCurrentScreen] isKindOfClass:[LoginViewController class]]) {
        _overlayView = [[UIView alloc] initWithFrame: CGRectMake(0,-[UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 34)];
        [_overlayView setBackgroundColor:[UTIL redColor]];
        [_overlayView setAutoresizesSubviews:YES];
        [_overlayView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, [UIScreen mainScreen].bounds.size.width, 38)];
        [_label setFont:[UIFont systemFontOfSize:12]];
        [_label setTextColor:[UIColor whiteColor]];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [_label setBackgroundColor:[UIColor clearColor]];
        if ([[APP_DELEGATE getCurrentScreen] isKindOfClass:[LoginViewController class]]) {
            [_label setTextColor:[UIColor whiteColor]];
        }
        [_label setText:NSLocalizedStringFromTable(@"no_external_scanner", [UTIL getLanguage], @"")];
        
        [_overlayView addSubview:_label];
        [_label setAlpha:0];
        
        AudioServicesPlayAlertSound(1106);
        
        [UIView animateWithDuration:1 animations:^{self->_overlayView.center = CGPointMake(self->_overlayView.center.x, roundf(self->_overlayView.bounds.size.height/2.));[self->_label setAlpha:1.0];}];
        
        [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:_overlayView];
        
        _notifTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onNotifTimer:) userInfo:nil repeats:YES];
        _notifTimerEnd = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(onNotifTimerEnd:) userInfo:nil repeats:NO];
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:deviceName forKey:@"data"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"externalScannerDisconnected" object:nil userInfo:userInfo];
}

-(void) onDecodedData:(DeviceInfo*) device decodedData:(ISktScanDecodedData*) decodedData {
    if ([self allowScan] && [UTIL.loading isEqual:[NSNumber numberWithInt:0]]) {
        NSString *receivedData = [NSString stringWithUTF8String:(const char *)[decodedData getData]];
        
        NSMutableArray* stringComponents = (NSMutableArray *)[receivedData componentsSeparatedByString: @"ID="];
        if (stringComponents.count > 1) {
            receivedData = [stringComponents objectAtIndex:(stringComponents.count - 1)];
        }
        
        [UTIL showActivity:NSLocalizedStringFromTable(@"searching", [UTIL getLanguage], @"")];
        [self performSelector:@selector(executeSearch:) withObject:receivedData afterDelay:0.1f];
    }
}

// search everything
- (void)search:(NSString *)term {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    [API findItem:USER.sessionId regionId:USER.regionId branchName:@"" searchString:term completion:^(NSMutableArray *result) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            [UTIL hideActivity];
            
            NSString *error = @"";
            if ([result valueForKey:@"error"]) {
                error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
            }
            
            if ([error isEqualToString: @""]) {
                NSMutableArray *responseData = [result valueForKey:@"findItemResult"];
                if (![responseData isKindOfClass:[NSNull class]]) {
                    if ([responseData count] > 0) {
                        for (id item in responseData) {
                            Inventory *inventory = [[Inventory alloc] init];
                            [inventory initWithData:item];
                            
                            [items addObject:inventory];
                        }
                    } else {
                        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"nothing_found", [UTIL getLanguage], @"")];
                    }
                } else {
                    [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"nothing_found", [UTIL getLanguage], @"")];
                }
            } else {
                [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:error];
            }
            
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:items forKey:@"data"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"externalScannerItemsResponse" object:nil userInfo:userInfo];
        });
    }];
}

- (void)searchExact:(NSString *)term {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    [API findItemExact:USER.sessionId regionId:USER.regionId branchName:@"" searchString:term completion:^(NSMutableArray *result) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            [UTIL hideActivity];
            
            NSString *error = @"";
            if ([result valueForKey:@"error"]) {
                error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
            }
            
            if ([error isEqualToString: @""]) {
                NSMutableArray *responseData = [result valueForKey:@"findItemExactResult"];
                if (![responseData isKindOfClass:[NSNull class]]) {
                    if ([responseData count] > 0) {
                        for (id item in responseData) {
                            Inventory *inventory = [[Inventory alloc] init];
                            [inventory initWithData:item];
                            
                            [items addObject:inventory];
                        }
                    } else {
                        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"nothing_found", [UTIL getLanguage], @"")];
                    }
                } else {
                    [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"nothing_found", [UTIL getLanguage], @"")];
                }
            } else {
                [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:error];
            }
            
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:items forKey:@"data"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"externalScannerItemsResponse" object:nil userInfo:userInfo];
        });
    }];
}

- (void)executeSearch:(NSString *)term {
    NSMutableArray* stringComponents = (NSMutableArray *)[term componentsSeparatedByString: @"ID="];
    if (stringComponents.count > 1) {
        term = [stringComponents objectAtIndex:(stringComponents.count - 1)];
    }
    
    [API scanItem:USER.sessionId location:LOCATION.lastSavedLocation searchString:term completion:^(NSMutableArray *result) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            [UTIL hideActivity];
            
            NSString *error = @"";
            if ([result valueForKey:@"error"]) {
                error = [NSString stringWithFormat:@"%@", [result valueForKey:@"error"]];
            }
            
            bool found = false;
            
            if ([error isEqualToString: @""]) {
                NSMutableArray *responseData = [result valueForKey:@"scanItemResult"];
                
                // if valid result received
                if (responseData) {
                    if (![responseData isKindOfClass:[NSNull class]]) {
                        if ([responseData count] > 0) {
                            int tempId = 0;
                            
                            if ([responseData valueForKey:@"Id"] != [NSNull null]) {
                                tempId = [[responseData valueForKey:@"Id"] intValue];
                            }
                            
                            if (tempId > 0) {
                                found = true;
                                [UTIL playBeep];
                                
                                Inventory *inventory = [[Inventory alloc] init];
                                [inventory initWithData:responseData];
                                
                                if ([inventory.assetTag isEqual:@""]) {
                                    inventory.assetTag = term;
                                }
                                
                                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:inventory forKey:@"data"];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"externalScannerResponse" object:nil userInfo:userInfo];
                            }
                        }
                    }
                }
            } else {
                [ALERT alertWithTitle:NSLocalizedStringFromTable(@"error", [UTIL getLanguage], @"") message:error];
            }
            
            if (!found) {
                // check current screen type
                UIViewController *destController = [APP_DELEGATE getCurrentScreen];
                if ([destController isKindOfClass:[CameraViewController class]]) {
                    destController = [APP_DELEGATE getPreviousScreen];
                }
                
                if ([destController isKindOfClass:[InventoryViewController class]]) {
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:term forKey:@"data"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"externalScannerResponse" object:nil userInfo:userInfo];
                } else {
                    if ([destController isKindOfClass:[EquipmentDetailsViewController class]]) {
                        EquipmentDetailsViewController *equipmentDetailsViewController = (EquipmentDetailsViewController *)destController;
                        if (!equipmentDetailsViewController.receiveModeInventory) {
                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:term forKey:@"data"];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"externalScannerResponse" object:nil userInfo:userInfo];
                        } else {
                            [UTIL playInvalidBeep];
                            [self sendNotFound:term];
                        }
                    } else {
                        [UTIL playInvalidBeep];
                        [self sendNotFound:term];
                    }
                }
            }
        });
    }];
}

- (bool)allowScan {
    bool response = true;
    
    if ([USER.userId isEqual: @""]) {
        response = false;
    } else {
        UIViewController *current = [APP_DELEGATE getCurrentScreen];
        if ([current isKindOfClass:[EquipmentViewController class]] || [current isKindOfClass:[EquipmentDetailsViewController class]] || [current isKindOfClass:[ClaimEquipmentViewController class]] || [current isKindOfClass:[TransactionsViewController class]] || [current isKindOfClass:[BatchItemsViewController class]] || [current isKindOfClass:[InventoryViewController class]] || [current isKindOfClass:[HomeViewController class]]) {
            response = true;
        } else {
            response = false;
        }
    }
    
    return response;
}

- (void)sendNotFound:(NSString *)term {
    if (!USER.isProduction) {
        [ALERT promptWithTitle:NSLocalizedStringFromTable(@"nothing_found", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"do_you_want_to_add_a_new_item", [UTIL getLanguage], @"") completion:^(BOOL granted) {
            if (granted) {
                InventoryViewController *inventoryViewController = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"InventoryViewController"];
                
                [inventoryViewController setInventory:[[Inventory alloc] init]];
                [inventoryViewController.inventory setAssetTag:term];
                
                UIViewController *current = [APP_DELEGATE getCurrentScreen];
                [current.navigationController pushViewController:inventoryViewController animated:YES];
            }
        }];
    } else {
        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"nothing_found", [UTIL getLanguage], @"")];
    }
}

- (void)onScanApiTerminated {
    
}

- (void)onScanApiInitializeComplete:(SKTRESULT) result {
    if (!SKTSUCCESS(result)) {
        NSLog(@"Error initializing ScanAPI:%ld", result);
    }
}

@end
