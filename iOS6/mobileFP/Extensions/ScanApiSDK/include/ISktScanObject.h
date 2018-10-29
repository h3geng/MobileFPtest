//
//  ISktScanObject.h
//  ScanApi
//
//  Created by Jimmy Yang on 11-1-26.
//  Copyright 2011 SocketMobile. All rights reserved.
//

#import "ISktScanMsg.h"
#import "ISktScanProperty.h"

@interface ISktScanObject : NSObject

-(ISktScanMsg*) Msg;
-(ISktScanProperty*) Property;
 
@end
