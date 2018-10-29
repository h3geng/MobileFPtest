//
//  CBTManager.h
//  FlirBLETester
//
//  Created by Trebly on 11/20/13.
//  Copyright (c) 2013 FLIR Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CBTPeripheral.h"



/****** UI Protocol.  Independent of specific class ******/
@protocol bLeDiscoveryDelegate <NSObject>

- (void) discoveryDidRefresh;
- (void) discoveryStatePoweredOff;
- (void) writeToTextViewLog:(NSString *)logString;
- (void) writeToTextViewDetailInfo:(NSString *)detailString;
- (void) setNotifyBit:(CBPeripheral *)peripheral :(NSString *)charUUID :(Boolean)isOnOff;
@end


/****** class ******/
@interface CBTManager : NSObject

+ (id) sharedInstance;


/****** UI controls ******/
@property (nonatomic, assign) id<bLeDiscoveryDelegate>   discoveryDelegate;
@property (nonatomic, assign) id<DeviceAlarmProtocol>	peripheralDelegate;

- (void) stopScanning;
- (void) startScanningForUUIDString:(NSString *)uuidString;
- (void) connectPeripheral:(CBPeripheral*)peripheral;
- (void) disconnectPeripheral:(CBPeripheral*)peripheral;
- (void) centralManagerDidUpdateState:(CBCentralManager*)central;

/****** access to devices ******/
@property (retain, nonatomic) NSMutableArray    *foundPeripherals;
@property (retain, nonatomic) NSMutableArray	*connectedServices;

@end
