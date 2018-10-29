//
//  ISktScanSymbology.h
//  ScanApi
//
//  Created by Jimmy Yang on 5/19/11.
//  Copyright 2011 SocketMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "SktScanPropIds.h"
#include "SktScanTypes.h"


@interface ISktScanSymbology : NSObject
-(void)setID:(enum ESktScanSymbologyID)symid;
-(enum ESktScanSymbologyID)getID;
-(void)setFlags:(enum ESktScanSymbologyFlags)flags;
-(enum ESktScanSymbologyFlags)getFlags;
-(void)setStatus:(enum ESktScanSymbologyStatus)status;
-(enum ESktScanSymbologyStatus)getStatus;
-(NSString*)getName;

@end
