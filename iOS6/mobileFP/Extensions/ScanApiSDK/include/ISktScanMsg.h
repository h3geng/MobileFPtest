//
//  ISktScanMsg.h
//  ScanApi
//
//  Created by Jimmy Yang on 11-1-26.
//  Copyright 2011 SocketMobile. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "SktScanPropIds.h"
#import "SktScanTypes.h"
#import "ISktScanEvent.h"

@class ISktScanDevice;
@interface ISktScanMsg : NSObject

-(enum ESktScanMsgID) MsgID;
-(SKTRESULT) Result;
-(NSString*) DeviceName;
-(ISktScanDevice*) hDevice;
-(uint32_t) DeviceType;
-(NSString*) DeviceGuid;
-(ISktScanEvent*) Event;

@end

