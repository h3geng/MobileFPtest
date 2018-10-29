//
//  ISktScanDevice.h
//  ScanApi
//
//  Created by Jimmy Yang on 11-1-30.
//  Copyright 2011 SocketMobile. All rights reserved.
//
#include "SktScanPropIds.h"
#include "SktScanTypes.h"
#import "ISktScanObject.h"

@interface ISktScanDevice : NSObject
-(SKTRESULT) open: (NSString*) devicename;
-(SKTRESULT) close;
-(SKTRESULT) getProperty: (ISktScanObject*) pScanObj;
-(SKTRESULT) setProperty: (ISktScanObject*) pScanObj;

@end
