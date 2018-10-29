//
//  Util.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/6/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface Util : NSObject

@property MBProgressHUD *hud;
@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, retain) AVAudioPlayer *player;
@property (nonatomic, retain) NSNumber *loading;

@property float mileageRate1;
@property float mileageRate2;
@property float mileageRange;

+ (Util *)getInstance;

- (void)showActivity:(NSString *)message;
- (void)hideActivity;
- (void)showToaster:(UIView *)view withMessage:(NSString *)message;

- (NSString *)formatDate:(NSString *)fullDateString;
- (NSDate *)formatDateString:(NSString *)dateString format:(NSString *)format;
- (NSString *)formatDateOnly:(NSDate *)date format:(NSString *)format;
- (NSString *)formatPhone:(NSString *)phoneString;
- (void)playBeep;
- (void)playInvalidBeep;
- (NSString *)getLanguage;
- (void)setLanguage:(NSString *)language;

- (UILabel *)getBadge:(CGFloat)badgeValue type:(int)type;
- (UIColor *)blueColor;
- (UIColor *)pinkColor;
- (UIColor *)lightBlueColor;
- (UIColor *)darkBlueColor;
- (UIColor *)greenColor;
- (UIColor *)redColor;
- (UIColor *)lightRedColor;
- (UIColor *)darkRedColor;
- (UIColor *)lightGrayColor;

- (UIColor *)EventColor1;
- (UIColor *)EventLineColor1;
- (UIColor *)EventColor2;
- (UIColor *)EventLineColor2;

- (void)checkForUpdate;
- (UINavigationController *)getErrorNavigationController:(UIViewController *)rootViewController;

- (UILabel *)getPhotoLabel:(NSString *)text;
- (UIImage *)scaleImageToSize:(UIImage *)source newSize:(CGSize)newSize;

- (NSString *)encodeToBase64String:(UIImage *)image;
- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData;

- (void)saveImage:(UIImage *)image name:(NSString *)name;
- (UIImage *)loadImage:(NSString *)name;
- (void)processAppOptions:(NSDictionary *)options;

- (NSString *)trim:(NSString *)item;
- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
    
- (NSNumber *)getImageOrientationWithImage:(UIImage *)image;
- (UIImage *)cropImage:(UIImage*)image toRect:(CGRect)rect;

- (UIImage *)cropImageByFace:(CGImageRef)image toRect:(CGRect)rect;

@end
