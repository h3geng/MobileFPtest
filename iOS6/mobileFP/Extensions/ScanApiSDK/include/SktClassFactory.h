//
//  SktClassFactory.h
//  ScanApi
//
//  Created by Jimmy Yang on 11-1-26.
//  Copyright 2011 SocketMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISktScanApi.h"
#import "ISktScanDevice.h"

@interface SktClassFactory : NSObject {

}
+ (ISktScanObject*) createScanObject;
+(void)releaseScanObject: (ISktScanObject*)scanObj;

+ (ISktScanApi*) createScanApiInstance;
+(void)releaseScanApiInstance: (ISktScanApi*) scanApi;

+ (ISktScanDevice*) createDeviceInstance: (ISktScanApi*) scanApi;
+(void)releaseDeviceInstance:(ISktScanDevice*)deviceInstance;
@end
