//
//  CBTManager.m
//  FlirBLETester
//
//  Created by Trebly on 11/20/13.
//  Copyright (c) 2013 FLIR Systems, Inc. All rights reserved.
//

#import "CBTManager.h"


@interface CBTManager () <CBCentralManagerDelegate, CBPeripheralDelegate> {
	CBCentralManager    *centralManager;
	BOOL				pendingInit;
}
@end


@implementation CBTManager

@synthesize foundPeripherals;
@synthesize connectedServices;
@synthesize discoveryDelegate;
@synthesize peripheralDelegate;


/****************** Initilization ******************/
+ (id) sharedInstance
{
	static CBTManager	*this	= nil;
    
	if (!this)
		this = [[CBTManager alloc] init];
    
	return this;
}


- (id) init
{
    self = [super init];
    if (self) {
        
		pendingInit = YES;
		centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
		foundPeripherals = [[NSMutableArray alloc] init];
		connectedServices = [[NSMutableArray alloc] init];
	}
    return self;
}



- (void) dealloc
{
    // We are a singleton and as such, dealloc shouldn't be called.
    assert(NO);
    foundPeripherals = nil;
    connectedServices = nil;
    //centralManager = nil;
}


/* Reload from file. */
- (void) loadSavedDevices
{
	NSArray	*storedDevices	= [[NSUserDefaults standardUserDefaults] arrayForKey:@"StoredDevices"];
    
	if (![storedDevices isKindOfClass:[NSArray class]]) {
        //NSLog(@"No stored UUID's to load\n");
        [self writeToUILog:@"No stored UUID's to load\n"];
        return;
    }
    
    for (id deviceUUIDString in storedDevices) {
        
        if (![deviceUUIDString isKindOfClass:[NSString class]]) continue;
        
        CFUUIDRef uuid = CFUUIDCreateFromString(NULL, (CFStringRef)deviceUUIDString);
        if (!uuid)  continue;
        
        [centralManager retrievePeripheralsWithIdentifiers:[NSArray arrayWithObject:(id)CFBridgingRelease(uuid)]];
        CFRelease(&uuid);
    }
}


- (void) addSavedDevice:(CFUUIDRef) uuid
{
	NSArray			*storedDevices	= [[NSUserDefaults standardUserDefaults] arrayForKey:@"StoredDevices"];
	NSMutableArray	*newDevices		= nil;
	CFStringRef		uuidString		= NULL;
    
	if (![storedDevices isKindOfClass:[NSArray class]]) {
        //NSLog(@"Can't find/create an array to store the uuid");
        [self writeToUILog:@"Can't find/create an array to store the uuid"];
        return;
    }
    
    newDevices = [NSMutableArray arrayWithArray:storedDevices];
    
    uuidString = CFUUIDCreateString(NULL, uuid);
    if (uuidString) {
        [newDevices addObject:(NSString*)CFBridgingRelease(uuidString)];
        CFRelease(&uuidString);
    }
    /* Store */
    [[NSUserDefaults standardUserDefaults] setObject:newDevices forKey:@"StoredDevices"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void) removeSavedDevice:(CFUUIDRef) uuid
{
	NSArray			*storedDevices	= [[NSUserDefaults standardUserDefaults] arrayForKey:@"StoredDevices"];
	NSMutableArray	*newDevices		= nil;
	CFStringRef		uuidString		= NULL;
    
	if ([storedDevices isKindOfClass:[NSArray class]]) {
		newDevices = [NSMutableArray arrayWithArray:storedDevices];
        
		uuidString = CFUUIDCreateString(NULL, uuid);
		if (uuidString) {
			[newDevices removeObject:(NSString*)CFBridgingRelease(uuidString)];
            CFRelease(&uuidString);
        }
		/* Store */
		[[NSUserDefaults standardUserDefaults] setObject:newDevices forKey:@"StoredDevices"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}


- (void) centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
	CBPeripheral	*peripheral;
	
	/* Add to list. */
	for (peripheral in peripherals) {
		[central connectPeripheral:peripheral options:nil];
	}
	[discoveryDelegate discoveryDidRefresh];
}


- (void) centralManager:(CBCentralManager *)central didRetrievePeripheral:(CBPeripheral *)peripheral
{
	[central connectPeripheral:peripheral options:nil];
	[discoveryDelegate discoveryDidRefresh];
}


- (void) centralManager:(CBCentralManager *)central didFailToRetrievePeripheralForUUID:(CFUUIDRef)UUID error:(NSError *)error
{
	/* Nuke from plist. */
	[self removeSavedDevice:UUID];
}


/****************** Discovery ******************/
- (void) startScanningForUUIDString:(NSString *)uuidString
{
	NSArray         *uuidArray	= [NSArray arrayWithObjects:[CBUUID UUIDWithString:uuidString], nil];
	NSDictionary    *options	= [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
	[centralManager scanForPeripheralsWithServices:uuidArray options:options];
    
    uuidArray = nil;
    options = nil;
    //[centralManager scanForPeripheralsWithServices:nil options:nil];
}


- (void) stopScanning
{
	[centralManager stopScan];
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
	if (![foundPeripherals containsObject:peripheral]) {
		[foundPeripherals addObject:peripheral];
		[discoveryDelegate discoveryDidRefresh];
	}
}



/****************** Connection & Disconnection ******************/
- (void) connectPeripheral:(CBPeripheral*)peripheral
{
	if (peripheral.state != CBPeripheralStateConnected) {
		[centralManager connectPeripheral:peripheral options:nil];
	}
}


- (void) disconnectPeripheral:(CBPeripheral*)peripheral
{
	[centralManager cancelPeripheralConnection:peripheral];
}


- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    CBTPeripheral *service = nil;
	
	/* Create a service instance. */
	service = [[CBTPeripheral alloc] initWithPeripheral:peripheral controller:peripheralDelegate];
    
	[service start];
    
	if (![connectedServices containsObject:service])    [connectedServices addObject:service];
	if ([foundPeripherals containsObject:peripheral])   [foundPeripherals removeObject:peripheral];
    
    [peripheralDelegate deviceServiceDidChangeStatus:service];
	[discoveryDelegate discoveryDidRefresh];
}


- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    //NSLog(@"Attempted connection to peripheral %@ failed: %@", [peripheral name], [error localizedDescription]);
    [self writeToUILog:@"Attempted connection to peripheral"];
}


- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{

	CBTPeripheral	*service	= nil;
    
	for (service in connectedServices) {
		if ([service peripheral] == peripheral) {
			[connectedServices removeObject:service];
            [peripheralDelegate deviceServiceDidChangeStatus:service];
			break;
		}
	}
	[discoveryDelegate discoveryDidRefresh];
}


- (void) writeToUILog:(NSString *)text {
    
    [discoveryDelegate writeToTextViewLog:text];
}


- (void) clearDevices
{
    CBTPeripheral	*service;
    [foundPeripherals removeAllObjects];
    
    for (service in connectedServices) {
        [service reset];
    }
    [connectedServices removeAllObjects];
    
    connectedServices = nil;
}


- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSDictionary *options;
    //static CBCentralManagerState cBReady = false;
    
    switch (centralManager.state) {
        case CBCentralManagerStatePoweredOff:
            
            //NSLog(@"BLE powered off");
            [self writeToUILog:@"BLE powered off"];
            [self clearDevices];
            [discoveryDelegate discoveryDidRefresh];
            break;
        case CBCentralManagerStatePoweredOn:
            
            //NSLog(@"BLE powered on and ready");
            [self writeToUILog:@"\nBLE powered on and ready"];
            
            pendingInit = NO;
			[self loadSavedDevices];
            
            options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
            [centralManager scanForPeripheralsWithServices:nil options:options];
            
			//[centralManager retrieveConnectedPeripherals];
			[discoveryDelegate discoveryDidRefresh];
			break;
        case CBCentralManagerStateResetting:
            
            //NSLog(@"BLE hardware is resetting");
            [self writeToUILog:@"BLE hardware is resetting"];
            [self clearDevices];
            [discoveryDelegate discoveryDidRefresh];
			pendingInit = YES;
			break;
        case CBCentralManagerStateUnauthorized:
            
            //NSLog(@"BLE state is unauthorized");
            [self writeToUILog:@"BLE state is unauthorized"];
            break;
        case CBCentralManagerStateUnknown:
            
            //NSLog(@"BLE state is unknown");
            [self writeToUILog:@"BLE state is unknown"];
            break;
        case CBCentralManagerStateUnsupported:
            
            //NSLog(@"BLE unsupported on this platform");
            [self writeToUILog:@"BLE unsupported on this platform"];
            break;
        default:
            break;
    }
    //cBReady = [centralManager state];
    //[central scanForPeripheralsWithServices:nil options:nil];
}


@end
