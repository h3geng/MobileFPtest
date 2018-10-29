//
//  Definitions.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 7/30/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#ifndef ___Definitions_h
#define ___Definitions_h

// include definitions
#import "AlertHelper.h"
#import "Singleton.h"
#import "GenericObject.h"
#import "Inventory.h"
#import "Claim.h"
#import "MBProgressHUD.h"

//#define DEVICE [UIDevice currentDevice]
#define IS_IPAD() UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#define IS_PORTRAIT() UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)

#define RECEIPT_URL @"http://devservices.firstonsite.ca/mobileservices/ReceiptHandler.ashx"

#define UPLOAD_TEST_URL @"http://devservices.firstonsite.ca/mobileservices/FileUpload.ashx"
#define UPLOAD_PRODUCTION_URL @"http://services.firstonsite.ca/mobileservices/FileUpload.ashx"

#define TEST_URL @"https://devservices.firstonsite.ca/mobileservices/%@/%@"
#define PRODUCTION_URL @"https://services.firstonsite.ca/mobileservices/%@/%@"

#define MSG_UPDATE_TIMER 60.0
#define USER_PHOTO_SIZE 1000.0f
#define USER_PHOTO_THUMB_SIZE 200.0f
#define CLAIM_PHOTO_SIZE 1280.0f
#define CLAIM_PHOTO_THUMB_SIZE 48.0f

#define UPDATE_CHECK_URL @"https://services.firstonsite.ca/applications/mobileFP/mobileFP9.plist"
#define UPDATE_URL @"itms-services://?action=download-manifest&url=https://services.firstonsite.ca/applications/mobileFP/mobileFP9.plist"

#define UPDATE_CHECK_TEST_URL @"https://services.firstonsite.ca/applications/mobileFPTest/mobileFP9.plist"
#define UPDATE_TEST_URL @"itms-services://?action=download-manifest&url=https://services.firstonsite.ca/applications/mobileFPTest/mobileFP9.plist"

// Set the environment:
// - For live charges, use PayPalEnvironmentProduction (default).
// - To use the PayPal sandbox, use PayPalEnvironmentSandbox.
// - For testing, use PayPalEnvironmentNoNetwork.
#define kPayPalEnvironment PayPalEnvironmentSandbox

#define PAYPAL_CLIENT_ID_FOR_SANDBOX @"AT1Jvv_XALzlofyux2yagU5V-lsM9nYdLbMegzVu0hi9CizlGZEkrLRhEN_QRIKLngxK2HUlwtto4TgW"
#define PAYPAL_CLIENT_ID_FOR_PRODUCTION @""

// App Mode
#define APP_MODE @"0" // Production - 1

#define RANDOM_INT(min, max) (min + arc4random_uniform(max - min + 1))

// Singleton Pattern Implementation
#define SHARED_INSTANCE_USING_BLOCK(block) \
static dispatch_once_t pred = 0; \
__strong static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = block(); \
}); \
return _sharedObject; \

#endif
