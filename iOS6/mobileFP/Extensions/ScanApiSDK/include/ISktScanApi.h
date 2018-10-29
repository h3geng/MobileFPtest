//
//  ISktScanApi.h
//  ScanApi
//
//  Created by Jimmy Yang on 11-1-27.
//  Copyright 2011 SocketMobile. All rights reserved.
//
#import "ISktScanDevice.h"
#import "ISktScanObject.h"

@interface ISktScanApi : ISktScanDevice
-(SKTRESULT) waitForScanObject: (ISktScanObject*) scanObj TimeOut: (unsigned long) ulTimeOut ;
-(SKTRESULT) releaseScanObject: (ISktScanObject*) scanObj;
@end

//@protocol ScanAPIObjectDelegate
//    -(id)startController;
//@end


