//
//  Util.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/6/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "Util.h"

@interface Util ()
    
@end

@implementation Util

/**
 * Gets the instance of self object.
 *
 * @return instance object.
 */
+ (Util *)getInstance {
    SHARED_INSTANCE_USING_BLOCK(^{
        Util *util = [[Util alloc] init];
        util.hud = nil;
        
        return util;
    });
}

- (void)showActivity:(NSString *)message {
    _hud = [MBProgressHUD showHUDAddedTo:[APP_DELEGATE window] animated:YES];
    
    [_hud.backgroundView setStyle:MBProgressHUDBackgroundStyleSolidColor];
    [_hud.backgroundView setColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f]];
    
    [_hud.bezelView setStyle:MBProgressHUDBackgroundStyleSolidColor];
    [_hud.bezelView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8f]];
    
    [_hud setContentColor:[UIColor whiteColor]];
    
    if ([message isEqual:@""]) {
        _hud.label.text = NSLocalizedStringFromTable(@"please_wait", [UTIL getLanguage], @"");
    } else {
        _hud.detailsLabel.text = message;
    }
    
    [_hud showAnimated:YES];
    _loading = [NSNumber numberWithInt:1];
}

- (void)hideActivity {
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self->_hud hideAnimated:YES];
    });
    _loading = [NSNumber numberWithInt:0];
}

- (void)showToaster:(UIView *)view withMessage:(NSString *)message {
    MBProgressHUD *toaster = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:toaster];
    
    // Set custom view mode
    toaster.mode = MBProgressHUDModeCustomView;
    
    if (![message isEqual:@""]) {
        toaster.label.text = message;
    }
    
    toaster.removeFromSuperViewOnHide = YES;
    [toaster showAnimated:YES];
    [toaster hideAnimated:YES afterDelay:2];
}

- (NSString *)formatDate:(NSString *)fullDateString {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[NSLocale systemLocale]];
    [dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormat setFormatterBehavior:NSDateFormatterBehaviorDefault];
    [dateFormat setDateFormat:@"M/d/yyyy h:mm:ss a"];
    
    NSDate *date = [dateFormat dateFromString:fullDateString];
    [dateFormat setDateFormat:@"M/d/yyyy h:mm a"];
    
    return [dateFormat stringFromDate:date];
}

- (NSDate *)formatDateString:(NSString *)dateString format:(NSString *)format {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
    if ([format isEqual: @""]) {
        format = @"yyyy-MM-dd";
        if (dateString.length > 10) {
            format = @"yyyy-MM-dd HH:mm:ss";
        }
    }
    [dateFormat setDateFormat:format];
    
    return [dateFormat dateFromString:dateString];
}

- (NSString *)formatDateOnly:(NSDate *)date format:(NSString *)format {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    if ([format isEqual: @""]) {
        format = @"EEE, MMM d yyyy";
    }
    [dateFormat setDateFormat:format];
    
    return [dateFormat stringFromDate:date];
}

- (NSString *)formatPhone:(NSString *)phoneString {
    NSString *formatted = phoneString;
    
    if ([phoneString length] >= 10) {
        phoneString = [phoneString stringByReplacingOccurrencesOfString:@"-" withString:@""];
        phoneString = [phoneString stringByReplacingOccurrencesOfString:@" " withString:@""];
        phoneString = [phoneString stringByReplacingOccurrencesOfString:@"(" withString:@""];
        phoneString = [phoneString stringByReplacingOccurrencesOfString:@")" withString:@""];
        NSArray *stringComponents = [NSArray arrayWithObjects:[phoneString substringWithRange:NSMakeRange(0, 3)],
                                     [phoneString substringWithRange:NSMakeRange(3, 3)],
                                     [phoneString substringWithRange:NSMakeRange(6, [phoneString length]-6)], nil];
        
        formatted = [NSString stringWithFormat:@"(%@) %@-%@", [stringComponents objectAtIndex:0], [stringComponents objectAtIndex:1], [stringComponents objectAtIndex:2]];
    }
    return formatted;
}

- (void)playBeep {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"softScanBeep" ofType:@"wav"];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSURL alloc] initFileURLWithPath: path] error:nil];
    [_player setVolume:1.0f];
    [_player prepareToPlay];
    [_player play];
}

- (void)playInvalidBeep {
    AudioServicesPlayAlertSound(1053);
}

- (NSString *)getLanguage {
    return [USER_DEFAULTS objectForKey:@"language"]?[USER_DEFAULTS objectForKey:@"language"]:@"";
}

- (void)setLanguage:(NSString *)language {
    [USER_DEFAULTS setObject:language forKey:@"language"];
    [USER_DEFAULTS synchronize];
}

- (UILabel *)getBadge:(CGFloat)badgeValue type:(int)type {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 24)];
    if (type == 0) {
        [lbl setText:[NSString stringWithFormat:@"  %.1f  ", badgeValue]];
    } else {
        [lbl setText:[NSString stringWithFormat:@"  %d  ", (int)badgeValue]];
    }
    
    [lbl setBackgroundColor:[self blueColor]];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl sizeToFit];
    
    [lbl.layer setCornerRadius:10.0f];
    [lbl setClipsToBounds:YES];
    
    return lbl;
}

#pragma mark - Colors
- (UIColor *)blueColor {
    return [UIColor colorWithRed:(30/255.0) green:(114/255.0) blue:(220/255.0) alpha:1.0f];
}

- (UIColor *)pinkColor {
    return [UIColor colorWithRed:(255/255.0) green:(153/255.0) blue:(153/255.0) alpha:1.0f];
}

- (UIColor *)lightBlueColor {
    return [UIColor colorWithRed:(0/255.0) green:(191/255.0) blue:(233/255.0) alpha:1.0f];
}

- (UIColor *)darkBlueColor {
    return [UIColor colorWithRed:(0/255.0) green:(45/255.0) blue:(87/255.0) alpha:1.0f];
}

- (UIColor *)greenColor {
    return [UIColor colorWithRed:(76/255.0) green:(217/255.0) blue:(100/255.0) alpha:1.0f];
}

- (UIColor *)redColor {
    return [UIColor colorWithRed:(255/255.0) green:(102/255.0) blue:(102/255.0) alpha:1.0f];
}

- (UIColor *)lightRedColor {
    return [UIColor colorWithRed:(255/255.0) green:(153/255.0) blue:(153/255.0) alpha:1.0f];
}

- (UIColor *)darkRedColor {
    return [UIColor colorWithRed:(255/255.0) green:(51/255.0) blue:(51/255.0) alpha:1.0f];
}

- (UIColor *)lightGrayColor {
    return [UIColor colorWithRed:199.0f/255 green:199.0f/255 blue:205.0f/255 alpha:1.0f];
}

- (UIColor *)EventColor1 {
    return [UIColor colorWithRed:254.0f/255 green:234.0f/255 blue:205.0f/255 alpha:1.0f];
}

- (UIColor *)EventLineColor1 {
    return [UIColor colorWithRed:237.0f/255 green:150.0f/255 blue:51.0f/255 alpha:1.0f];
}

- (UIColor *)EventColor2 {
    return [UIColor colorWithRed:171.0f/255 green:235.0f/255 blue:198.0f/255 alpha:1.0f];
}

- (UIColor *)EventLineColor2 {
    return [UIColor colorWithRed:35.0f/255 green:155.0f/255 blue:86.0f/255 alpha:1.0f];
}

- (void)checkForUpdate {
    if ([self newVersionIsAvailable]) {
        [ALERT promptWithTitle:NSLocalizedStringFromTable(@"information", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"update_version_notification", [UTIL getLanguage], @"") completion:^(BOOL granted) {
            if (granted) {
                NSURL *url = [NSURL URLWithString:UPDATE_TEST_URL];
                if (![APP_MODE isEqual: @"0"]) {
                    url = [NSURL URLWithString:UPDATE_URL];
                }
                [[UIApplication sharedApplication] openURL:url];
                
                exit(0);
            }
        }];
    }
}

- (bool)newVersionIsAvailable {
    bool updateAvailable = false;
    
    NSDictionary *updateDictionary;
    if (![APP_MODE isEqual: @"0"]) {
        updateDictionary = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:UPDATE_CHECK_URL]];
    } else {
        updateDictionary = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:UPDATE_CHECK_TEST_URL]];
    }
    
    if (updateDictionary) {
        NSArray *items = [updateDictionary objectForKey:@"items"];
        NSDictionary *itemDict = [items lastObject];
        
        NSDictionary *metaData = [itemDict objectForKey:@"metadata"];
        NSString *newversion = [metaData valueForKey:@"bundle-version"];
        NSString *currentversion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        
        updateAvailable = [newversion compare:currentversion options:NSNumericSearch] == NSOrderedDescending;
    }
    
    return updateAvailable;
}

- (UINavigationController *)getErrorNavigationController:(UIViewController *)rootViewController {
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [navController setModalPresentationStyle:UIModalPresentationCurrentContext];
    [navController.navigationBar setBarTintColor:[UIColor colorWithRed:0/255.0f green:45/255.0f blue:87/255.0f alpha:1.0f]];
    [navController.navigationBar setTintColor:[UIColor whiteColor]];
    [navController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [navController.navigationBar setTranslucent:NO];
    
    return navController;
}

- (UILabel *)getPhotoLabel:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    [label setAttributedText:[[NSAttributedString alloc] initWithString:text attributes: @{ NSFontAttributeName: [UIFont boldSystemFontOfSize: [UIFont systemFontSize]]}]];
    [label setTextColor:[UIColor whiteColor]];
    [label.layer setBackgroundColor:[[UTIL blueColor] CGColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [label.layer setBorderWidth:1.0f];
    [label.layer setCornerRadius:16.0f];
    
    return label;
}

- (UIImage *)scaleImageToSize:(UIImage *)source newSize:(CGSize)newSize {
    @autoreleasepool {
        CGRect scaledImageRect = CGRectZero;
        
        CGFloat aspectWidth = newSize.width / source.size.width;
        CGFloat aspectHeight = newSize.height / source.size.height;
        CGFloat aspectRatio = MIN ( aspectWidth, aspectHeight );
        
        scaledImageRect.size.width = source.size.width * aspectRatio;
        scaledImageRect.size.height = source.size.height * aspectRatio;
        scaledImageRect.origin.x = 0;//(newSize.width - scaledImageRect.size.width) / 2.0f;
        scaledImageRect.origin.y = 0;//(newSize.height - scaledImageRect.size.height) / 2.0f;
        
        UIGraphicsBeginImageContextWithOptions(scaledImageRect.size, NO, 0);
        [[UIColor whiteColor] set];
        UIRectFill(CGRectMake(0.0, 0.0, scaledImageRect.size.width, scaledImageRect.size.height));
        [source drawInRect:scaledImageRect];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return scaledImage;
    }
}

- (NSString *)encodeToBase64String:(UIImage *)image {
    NSString *response = [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    response = [response stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    return response;
}

- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

- (void)saveImage:(UIImage *)image name:(NSString *)name {
    if (image != nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", name]];
        NSData *data = UIImagePNGRepresentation(image);
        [data writeToFile:path atomically:YES];
    }
}

- (UIImage *)loadImage:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", name]];
    return [UIImage imageWithContentsOfFile:path];
}

- (void)processAppOptions:(NSDictionary *)options {
    if (![USER.sessionId isEqual:@""]) {
        APP_DELEGATE.receivedPushNotification = nil;
        
        NSInteger acme1 = [[options objectForKey:@"acme1"] integerValue];
        NSString *acme2String = [options objectForKey:@"acme2"];
        
        // fix json
        acme2String = [acme2String stringByReplacingOccurrencesOfString:@"region" withString:@"\"region\""];
        acme2String = [acme2String stringByReplacingOccurrencesOfString:@"claim" withString:@"\"claim\""];
        acme2String = [acme2String stringByReplacingOccurrencesOfString:@"note" withString:@"\"note\""];
        
        NSData *data = [acme2String dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *acme2 = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        switch (acme1) {
            case 1: // note_share
            {
                int regionId = 0;
                int claimId = 0;
                int noteId = 0;
                
                if ([acme2 objectForKey:@"region"] && [acme2 objectForKey:@"region"] != [NSNull null]) {
                    regionId = [[acme2 objectForKey:@"region"] intValue];
                }
                if ([acme2 objectForKey:@"claim"] && [acme2 objectForKey:@"claim"] != [NSNull null]) {
                    claimId = [[acme2 objectForKey:@"claim"] intValue];
                }
                if ([acme2 objectForKey:@"note"] && [acme2 objectForKey:@"note"] != [NSNull null]) {
                    noteId = [[acme2 objectForKey:@"note"] intValue];
                }
                
                if (regionId > 0 && claimId > 0 && noteId > 0) {
                    // open note screen
                    Note *note = [[Note alloc] init];
                    note.regionId = regionId;
                    note.noteId = noteId;
                    note.claim.claimIndx = claimId;
                    
                    // loading_note
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:note forKey:@"data"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedNoteShare" object:nil userInfo:userInfo];
                } else {
                    [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"note_could_not_be_loaded", [UTIL getLanguage], @"")];
                }
            }
                break;
            default:
                break;
        }
    }
}

- (NSString *)trim:(NSString *)item {
    NSString *trimmed = @"";
    if (![item isKindOfClass:[NSNull class]]) {
        @try {
            trimmed = [item stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        } @catch(NSException *e) {}
    }
    
    return trimmed;
}

- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (NSNumber *)getImageOrientationWithImage:(UIImage *)image {
    NSUInteger exifOrientation;
    switch (image.imageOrientation) {
        case UIImageOrientationUp:
        exifOrientation = 1;
        break;
        case UIImageOrientationDown:
        exifOrientation = 3;
        break;
        case UIImageOrientationLeft:
        exifOrientation = 8;
        break;
        case UIImageOrientationRight:
        exifOrientation = 6;
        break;
        case UIImageOrientationUpMirrored:
        exifOrientation = 2;
        break;
        case UIImageOrientationDownMirrored:
        exifOrientation = 4;
        break;
        case UIImageOrientationLeftMirrored:
        exifOrientation = 5;
        break;
        case UIImageOrientationRightMirrored:
        exifOrientation = 7;
        break;
        default:
        break;
    }
    
    return @(exifOrientation);
}

- (UIImage *)cropImage:(UIImage*)image toRect:(CGRect)rect {
    CGFloat (^rad)(CGFloat) = ^CGFloat(CGFloat deg) {
        return deg / 180.0f * (CGFloat) M_PI;
    };
    
    // determine the orientation of the image and apply a transformation to the crop rectangle to shift it to the correct position
    CGAffineTransform rectTransform;
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -image.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -image.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -image.size.width, -image.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    
    // adjust the transformation scale based on the image scale
    rectTransform = CGAffineTransformScale(rectTransform, image.scale, image.scale);
    
    // apply the transformation to the rect to create a new, shifted rect
    CGRect transformedCropSquare = CGRectApplyAffineTransform(rect, rectTransform);
    // use the rect to crop the image
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, transformedCropSquare);
    // create a new UIImage and set the scale and orientation appropriately
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    // memory cleanup
    CGImageRelease(imageRef);
    
    return result;
}

- (UIImage *)cropImageByFace:(CGImageRef)image toRect:(CGRect)rect {
    CGFloat delta = 220.0f;
    CGFloat frameX = (rect.origin.x + (delta*1.2f));// > 0 ? rect.origin.x - (delta*1.2f) : 0;
    CGFloat frameY = (rect.origin.y + (delta*1.2f));// > 0 ? rect.origin.y - (delta*1.2f) : 0;
    CGFloat side = MAX(rect.size.width - delta*2.4, rect.size.height - delta*2.4);
    CGRect rectToCrop = CGRectMake(frameX, frameY, side, side);
    CGImageRef imref = CGImageCreateWithImageInRect(image, rectToCrop);
    
    UIImage *response = [UIImage imageWithCGImage:imref];
    CGImageRelease(imref);
    
    return response;
}

@end
