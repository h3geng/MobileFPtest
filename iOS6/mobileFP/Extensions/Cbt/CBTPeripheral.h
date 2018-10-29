//
//  CBCPeripheral.h
//  FlirBLETester
//
//  Created by Trebly on 11/20/13.
//  Copyright (c) 2013 FLIR Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

/***************    Service Characteristics ***************/
extern NSString *flirServiceUUIDString;
extern NSString *flirCharacteristicUUIDString;

@class CBTPeripheral;

@protocol DeviceAlarmProtocol<NSObject>
- (void)deviceServiceDidChangeStatus:(CBTPeripheral*)service;
- (void)updateReadingLables:(NSData *)logString;
- (void)writeToTextViewLog:(NSString *)logString;
- (void)writeToTextViewDetailInfo:(NSString *)detailString;
- (void)setNotifyBit:(CBPeripheral *)peripheral :(NSString *)charUUID :(Boolean)isOnOff;;
@end

@interface CBTPeripheral : NSObject

- (id)initWithPeripheral:(CBPeripheral *)peripheral controller:(id<DeviceAlarmProtocol>)controller;
- (void)reset;
- (void)start;
- (void)enteredBackground;
- (void)enteredForeground;

@property (readonly) CBPeripheral *peripheral;

@end
