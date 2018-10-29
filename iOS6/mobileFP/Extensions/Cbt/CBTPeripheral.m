//
//  CBCPeripheral.m
//  FlirBLETester
//
//  Created by Trebly on 11/20/13.
//  Copyright (c) 2013 FLIR Systems, Inc. All rights reserved.
//

#import "CBTPeripheral.h"
#import "CBTManager.h"

/* TI Sensor Tag test...  */
NSString *flirServiceUUIDString = @"D813BF66-5E61-188C-3D47-2487320A8B6E";
NSString *flirCharacteristicUUIDString = @"E9A8B8C1-B91E-10A1-5241-C4D951378343";

@interface CBTPeripheral() <CBPeripheralDelegate> {
    
@private
    CBPeripheral		*servicePeripheral;
    CBService			*genericService;
    CBCharacteristic    *deviceCharacteristicData;
    CBUUID              *currentValueUUID;
    
    id<DeviceAlarmProtocol>	peripheralDelegate;
}
@end

@implementation CBTPeripheral

@synthesize peripheral = servicePeripheral;

/********************   Init    ********************/
- (id) initWithPeripheral:(CBPeripheral *)peripheral controller:(id<DeviceAlarmProtocol>)controller {
    self = [super init];
    if (self) {
        servicePeripheral = peripheral;
        [servicePeripheral setDelegate:self];
		peripheralDelegate = controller;
        
        currentValueUUID	= [CBUUID UUIDWithString:flirCharacteristicUUIDString];
	}
    return self;
}

- (void) dealloc {
	if (servicePeripheral) {
        [servicePeripheral setDelegate:[CBTManager sharedInstance]];
        servicePeripheral = nil;
        currentValueUUID = nil;
    }
}

- (void) reset {
	if (servicePeripheral) {
		servicePeripheral = nil;
	}
}

/********************   Service Interactions    ********************/
- (void) start {
	CBUUID	*serviceUUID	= [CBUUID UUIDWithString:flirServiceUUIDString];
	NSArray	*serviceArray	= [NSArray arrayWithObjects:serviceUUID, nil];
    
    [servicePeripheral discoverServices:serviceArray];
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
	NSArray *services = nil;
	NSArray *uuids = [NSArray arrayWithObjects:currentValueUUID, nil];
    
    //NSLog(@"Scanning Services\n");
    [peripheralDelegate writeToTextViewLog:@"Scanning Services\n"];
    
	if (peripheral != servicePeripheral) {
		//NSLog(@"Wrong Peripheral.\n");
        [peripheralDelegate writeToTextViewLog:@"Wrong Peripheral.\n"];
		return ;
	}
    
    if (error != nil) {
        //NSLog(@"Error %@\n", error);
        [peripheralDelegate writeToTextViewLog:[NSString stringWithFormat:@"Error:\t%@", error]];
		return ;
	}
    
	services = [peripheral services];
	if (!services || ![services count]) {
		return ;
	}
    
	genericService = nil;
    
	for (CBService *service in services) {
        
         //NSLog(@"Services found : %@",[service UUID]);
        [peripheralDelegate writeToTextViewDetailInfo:[NSString stringWithFormat:@"Description :\n\t%@", service.description]];
        [peripheralDelegate writeToTextViewDetailInfo:[NSString stringWithFormat:@"Services    :\n\t%@", service.UUID]];
        [peripheralDelegate writeToTextViewDetailInfo:[NSString stringWithFormat:@"Peripheral :\n\t%@", peripheral.identifier.UUIDString]];

		if ([[service UUID] isEqual:[CBUUID UUIDWithString:flirServiceUUIDString]]) {
			genericService = service;
            [peripheral discoverCharacteristics:uuids forService:genericService];
			break;
		}
	}
    
	//if (genericService) {
	//	[peripheral discoverCharacteristics:uuids forService:genericService];
	//}
}


- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error; {
	NSArray *characteristics = [service characteristics];
	CBCharacteristic *characteristic;
    
	if (peripheral != servicePeripheral) {
		//NSLog(@"Incorrect Peripheral.\n");
        [peripheralDelegate writeToTextViewLog:@"Incorrect Peripheral.\n"];
		return;
	}
	
	if (service != genericService) {
		//NSLog(@"Incorrect Service.\n");
        [peripheralDelegate writeToTextViewLog:@"Incorrect Service.\n"];
		return;
	}
    
    if (error != nil) {
		//NSLog(@"Error %@\n", error);
		return;
	}
    
	for (characteristic in characteristics) {
		if (characteristic != nil && [[characteristic UUID] isEqual:currentValueUUID]) {
            NSLog(@"Discovered characteristic %@", [characteristic UUID]);

            //[peripheral setNotifyValue:YES forCharacteristic:characteristic];
            //[peripheralDelegate setNotifyBit:peripheral :flirCharacteristicUUIDString :(Boolean)NO];
            //[peripheralDelegate writeToTextViewLog:@"Data notification state set: On\n"];
            [peripheralDelegate writeToTextViewDetailInfo:[[NSString stringWithFormat:@"Characteristic :\n\t%@", characteristic.UUID] stringByAppendingString:@"\n\n"]];
            deviceCharacteristicData = characteristic;
		}
	}
    
}

/********************   Characteristics Interactions    ********************/
- (void)enteredBackground {
    for (CBService *service in [servicePeripheral services]) {
        if ([[service UUID] isEqual:[CBUUID UUIDWithString:flirServiceUUIDString]]) {
            
            //Find characteristic
            for (CBCharacteristic *characteristic in [service characteristics]) {
                if ( [[characteristic UUID] isEqual:[CBUUID UUIDWithString:flirCharacteristicUUIDString]] ) {
                    
                    //Stop notifications from device
                    [peripheralDelegate setNotifyBit:service.peripheral :flirCharacteristicUUIDString :(Boolean)NO];
                    //[servicePeripheral setNotifyValue:NO forCharacteristic:characteristic];
                    [peripheralDelegate writeToTextViewLog:@"Data notification state set:Off : enteredBackground\n"];
                }
            }
        }
    }
}

- (void)enteredForeground {
    for (CBService *service in [servicePeripheral services]) {
        if ([[service UUID] isEqual:[CBUUID UUIDWithString:flirServiceUUIDString]]) {
            
            // Find characteristic
            for (CBCharacteristic *characteristic in [service characteristics]) {
                if ( [[characteristic UUID] isEqual:[CBUUID UUIDWithString:flirCharacteristicUUIDString]] ) {
                    
                    //Start notifications from device
                    //[peripheralDelegate setNotifyBit:peripheral :characteristic];
                    [peripheralDelegate setNotifyBit:service.peripheral :flirCharacteristicUUIDString :(Boolean)YES];
                    //[servicePeripheral setNotifyValue:YES forCharacteristic:characteristic];
                    [peripheralDelegate writeToTextViewLog:@"Data notification state set:On : enteredForeground\n"];
                }
            }
        }
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
	if (peripheral != servicePeripheral) {
		//NSLog(@"Wrong peripheral\n");
        [peripheralDelegate writeToTextViewLog:@"Wrong peripheral\n"];
		return ;
	}
    
    if ([error code] != 0) {
		//NSLog(@"Error %@\n", error);
        [peripheralDelegate writeToTextViewLog:[NSString stringWithFormat:@"%@", error]];
		return ;
	}
    
    if ([[characteristic UUID] isEqual:currentValueUUID]) {
        
        NSMutableString *resultHex = [NSMutableString string];
        NSData *tk = [deviceCharacteristicData value];

        if (tk.length > 0) {
            
            const char *bytes = [tk bytes];
            for (int i = 0; i < [tk length]; i++)
                [resultHex appendFormat:@" %x", (Byte)bytes[i]];
            
            [peripheralDelegate updateReadingLables:tk];
            [peripheralDelegate writeToTextViewLog:[resultHex stringByAppendingString:@"\n"]];
             return;
        }//end tk len
    }
     return;
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    //[peripheralDelegate writeToTextViewLog:@"Data notification state set\n"];
    //NSLog(@"Data notification state set %@ error = %@", characteristic,error);
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    [peripheralDelegate writeToTextViewLog:@"Did write value for characteristic\n"];
    //NSLog(@"didWriteValueForCharacteristic %@ error = %@",characteristic,error);
}

@end







