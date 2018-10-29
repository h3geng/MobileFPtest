//
//  ISktScanVersion.h
//  ScanApi
//
//  Created by Eric Glaenzer on 5/20/11.
//  Copyright 2011 SocketMobile. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ISktScanVersion : NSObject
- (unsigned long) getMajor;
- (unsigned long) getMiddle;
- (unsigned long) getMinor;
- (unsigned long) getBuild;
- (unsigned short) getMonth;
- (unsigned short) getDay;
- (unsigned short) getYear;
- (unsigned short) getHour;
- (unsigned short) getMinute;

@end
