//
//  ScanApiHelper.m
//  ScannerSettings
//
//  Created by Eric Glaenzer on 7/29/11.
//  Copyright 2011 Socket Mobile, Inc. All rights reserved.
//

#import "ScanApiHelper.h"

/**
 * CommandContext
 *
 * This class holds the various parameter for a particular
 * property. It will be stored in the Context member of a property
 * to get it back upon property completion.
 */
@implementation CommandContext
-(id)initWithParam:(BOOL)getOperation
           ScanObj:(ISktScanObject*)scanObj
        ScanDevice:(ISktScanDevice*)scanDevice
            Device:(DeviceInfo*)device
            Target:(id)target
          Response:(SEL)response{
    self=[super init];
    if(self!=nil){
        _getOperation=getOperation;
        _scanObj=scanObj;
        _device=scanDevice;
        _deviceInfo=device;
        _target=target;
        _response=response;
        status=statusReady;

        [[_scanObj Property]setContext:self];// set the property context to this CommandContext instance
    }
    return self;
}

#if __has_feature(objc_arc)
-(void)dealloc{
    [SktClassFactory releaseScanObject:_scanObj];
}
#else
-(void)dealloc{
    [SktClassFactory releaseScanObject:_scanObj];
    _scanObj=nil;
    [super dealloc];
}
#endif

@synthesize retry;
@synthesize status;

-(ISktScanDevice*)getScanDevice{
    return _device;
}

-(ISktScanObject*)getScanObject{
    return _scanObj;
}

-(DeviceInfo*)getDeviceInfo{
    return _deviceInfo;
}

// remove the warning about potential memory leak
// in the _response selector because the compiler
// doesn't know in ARC mode if it needs to apply
// a retain or release.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
-(SKTRESULT)doCallback:(ISktScanObject*)scanObj{
    SKTRESULT result=ESKT_NOERROR;
    if((_response!=nil)&&(_target!=nil)){
        [_target performSelector:_response withObject:scanObj];
    }
    else{
        result=[[scanObj Msg]Result];
    }
    status=statusCompleted;
    return result;
}
#pragma clang diagnostic push


-(SKTRESULT)doCommand{
    SKTRESULT result=ESKT_NOERROR;
    if(_device==nil)
        result=ESKT_INVALIDHANDLE;

    if(SKTSUCCESS(result)){
        if(_getOperation==true){
            result=[_device getProperty:_scanObj];
        }
        else{
            result=[_device setProperty:_scanObj];
        }
        retry++;
        // waiting for a complete event
        status=statusNotCompleted;
    }
    return result;
}

@end


@implementation ScanApiHelper
{
    bool _softScanTrigger;
    bool _softScanPending;
}
-(id)init{
    static ScanApiHelper* sharedScanApiHelper=nil;
    self=[super init];
    if(self!=nil){
        sharedScanApiHelper=self;
        _commandContextsLock=[[NSObject alloc]init];
        _deviceInfoList=[[NSMutableDictionary alloc]init];
        _scanApiOpen=FALSE;
        _scanApiTerminated=TRUE;// by default ScanApi is not started
        _delegateStack=[[NSMutableArray alloc]init];
        // flag to know if SoftScan is pending so we can ignored
        // the popDelegate action, which on a iPhone/iPod occurs when
        // scanning with SoftScan, and therefore the current controller
        // can receive the onDecodedData notification
        _softScanPending = false;
        _softScanTrigger = false;
    }
    return self;
}

#if __has_feature(objc_arc)
-(void)dealloc{
    if(_scanApi!=nil){
        [_scanApi close];
        [SktClassFactory releaseScanApiInstance:_scanApi];
        _scanApi=nil;
    }
    _noDeviceText=nil;

    [_commandContexts removeAllObjects];
    _commandContexts=nil;

    _commandContextsLock=nil;

    _deviceInfoList=nil;
    _delegateStack=nil;
}
#else
-(void)dealloc{
    if(_scanApi!=nil){
        [_scanApi close];
        [SktClassFactory releaseScanApiInstance:_scanApi];
        _scanApi=nil;
    }

    [_noDeviceText release];
    _noDeviceText=nil;

    [_commandContexts removeAllObjects];
    [_commandContexts release];
    _commandContexts=nil;

    [_commandContextsLock release];
    _commandContextsLock=nil;

    [_deviceInfoList release];
    _deviceInfoList=nil;

    [_delegateStack release];
    _delegateStack=nil;

    [super dealloc];
}
#endif

+(ScanApiHelper*)sharedScanApiHelper{
    static ScanApiHelper* scanApiHelper=nil;
    if(scanApiHelper==nil){
        scanApiHelper=[[ScanApiHelper alloc]init];
    }
    return scanApiHelper;
}

-(void)pushDelegate:(id<ScanApiHelperDelegate>)delegate{
    if(_delegate != delegate){
        if(_delegate!=nil){
            [_delegateStack addObject:_delegate];
        }
        _delegate=delegate;
        [self generateDeviceArrivals];
    }
    // whatever view is pushing, it means SoftScan
    // is no longer pending
    _softScanPending = false;
    _softScanTrigger = false;
}

-(void)popDelegate:(id<ScanApiHelperDelegate>)delegate{
    if(_delegate ==delegate){
        // if SoftScan has just been triggered, then
        // SoftScan is now Pending
        // if SoftScan is pending we don't want to remove
        // the current view controller from the notification stack
        // that way it can still receive the SoftScan decoded data.
        if(_softScanTrigger == true){
            _softScanPending = true;
        }
        _softScanTrigger = false;
        if(_softScanPending == false){
            if(_delegateStack.count>0){
                id<ScanApiHelperDelegate> newDelegate=[_delegateStack objectAtIndex:_delegateStack.count-1];
                [_delegateStack removeLastObject];
                _delegate = newDelegate;
                // generate a device Arrival for each scanner we've already receive
                // so that the new view can be aware of the connected scanners
                [self generateDeviceArrivals];
            }
            else{
                _delegate=nil;
            }
        }
    }
}

/**
 * register for notifications in order to receive notifications such as
 * "Device Arrival", "Device Removal", "Decoded Data"...etc...
 * @param delegate
 */
-(void)setDelegate:(id<ScanApiHelperDelegate>)delegate{
    _delegate=delegate;
}

/**
 * specifying a name to display when no device is connected
 * will add a no device connected item in the list with
 * the name specified, otherwise if there is no device connected
 * the list will be empty.
 */
-(void)setNoDeviceText:(NSString*) noDeviceText{
#if __has_feature(objc_arc)
#else
    [_noDeviceText release];
    [noDeviceText retain];
#endif
    _noDeviceText=noDeviceText;
}

/**
 * get the list of devices. If there is no device
 * connected and a text has been specified for
 * when there is no device then the list will
 * contain one item which is the no device in the
 * list
 * @return
 */
-(NSDictionary*) getDevicesList{
    return _deviceInfoList;
}

/**
 * get a DeviceInfo object from a ScanObject received by ScanAPI.
 *
 * If no DeviceInfo matches, this method returns nil
 * @param scanObj, ScanObject received by ScanAPI that contains the
 * device information.
 *
 * @return a device info instance or nil if no device info in the list
 * matches to the ScanObj device information.
 */
-(DeviceInfo*) getDeviceInfoFromScanObject:(ISktScanObject*)scanObj{
    ISktScanDevice* scanDevice=[[scanObj Msg]hDevice];

    // retrieve the DeviceInfo object from the list
    DeviceInfo* deviceInfo=[_deviceInfoList valueForKey:[NSString stringWithFormat:@"%@",scanDevice]];
    return deviceInfo;
}





/**
 * check if there is a device connected
 * @return
 */
-(BOOL) isDeviceConnected{
    BOOL isConnected=FALSE;
    if(_deviceInfoList!=nil){
        if([_deviceInfoList count]>0){
            if(_noDeviceText!=nil){
                isConnected=![[_deviceInfoList allValues]containsObject:_noDeviceText];// check if there is a no device text item in the list
            }
            else
                isConnected=TRUE;// there is at least one device connected when no device text is not used
        }
    }
    return isConnected;
}

/**
 * flag to know if ScanAPI is open
 * @return
 */
-(BOOL)isScanApiOpen{
    return _scanApiOpen;
}


/**
 * open ScanAPI and initialize ScanAPI
 * The result of opening ScanAPI is returned in the callback
 * onScanApiInitializeComplete
 */
-(void)open{
    // make sure the devices list is empty
    [_deviceInfoList removeAllObjects];

    // if there is a text to display when no device
    // is connected then add it now in the list
    if(_noDeviceText!=nil)
        [_deviceInfoList setObject:_noDeviceText forKey:_noDeviceText];

    [SktClassFactory releaseScanObject:_scanObjectReceived];
    _scanObjectReceived=[SktClassFactory createScanObject];
    // Start ScanAPI initialization into a thread
    // as sometimes this could be a lengthy operation
#if __has_feature(objc_arc)
    NSThread* scanApiInitThread=[[NSThread alloc]initWithTarget:self selector:@selector(initializeScanAPIThread:) object:nil];
#else
    NSThread* scanApiInitThread=[[[NSThread alloc]initWithTarget:self selector:@selector(initializeScanAPIThread:) object:nil]
                                 autorelease];
#endif
    [scanApiInitThread start];
    _scanApiOpen=TRUE;
}

/**
 * close ScanAPI. The callback onScanApiTerminated
 * is invoked as soon as ScanAPI is completely closed.
 * If a device is connected, a device removal will be received
 * during the process of closing ScanAPI.
 */
-(void)close{
    [self postScanApiAbort:nil Response:nil];
    _scanApiOpen=FALSE;
}

/**
 * remove the pending commands for a specific device
 * or all the pending commands if null is passed as
 * iDevice parameter
 * @param iDevice reference to the device for which
 * the commands must be removed from the list or <b>null</b>
 * if all the commands must be removed.
 */
-(void)removeCommand:(DeviceInfo*)deviceInfo{
    ISktScanDevice* iDevice=[deviceInfo getSktScanDevice];
    CommandContext* commandContext=nil;
    int index=0;
    @synchronized(_commandContextsLock){
        while(index<[_commandContexts count]){
            commandContext=[_commandContexts objectAtIndex:index];
            if([commandContext getScanDevice]==iDevice){
                [_commandContexts removeObjectAtIndex:index];
                commandContext=nil;
                index=0;
            }
            else
                index++;
        }
    }
}

/**
 * postGetScanAPIVersion
 * retrieve the ScanAPI Version
 */
-(void)postGetScanApiVersion:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdVersion];
    [[scanObj Property]setType:kSktScanPropTypeNone];

    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:_scanApi
                                                          Device:nil
                                                         Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}


/**
 * postSetConfirmationMode
 * Configures ScanAPI so that decoded data must be confirmed by this application before the
 * scanner can be triggered again.
 */
-(void)postSetConfirmationMode:(unsigned char)mode Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdDataConfirmationMode];
    [[scanObj Property]setType:kSktScanPropTypeByte];
    [[scanObj Property]setByte:mode];

    CommandContext* command=[[CommandContext alloc]initWithParam:FALSE
                                                         ScanObj:scanObj
                                                      ScanDevice:_scanApi
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postGetConfirmationMode
 * Retrieves ScanAPI confirmation mode indicating if the decoded data must be confirmed by
 * this application before the scanner can be triggered again.
 */
-(void)postGetConfirmationMode:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdDataConfirmationMode];
    [[scanObj Property]setType:kSktScanPropTypeNone];

    CommandContext* command=[[CommandContext alloc]initWithParam:FALSE
                                                         ScanObj:scanObj
                                                      ScanDevice:_scanApi
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}


/**
 * postScanApiAbort
 *
 * Request ScanAPI to shutdown. If there is some devices connected
 * we will receive Remove event for each of them, and once all the
 * outstanding devices are closed, then ScanAPI will send a
 * Terminate event upon which we can close this application.
 * If the ScanAPI Abort command failed, then the callback will
 * close ScanAPI
 */
-(void)postScanApiAbort:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdAbort];
    [[scanObj Property]setType:kSktScanPropTypeNone];

    CommandContext* command=[[CommandContext alloc]initWithParam:FALSE
                                                         ScanObj:scanObj
                                                      ScanDevice:_scanApi
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postSetDataConfirmation
 * acknowledge the decoded data<p>
 * This is only required if the scanner Confirmation Mode is set to kSktScanDataConfirmationModeApp
 */
-(void)postSetDataConfirmation:(DeviceInfo*)deviceInfo goodData:(BOOL) good Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdDataConfirmationDevice];
    [[scanObj Property]setType:kSktScanPropTypeUlong];
    [[scanObj Property]setUlong:SKTDATACONFIRMATION(0, kSktScanDataConfirmationRumbleNone,
                                                    kSktScanDataConfirmationBeepGood,
                                                    kSktScanDataConfirmationLedGreen)];

    if(good == FALSE){
            [[scanObj Property]setUlong:SKTDATACONFIRMATION(0, kSktScanDataConfirmationRumbleNone,
                                                                kSktScanDataConfirmationBeepBad,
                                                                kSktScanDataConfirmationLedRed)];
    }
    CommandContext* command=[[CommandContext alloc]initWithParam:FALSE
                                                         ScanObj:scanObj
                                                      ScanDevice:[deviceInfo getSktScanDevice]
                                                          Device:deviceInfo
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postSetSoftScanStatus
 * enable or disable the softscan feature.
 */
-(void)postSetSoftScanStatus:(unsigned char)action Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdSoftScanStatus];
    [[scanObj Property]setType:kSktScanPropTypeByte];
    [[scanObj Property]setByte:action];

    CommandContext* command=[[CommandContext alloc]initWithParam:FALSE
                                                         ScanObj:scanObj
                                                      ScanDevice:_scanApi
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postGetSoftScanStatus
 * Retrieve the status of the softscan feature.
 */
-(void)postGetSoftScanStatus:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdSoftScanStatus];
    [[scanObj Property]setType:kSktScanPropTypeNone];

    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:_scanApi
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postGetBtAddress
 * Creates a SktScanObject and initializes it to perform a request for the
 * Bluetooth address in the scanner.
 */
-(void)postGetBtAddress:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdBluetoothAddressDevice];
    [[scanObj Property]setType:kSktScanPropTypeNone];

    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:[deviceInfo getSktScanDevice]
                                                          Device:deviceInfo
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postGetDeviceType
 * Creates a SktScanObject and initializes it to perform a request for the
 * device type of the scanner.
 */
-(void)postGetDeviceType:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdDeviceType];
    [[scanObj Property]setType:kSktScanPropTypeNone];

    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:[deviceInfo getSktScanDevice]
                                                          Device:deviceInfo
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postGetFirmwareVersion
 * Creates a SktScanObject and initializes it to perform a request for the
 * firmware revision in the scanner.
 */
-(void)postGetFirmwareVersion:(DeviceInfo*)deviceInfo Target:target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdVersionDevice];
    [[scanObj Property]setType:kSktScanPropTypeNone];

    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:[deviceInfo getSktScanDevice]
                                                          Device:deviceInfo
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}


/**
 * postGetBattery
 * Creates a SktScanObject and initializes it to perform a request for the
 * battery level in the scanner.
 */
-(void)postGetBattery:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdBatteryLevelDevice];
    [[scanObj Property]setType:kSktScanPropTypeNone];

    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:[deviceInfo getSktScanDevice]
                                                          Device:deviceInfo
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postGetStandConfig
 * Creates a SktScanObject and initializes it to perform a request for the
 * stand config of the scanner.
 */
-(void)postGetStandConfig:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdStandConfigDevice];
    [[scanObj Property]setType:kSktScanPropTypeNone];

    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:[deviceInfo getSktScanDevice]
                                                          Device:deviceInfo
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postSetStandConfig
 * Creates a SktScanObject and initializes it to perform a request for changing the
 * stand config of the scanner.
 *
 */
-(void)postSetStandConfig:(DeviceInfo*)deviceInfo StandConfig:(long) standConfig Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdStandConfigDevice];
    [[scanObj Property]setType:kSktScanPropTypeUlong];
    [[scanObj Property]setUlong:standConfig];

    CommandContext* command=[[CommandContext alloc]initWithParam:FALSE
                                                         ScanObj:scanObj
                                                      ScanDevice:[deviceInfo getSktScanDevice]
                                                          Device:deviceInfo
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postGetDecodeActionDevice
 *
 * Creates a SktScanObject and initializes it to perform a request for the
 * Decode Action in the scanner.
 *
 * The local decode action can be a flag set to one or more of these flags:
 *    kSktScanLocalDecodeActionNone: No action required (cannot be combined with another value)
 *    kSktScanLocalDecodeActionBeep: Device will beep
 *    kSktScanLocalDecodeActionFlash: Device will flash the Green localAcknowledgment
 *    kSktScanLocalDecodeActionRumble: Device will rumble once
 */
-(void)postGetDecodeActionDevice:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdLocalDecodeActionDevice];
    [[scanObj Property]setType:kSktScanPropTypeNone];

    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:[deviceInfo getSktScanDevice]
                                                          Device:deviceInfo
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif

}


/**
 * postSetDecodeActionDevice
 *
 * Configure the local decode action of the device
 *
 * @param deviceInfo
 * @param decodeAction
 * The local decode action can be a flag set to one or more of these flags:
 *    kSktScanLocalDecodeActionNone: No action required (cannot be combined with another value)
 *    kSktScanLocalDecodeActionBeep: Device will beep
 *    kSktScanLocalDecodeActionFlash: Device will flash the Green localAcknowledgment
 *    kSktScanLocalDecodeActionRumble: Device will rumble once
 */
-(void)postSetDecodeActionDevice:(DeviceInfo*)deviceInfo DecodeAction:(int)decodeAction Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdLocalDecodeActionDevice];
    [[scanObj Property]setType:kSktScanPropTypeByte];
    [[scanObj Property]setByte:decodeAction];

    CommandContext* command=[[CommandContext alloc]initWithParam:FALSE
                                                         ScanObj:scanObj
                                                      ScanDevice:[deviceInfo getSktScanDevice]
                                                          Device:deviceInfo
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postGetLocalAcknowledgmentDevice
 *
 * Creates a SktScanObject and initializes it to perform a request for the
 * Local Acknowledgment of the scanner.
 *
 */
-(void)postGetLocalAcknowledgmentDevice:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdLocalAcknowledgmentDevice];
    [[scanObj Property]setType:kSktScanPropTypeNone];

    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:[deviceInfo getSktScanDevice]
                                                          Device:deviceInfo
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif

}


/**
 * postSetLocalAcknowledgmentDevice
 *
 * Configure the local Acknownledgment of the device
 *
 * @param deviceInfo
 * @param localAcknowledgment:
 *      kSktScanDeviceDataAcknowledgmentOff: turn off the device local acknowledgment or
 *      kSktScanDeviceDataAcknowledgmentOn (default) to turn on the device local acknownledgment
 */
-(void)postSetLocalAcknowledgmentDevice:(DeviceInfo*)deviceInfo LocalAcknowledgment:(unsigned char)localAcknowledgment Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdLocalAcknowledgmentDevice];
    [[scanObj Property]setType:kSktScanPropTypeByte];
    [[scanObj Property]setByte:localAcknowledgment];

    CommandContext* command=[[CommandContext alloc]initWithParam:FALSE
                                                         ScanObj:scanObj
                                                      ScanDevice:[deviceInfo getSktScanDevice]
                                                          Device:deviceInfo
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}


/**
 * postGetCapabilitiesDevice
 *
 * Creates a SktScanObject and initializes it to perform a request for the
 * Capabilities Device in the scanner.
 */
-(void)postGetCapabilitiesDevice:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdCapabilitiesDevice];
    [[scanObj Property]setType:kSktScanPropTypeByte];
    [[scanObj Property]setByte:kSktScanCapabilityLocalFunctions];// ask for the capabilities of the scanner

    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:[deviceInfo getSktScanDevice]
                                                          Device:deviceInfo
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postGetPostambleDevice
 *
 * Creates a SktScanObject and initializes it to perform a request for the
 * Postamble Device in the scanner.
 *
 */
-(void)postGetPostambleDevice:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdPostambleDevice];
    [[scanObj Property]setType:kSktScanPropTypeNone];

    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:[deviceInfo getSktScanDevice]
                                                          Device:deviceInfo
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}


/**
 * postSetPostamble
 *
 * Configure the postamble of the device
 * @param deviceInfo
 * @param postamble
 */
-(void)postSetPostambleDevice:(DeviceInfo*)deviceInfo Postamble:(NSString*)postamble Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdPostambleDevice];
    [[scanObj Property]setType:kSktScanPropTypeString];
    [[scanObj Property]setString:postamble];

    CommandContext* command=[[CommandContext alloc]initWithParam:FALSE
                                                         ScanObj:scanObj
                                                      ScanDevice:[deviceInfo getSktScanDevice]
                                                          Device:deviceInfo
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postGetSymbologyInfo
 *
 * Creates a SktScanObject and initializes it to perform a request for the
 * Symbology Info in the scanner.
 *
 */
-(void)postGetSymbologyInfo:(DeviceInfo*)deviceInfo SymbologyId:(int)symbologyId Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdSymbologyDevice];
    [[scanObj Property]setType:kSktScanPropTypeSymbology];
    [[[scanObj Property]Symbology]setID:(enum ESktScanSymbologyID)symbologyId];
    [[[scanObj Property]Symbology]setFlags:kSktScanSymbologyFlagStatus];

    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:[deviceInfo getSktScanDevice]
                                                          Device:deviceInfo
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postSetSymbologyInfo
 * Constructs a request object for setting the Symbology Info in the scanner
 *
 */
-(void)postSetSymbologyInfo:(DeviceInfo*)deviceInfo SymbologyId:(int)symbologyId Status:(BOOL)status Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdSymbologyDevice];
    [[scanObj Property]setType:kSktScanPropTypeSymbology];
    [[[scanObj Property]Symbology]setID:(enum ESktScanSymbologyID)symbologyId];
    [[[scanObj Property]Symbology]setFlags:kSktScanSymbologyFlagStatus];
    if(status==TRUE)
        [[[scanObj Property]Symbology]setStatus:kSktScanSymbologyStatusEnable];
    else
        [[[scanObj Property]Symbology]setStatus:kSktScanSymbologyStatusDisable];

    CommandContext* command=[[CommandContext alloc]initWithParam:FALSE
                                                         ScanObj:scanObj
                                                      ScanDevice:[deviceInfo getSktScanDevice]
                                                          Device:deviceInfo
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}


/**
 * postGetFriendlyName
 *
 * Creates a SktScanObject and initializes it to perform a request for the
 * friendly name in the scanner.
 *
 */
-(void)postGetFriendlyName:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdFriendlyNameDevice];
    [[scanObj Property]setType:kSktScanPropTypeNone];


    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:[deviceInfo getSktScanDevice]
                                                          Device:deviceInfo
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postSetFriendlyName
 * Constructs a request object for setting the Friendly Name in the scanner
 *
 */
-(void)postSetFriendlyName:(DeviceInfo*)deviceInfo FriendlyName:(NSString*)friendlyName Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdFriendlyNameDevice];
    [[scanObj Property]setType:kSktScanPropTypeString];
    [[scanObj Property]setString:friendlyName];

    CommandContext* command=[[CommandContext alloc]initWithParam:FALSE
                                                         ScanObj:scanObj
                                                      ScanDevice:[deviceInfo getSktScanDevice]
                                                          Device:deviceInfo
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postSetOverlayView
 *
 * Configure the Overlay view of softscan
 *
 * @param deviceInfo
 * @param decodeAction
 */
-(void)postSetOverlayView:(DeviceInfo*)deviceInfo OverlayView:(id)overlayview Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdOverlayViewDevice];
    [[scanObj Property]setType:kSktScanPropTypeObject];
    [[scanObj Property]setObject:overlayview];

    CommandContext* command=[[CommandContext alloc]initWithParam:FALSE
                                                         ScanObj:scanObj
                                                      ScanDevice:[deviceInfo getSktScanDevice]
                                                          Device:deviceInfo
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postSetTriggerDevice
 *
 * start scanning
 *
 * @param deviceInfo
 * @param decodeAction
 */
-(void)postSetTriggerDevice:(DeviceInfo*)deviceInfo Action:(unsigned char)action Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdTriggerDevice];
    [[scanObj Property]setType:kSktScanPropTypeByte];
    [[scanObj Property]setByte:action];

    CommandContext* command=[[CommandContext alloc]initWithParam:FALSE
                                                         ScanObj:scanObj
                                                      ScanDevice:[deviceInfo getSktScanDevice]
                                                          Device:deviceInfo
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

//#ifdef SCANAPI_HELPER_DATAEDITING
/**
 * postGetDataEditingProfiles
 *
 * Get the list of Data Editing profiles
 *
 */
-(void)postGetDataEditingProfiles:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdDataEditingProfile];
    [[scanObj Property]setType:kSktScanPropTypeNone];

    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:_scanApi
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postSetDataEditingProfiles
 *
 * Set the list of Data Editing profiles
 * This will add or remove profiles in function of
 * the current profiles list
 * @param profiles: semi colon separated list of the new profiles
 */
-(void)postSetDataEditingProfiles:(NSString*)profiles Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdDataEditingProfile];
    [[scanObj Property]setType:kSktScanPropTypeString];
    [[scanObj Property]setString:profiles];

    CommandContext* command=[[CommandContext alloc]initWithParam:FALSE
                                                         ScanObj:scanObj
                                                      ScanDevice:_scanApi
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postGetDataEditingCurrentProfile
 *
 * Get the Data Editing current profile
 *
 */
-(void)postGetDataEditingCurrentProfile:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdDataEditingCurrentProfile];
    [[scanObj Property]setType:kSktScanPropTypeNone];

    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:_scanApi
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postSetDataEditingCurrentProfile
 *
 * Set the Data Editing current profile
 *
 * @param profile: new current profile selected
 */
-(void)postSetDataEditingCurrentProfile:(NSString*)profile Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdDataEditingCurrentProfile];
    [[scanObj Property]setType:kSktScanPropTypeString];
    [[scanObj Property]setString:profile];

    CommandContext* command=[[CommandContext alloc]initWithParam:FALSE
                                                         ScanObj:scanObj
                                                      ScanDevice:_scanApi
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postGetDataEditingTriggerSymbology
 *
 * Get the Data Editing profile Trigger symbology list the
 * decoded data must come from
 *
 * @param profile to retrieve the trigger symbology list from
 */
-(void)postGetDataEditingTriggerSymbology:(NSString*)profile Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdDataEditingTriggerSymbologies];
    [[scanObj Property]setType:kSktScanPropTypeString];
    [[scanObj Property]setString:profile];

    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:_scanApi
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postSetDataEditingTriggerSymbology
 *
 * Set the Data Editing profile Trigger symbology list
 *
 * @param profile to set the trigger symbology list to
 */
-(void)postSetDataEditingTriggerSymbology:(NSString*)profileAndSymbology Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdDataEditingTriggerSymbologies];
    [[scanObj Property]setType:kSktScanPropTypeString];
    [[scanObj Property]setString:profileAndSymbology];

    CommandContext* command=[[CommandContext alloc]initWithParam:FALSE
                                                         ScanObj:scanObj
                                                      ScanDevice:_scanApi
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postGetDataEditingTriggerMinLength
 *
 * Get the Data Editing profile Trigger Minimum Length for the decoded Data
 *
 * @param profile to get the trigger minimum length
 */
-(void)postGetDataEditingTriggerMinLength:(NSString*)profile Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdDataEditingTriggerMinLength];
    [[scanObj Property]setType:kSktScanPropTypeString];
    [[scanObj Property]setString:profile];

    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:_scanApi
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postSetDataEditingTriggerMinLength
 *
 * Set the Data Editing profile Trigger Minimum Length for the decoded Data
 *
 * @param profileAndLength contains the profile and the minimum length in decimal
 */
-(void)postSetDataEditingTriggerMinLength:(NSString*)profileAndLength Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdDataEditingTriggerMinLength];
    [[scanObj Property]setType:kSktScanPropTypeString];
    [[scanObj Property]setString:profileAndLength];

    CommandContext* command=[[CommandContext alloc]initWithParam:FALSE
                                                         ScanObj:scanObj
                                                      ScanDevice:_scanApi
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postGetDataEditingTriggerMaxLength
 *
 * Get the Data Editing profile Trigger Maximum Length for the decoded Data
 *
 * @param profile to get the trigger maximum length
 */
-(void)postGetDataEditingTriggerMaxLength:(NSString*)profile Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdDataEditingTriggerMaxLength];
    [[scanObj Property]setType:kSktScanPropTypeString];
    [[scanObj Property]setString:profile];

    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:_scanApi
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postSetDataEditingTriggerMaxLength
 *
 * Set the Data Editing profile Trigger Maximum Length for the decoded Data
 *
 * @param profileAndLength contains the profile and the maximum length in decimal
 */
-(void)postSetDataEditingTriggerMaxLength:(NSString*)profileAndLength Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdDataEditingTriggerMaxLength];
    [[scanObj Property]setType:kSktScanPropTypeString];
    [[scanObj Property]setString:profileAndLength];

    CommandContext* command=[[CommandContext alloc]initWithParam:FALSE
                                                         ScanObj:scanObj
                                                      ScanDevice:_scanApi
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postGetDataEditingTriggerStartsBy
 *
 * Get the Data Editing profile Trigger Starts by string for the decoded Data
 *
 * @param profile to retrieve the trigger Starts by
 */
-(void)postGetDataEditingTriggerStartsBy:(NSString*)profile Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdDataEditingTriggerStartsBy];
    [[scanObj Property]setType:kSktScanPropTypeString];
    [[scanObj Property]setString:profile];

    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:_scanApi
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postSetDataEditingTriggerStartsBy
 *
 * Set the Data Editing profile Trigger Starts by string for the decoded Data
 *
 * @param profileAndString contains the profile and Starts by string
 */
-(void)postSetDataEditingTriggerStartsBy:(NSString*)profileAndString Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdDataEditingTriggerStartsBy];
    [[scanObj Property]setType:kSktScanPropTypeString];
    [[scanObj Property]setString:profileAndString];

    CommandContext* command=[[CommandContext alloc]initWithParam:FALSE
                                                         ScanObj:scanObj
                                                      ScanDevice:_scanApi
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postGetDataEditingTriggerEndsWith
 *
 * Get the Data Editing profile Trigger Ends with string for the decoded Data
 *
 * @param profile to retrieve the trigger Ends with
 */
-(void)postGetDataEditingTriggerEndsWith:(NSString*)profile Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdDataEditingTriggerEndsWith];
    [[scanObj Property]setType:kSktScanPropTypeString];
    [[scanObj Property]setString:profile];

    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:_scanApi
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postSetDataEditingTriggerEndsWith
 *
 * Set the Data Editing profile Trigger Ends with string for the decoded Data
 *
 * @param profileAndString contains the profile and the Ends With string
 */
-(void)postSetDataEditingTriggerEndsWith:(NSString*)profileAndString Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdDataEditingTriggerEndsWith];
    [[scanObj Property]setType:kSktScanPropTypeString];
    [[scanObj Property]setString:profileAndString];

    CommandContext* command=[[CommandContext alloc]initWithParam:FALSE
                                                         ScanObj:scanObj
                                                      ScanDevice:_scanApi
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postGetDataEditingTriggerContains
 *
 * Get the Data Editing profile Trigger Contains a string for the decoded Data
 *
 * @param profile to retrieve the trigger Contains string
 */
-(void)postGetDataEditingTriggerContains:(NSString*)profile Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdDataEditingTriggerContains];
    [[scanObj Property]setType:kSktScanPropTypeString];
    [[scanObj Property]setString:profile];

    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:_scanApi
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postSetDataEditingTriggerContains
 *
 * Set the Data Editing profile Trigger Contains a string for the decoded Data
 *
 * @param profileAndString contains the profile and the Contains string
 */
-(void)postSetDataEditingTriggerContains:(NSString*)profileAndString Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdDataEditingTriggerContains];
    [[scanObj Property]setType:kSktScanPropTypeString];
    [[scanObj Property]setString:profileAndString];

    CommandContext* command=[[CommandContext alloc]initWithParam:FALSE
                                                         ScanObj:scanObj
                                                      ScanDevice:_scanApi
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}


/**
 * postGetDataEditingOperations
 *
 * Get the Data Editing profile Operations applied to the decoded Data
 *
 * @param profile to retrieve the operations from
 */
-(void)postGetDataEditingOperations:(NSString*)profile Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdDataEditingOperation];
    [[scanObj Property]setType:kSktScanPropTypeString];
    [[scanObj Property]setString:profile];

    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:_scanApi
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postSetDataEditingOperations
 *
 * Set the Data Editing profile Operations applied to the decoded Data
 *
 * @param profileAndOperation contains the profile and the operation to set to
 */
-(void)postSetDataEditingOperations:(NSString*)profileAndOperations Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdDataEditingOperation];
    [[scanObj Property]setType:kSktScanPropTypeString];
    [[scanObj Property]setString:profileAndOperations];

    CommandContext* command=[[CommandContext alloc]initWithParam:FALSE
                                                         ScanObj:scanObj
                                                      ScanDevice:_scanApi
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postGetDataEditingExport
 *
 * Export the Data Editing profile
 *
 * @param profile to export
 */
-(void)postGetDataEditingExport:(NSString*)profile Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdDataEditingImportExport];
    [[scanObj Property]setType:kSktScanPropTypeString];
    [[scanObj Property]setString:profile];

    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:_scanApi
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postSetDataEditingImport
 *
 * Import the Data Editing profile
 *
 * @param profile to Import from
 */
-(void)postSetDataEditingImport:(NSString*)profile Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdDataEditingImportExport];
    [[scanObj Property]setType:kSktScanPropTypeString];
    [[scanObj Property]setString:profile];

    CommandContext* command=[[CommandContext alloc]initWithParam:FALSE
                                                         ScanObj:scanObj
                                                      ScanDevice:_scanApi
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postSetNotificationsForDevice
 *
 * Configure the Device Notifications
 *
 * @param deviceInfo: device to configure the notifications
 * @param forNotifications: notifications to receive
 */
-(void)postSetNotificationsForDevice:(DeviceInfo*)deviceInfo forNotifications:(int)notifications Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdNotificationsDevice];
    [[scanObj Property]setType:kSktScanPropTypeUlong];
    [[scanObj Property]setUlong:(unsigned long)notifications];

    CommandContext* command=[[CommandContext alloc]initWithParam:FALSE
                                                         ScanObj:scanObj
                                                      ScanDevice:[deviceInfo getSktScanDevice]
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postGetNotificationsFromDevice
 *
 * Retrieve the Device Notifications
 *
 * @param deviceInfo: device to configure the notifications
 */
-(void)postGetNotificationsFromDevice:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdNotificationsDevice];
    [[scanObj Property]setType:kSktScanPropTypeNone];

    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:[deviceInfo getSktScanDevice]
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postGetPowerStateFromDevice
 *
 * Retrieve the Device Power State
 *
 * @param deviceInfo: device to retrieve the power state from
 */
-(void)postGetPowerStateFromDevice:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdPowerStateDevice];
    [[scanObj Property]setType:kSktScanPropTypeNone];

    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:[deviceInfo getSktScanDevice]
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postGetButtonsStateFromDevice
 *
 * Retrieve the Device Buttons State
 *
 * @param deviceInfo: device to retrieve the buttons state from
 */
-(void)postGetButtonsStateFromDevice:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdButtonsStatusDevice];
    [[scanObj Property]setType:kSktScanPropTypeNone];

    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:[deviceInfo getSktScanDevice]
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postGetButtonsStateFromDevice
 *
 * Retrieve the Device Battery Level
 *
 * @param deviceInfo: device to retrieve the battery level from
 */
-(void)postGetBatteryLevelFromDevice:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdBatteryLevelDevice];
    [[scanObj Property]setType:kSktScanPropTypeNone];

    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:[deviceInfo getSktScanDevice]
                                                          Device:nil
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif
}

/**
 * postGetDeviceSpecific
 *
 * post a command specific to a certain type of scanner
 * The command is usually a series of bytes that are understandable only
 * by one particular type of scanner therefore the type of scanner must be
 * checked prior calling this method
 *
 * @param deviceInfo to send the command to
 * @param pCommand pointer to the bytes to send to the device
 * @param length of the command in bytes
 * @param target main object receiving the response
 * @param response selector invoked when the response is received
 */
-(void)postGetDeviceSpecific:(DeviceInfo*)deviceInfo Command:(unsigned char*)pCommand Length:(int) length Target:(id)target Response:(SEL) response{
    ISktScanObject*scanObj=[SktClassFactory createScanObject];
    [[scanObj Property]setID:kSktScanPropIdDeviceSpecific];
    [[scanObj Property]setType:kSktScanPropTypeArray];
    [[scanObj Property]setArray:pCommand Length:length];
    CommandContext* command=[[CommandContext alloc]initWithParam:TRUE
                                                         ScanObj:scanObj
                                                      ScanDevice:[deviceInfo getSktScanDevice]
                                                          Device:deviceInfo
                                                          Target:target
                                                        Response:response];

    [self addCommand:command];
#if __has_feature(objc_arc)
#else
    [command release];
#endif

}


//#endif // SCANAPI_HELPER_DATAEDITING


/**
 addCommand

 add a command context into the list
 */
-(void)addCommand:(CommandContext*)command{
    if(_commandContexts==nil)
        _commandContexts=[[NSMutableArray alloc]init];

    @synchronized(_commandContextsLock){

        if([[[command getScanObject]Property]getID]==kSktScanPropIdAbort)
            [_commandContexts removeAllObjects];

        [_commandContexts addObject:command];
    }
}

/**
 initializeScanAPIThread
 This is a thread for creating and opening the first
 instance of ScanAPI which causes ScanAPI to initialize
 itself. This might be a lengthy operation which is why
 it is done in a thread.
 */
-(void) initializeScanAPIThread:(id)arg{
#if __has_feature(objc_arc)
    @autoreleasepool {
#else
   NSAutoreleasePool* pool=[[NSAutoreleasePool alloc]init];
#endif
    // release the previous ScanAPI object instance if
    // it exists
//    if(_scanApi!=nil){
//        [_scanApi close];
//        [SktClassFactory releaseScanApiInstance:_scanApi];
//    }
    _scanApi=[SktClassFactory createScanApiInstance];
    SKTRESULT result=[_scanApi open:nil];
        id localDelegate = _delegate;
        if((localDelegate!=nil)&&([localDelegate respondsToSelector:@selector(onScanApiInitializeComplete:)])){
            dispatch_async(dispatch_get_main_queue(), ^{
                [localDelegate onScanApiInitializeComplete:result];
            });
        }
    _scanApiTerminated=FALSE;

#if __has_feature(objc_arc)
    }
#else
    [pool drain];
#endif
}

/**
 * doScanApiReceive
 *
 * Call this function from your timer routine, so it
 * will consume ScanAPI asyncrhonous event
 *
 * This function should be called after initializing
 * ScanAPI by calling ScanApiHelper open function
 * which will call the onScanApiInitializeComplete delegate
 *
 * IF THIS FUNCTION IS NOT CALLED, YOU WON'T RECEIVE
 * ANY ASYNCHRONOUS EVENT FROM SCANAPI
 */
-(SKTRESULT)doScanApiReceive{
    SKTRESULT result=ESKT_NOERROR;
    BOOL closeScanApi=FALSE;
    if(_scanApiTerminated==FALSE){
        result=[_scanApi waitForScanObject:_scanObjectReceived TimeOut:1];
        if(SKTSUCCESS(result)){
            if(result!=ESKT_WAITTIMEOUT){
                closeScanApi=[self handleScanObject:_scanObjectReceived];
                [_scanApi releaseScanObject:_scanObjectReceived];
            }
            else{
                // see if there is a command to send
                result=[self sendNextCommand];
            }
            if(closeScanApi==TRUE){
                // we won't receive any scanObject from ScanAPI anymore
                // so we can release the scanObject instance here
                [SktClassFactory releaseScanObject:_scanObjectReceived];
                _scanObjectReceived=nil;

                [_scanApi close];
                [SktClassFactory releaseScanApiInstance:_scanApi];
                _scanApi=nil;
                _scanApiTerminated=TRUE;
            }
        }
        else{
            if((_delegate!=nil)&&([_delegate respondsToSelector:@selector(onErrorRetrievingScanObject:)])){
                [_delegate onErrorRetrievingScanObject:result];
            }
        }
    }
    return result;
}

/**
 * handleScanObject
 *
 * Call this function from your timer routine, so it
 * will consume ScanAPI asyncrhonous event
 */
-(BOOL)handleScanObject:(ISktScanObject*)scanObj{
    BOOL closeScanApi=FALSE;
    SKTRESULT result=ESKT_NOERROR;
    switch([[scanObj Msg]MsgID]){
        case kSktScanMsgIdDeviceArrival:
            result=[self handleDeviceArrival:scanObj];
            break;
        case kSktScanMsgIdDeviceRemoval:
            result=[self handleDeviceRemoval:scanObj];
            break;
        case kSktScanMsgIdTerminate:
            if((_delegate!=nil)&&([_delegate respondsToSelector:@selector(onScanApiTerminated)])){
                [_delegate onScanApiTerminated];
            }
            closeScanApi=TRUE;
            break;
        case kSktScanMsgSetComplete:
        case kSktScanMsgGetComplete:
            result=[self handleSetOrGetComplete:scanObj];
            break;
        case kSktScanMsgEvent:
            result=[self handleEvent:scanObj];
            break;
        case kSktScanMsgIdNotInitialized:
        case kSktScanMsgLastID:
        default:
            break;
    }

    // if there is an error then report it to the ScanAPIHelper user
    if(!SKTSUCCESS(result)){
        if((_delegate!=nil)&&([_delegate respondsToSelector:@selector(onError:)])){
            [_delegate onError:result];
        }
    }
    return closeScanApi;
}

/**
 * handleDeviceArrival
 * This is called when a scanner connects to the host.
 *
 * This function create a new DeviceInfo object and add it
 * to the list and open the scanner so that it is ready to be
 * used, and then notify the ScanApiHelper user a new
 * scanner has connected
 */
-(SKTRESULT)handleDeviceArrival:(ISktScanObject*)scanObj{
    SKTRESULT result=ESKT_NOERROR;
    ISktScanDevice* scanDevice=[SktClassFactory createDeviceInstance:_scanApi];
    NSString* name=[[scanObj Msg]DeviceName];
    NSString* guid=[[scanObj Msg]DeviceGuid];
    long type=[[scanObj Msg]DeviceType];

    // create a new DeviceInfo object
    DeviceInfo* deviceInfo=[[DeviceInfo alloc]init:scanDevice name:name type:type];

    // open the scanner which means that we can now receive
    // any event (such as DecodedData event) from this scanner
    result=[scanDevice open:guid];

    if(SKTSUCCESS(result)){
        if(_noDeviceText!=nil)
            [_deviceInfoList removeObjectForKey:_noDeviceText];

        // add the device info into the list
        [_deviceInfoList setValue:deviceInfo forKey:[NSString stringWithFormat:@"%@",scanDevice]];
    }

    // notify the ScanApiHelper user a scanner has connected to this host
    if((_delegate!=nil)&&([_delegate respondsToSelector:@selector(onDeviceArrival:device:)])){
        [_delegate onDeviceArrival:result device:deviceInfo];
    }

#if __has_feature(objc_arc)
#else
    [deviceInfo release];// we don't keep this object since we couldn't open the scanner
#endif
    return result;
}


/**
 * handleDeviceRemoval
 * This function is called when a scanner disconnects or
 * when ScanAPI is shutting down after the Abort property has been set
 *
 * This function remove the device info from the list and notify
 * the ScanApiHelper user that a scanner has been disconnected
 * All the pending commands for this scanner are removed from the list.
 */
-(SKTRESULT)handleDeviceRemoval:(ISktScanObject*)scanObj{
    SKTRESULT result=ESKT_NOERROR;
    ISktScanDevice* scanDevice=[[scanObj Msg]hDevice];

    // retrieve the DeviceInfo object from the list
    DeviceInfo* deviceInfo=[self getDeviceInfoFromScanObject:scanObj];

    // if there is a text provided when no device is connected
    // then if the list is empty that's the time to add this text in the list
    if(_noDeviceText!=nil){
        if([_deviceInfoList count]==0)
            [_deviceInfoList setObject:_noDeviceText forKey:_noDeviceText];
    }

    // remove all the pending commands from the list for this scanner
    [self removeCommand:deviceInfo];

    [_deviceInfoList setValue:nil forKey:[NSString stringWithFormat:@"%@",scanDevice]];
    //[_deviceInfoList removeAllObjects];

    // close the scanner and release its instance
    result=[scanDevice close];
    [SktClassFactory releaseDeviceInstance:scanDevice];

    // notify the ScanApiHelper user a scanner has connected to this host
    if((_delegate!=nil)&&([_delegate respondsToSelector:@selector(onDeviceRemoval:)])){
        [_delegate onDeviceRemoval:deviceInfo];
    }

    return result;
}

/**
 * handleSetOrGetComplete
 *
 * handles both Set or Get complete property events
 *
 */
-(SKTRESULT)handleSetOrGetComplete:(ISktScanObject*)scanObj{
    SKTRESULT result=ESKT_NOERROR;
    BOOL doCallback=TRUE;
    // retrieve the error for this complete event
    result=[[scanObj Msg]Result];
    CommandContext* commandContext=(CommandContext*)[[scanObj Property]getContext];

    if(commandContext!=nil){
        // only if there is a timeout error then retry the command
        if(!SKTSUCCESS(result)){
            if(result==ESKT_REQUESTTIMEDOUT){
                if([commandContext retry]<CMD_MAX_RETRY){
                    doCallback=FALSE;// just retry without calling the command callback
                }
            }
        }

        if(doCallback==TRUE){
            // the result will be NO_ERROR if the callback has been called
            // and will be whatever result code we have in ScanObject if
            // there is no callback
            [commandContext doCallback:scanObj];
            @synchronized(_commandContextsLock){
                [_commandContexts removeObject:commandContext];
            }
            // the release has been done in the removeObject method
            commandContext=nil;
        }
        else
            [commandContext setStatus:statusReady];

    }

    // send the next command if there is one
    result=[self sendNextCommand];

    return result;
}

/**
 * handleEvent
 *
 * handles all events received from ScanAPI
 *
 */
-(SKTRESULT)handleEvent:(ISktScanObject*)scanObj{
    SKTRESULT result=ESKT_NOERROR;
    switch([[[scanObj Msg]Event]ID]){
        case kSktScanEventDecodedData:
            result=[self handleDecodedData:scanObj];
            break;
        case kSktScanEventError:
            if((_delegate!=nil)&&([_delegate respondsToSelector:@selector(onError:)]))
                [_delegate onError:[[scanObj Msg]Result]];
            break;

        case kSktScanEventListenerStarted:
            break;
        case kSktScanEventPower:
            result=[self handleEventPower:scanObj];
            break;
        case kSktScanEventButtons:
            result=[self handleEventButtons:scanObj];
            break;
        case kSktScanEventBatteryLevel:
            result=[self handleEventBatteryLevel:scanObj];
            break;
        case kSktScanEventLastID:
        default:
            break;
    }
    return result;
}
/**
 * handleDecodedData
 *
 * call the delegate with decoded data
 */
-(SKTRESULT)handleDecodedData:(ISktScanObject*)scanObj{
    SKTRESULT result=ESKT_NOERROR;
    result=[[scanObj Msg]Result];
    DeviceInfo* deviceInfo=[self getDeviceInfoFromScanObject:scanObj];
    if(_delegate!=nil){
        if([_delegate respondsToSelector:@selector(onDecodedDataResult:device:decodedData:)]==YES){
            [_delegate onDecodedDataResult:result device:deviceInfo decodedData:[[[scanObj Msg]Event]getDataDecodedData]];
        }
        else{
            // call only in case of no error the legacy onDecodedData:
            if(SKTSUCCESS(result)){
                if([_delegate respondsToSelector:@selector(onDecodedData:decodedData:)]==YES){
                    [_delegate onDecodedData:deviceInfo decodedData:[[[scanObj Msg]Event]getDataDecodedData]];
                }
            }
        }
    }
    // in case the user cancel the softscan
    // we don't want to report this as an error
    if(result==ESKT_CANCEL)
        result=ESKT_NOERROR;
    return result;
}

/**
 * handleEventPower
 *
 */
-(SKTRESULT)handleEventPower:(ISktScanObject*)scanObj{
    SKTRESULT result=ESKT_NOERROR;
    result=[[scanObj Msg]Result];
    DeviceInfo* deviceInfo=[self getDeviceInfoFromScanObject:scanObj];
    if(_delegate!=nil){
        if([_delegate respondsToSelector:@selector(onEventPowerResult:device:power:)]==YES){
            [_delegate onEventPowerResult:result device:deviceInfo power:[[[scanObj Msg]Event]getDataLong]];
        }
    }
    return result;
}

/**
 * handleEventButtons
 *
 */
-(SKTRESULT)handleEventButtons:(ISktScanObject*)scanObj{
    SKTRESULT result=ESKT_NOERROR;
    result=[[scanObj Msg]Result];
    DeviceInfo* deviceInfo=[self getDeviceInfoFromScanObject:scanObj];
    if(_delegate!=nil){
        if([_delegate respondsToSelector:@selector(onEventButtonsResult:device:buttons:)]==YES){
            [_delegate onEventButtonsResult:result device:deviceInfo buttons:[[[scanObj Msg]Event]getDataLong]];
        }
    }
    return result;
}

/**
 * handleEventBatteryLevel
 *
 */
-(SKTRESULT)handleEventBatteryLevel:(ISktScanObject*)scanObj{
    SKTRESULT result=ESKT_NOERROR;
    result=[[scanObj Msg]Result];
    DeviceInfo* deviceInfo=[self getDeviceInfoFromScanObject:scanObj];
    if(_delegate!=nil){
        if([_delegate respondsToSelector:@selector(onEventBatteryLevelResult:device:batteryLevel:)]==YES){
            [_delegate onEventBatteryLevelResult:result device:deviceInfo batteryLevel:[[[scanObj Msg]Event]getDataLong]];
        }
    }
    return result;
}


/**
 * sendNextCommand
 *
 * sends the next command if there is one in the list
 */
-(SKTRESULT)sendNextCommand{
    SKTRESULT result=ESKT_NOERROR;
    @synchronized(_commandContextsLock){
        ISktScanDevice* lastDevice=nil;
        int count=(int)[_commandContexts count];
        if(count>0){
            for(int i=0;i<count;i++){
                CommandContext* newCommand=[_commandContexts objectAtIndex:i];
                if([newCommand status]==statusReady){
                    result=[newCommand doCommand];
                    if(!SKTSUCCESS(result)){
                        ISktScanDevice*currentDevice=[newCommand getScanDevice];
                        NSLog(@"Remove the command/property because we failed to send it");
                        [_commandContexts removeObject:newCommand];
                        i--;// the current command has been removed so stay at the same index
                        count--;
                        // the release has been done in the removeObject method
                        newCommand=nil;
                        // if there is an error and the last device
                        // we reported an error is not this one then
                        // report the error to the app. This is to
                        // avoid reporting multiple time an error because
                        // a particular device might be disconnected
                        if((_delegate!=nil)&&(lastDevice!=currentDevice)){
                            [_delegate onError:result];// report an error but continue
                            lastDevice=currentDevice;
                        }

                    }
                    else{
                        // set the flag to void the podDelegate if SoftScan is
                        // triggered, which cause the current view to dissappear
                        // and in that case that view still needs to handle the
                        // ScanApiHelper notifications in order to receive the
                        // decoded data from SoftScan
                        if([[[newCommand getScanObject] Property] getID] == kSktScanPropIdTriggerDevice){
                            if([[[newCommand getDeviceInfo] getTypeString] isEqualToString: @"SoftScan"]){
                                _softScanTrigger = true;
                            }
                        }
                        break;
                    }
                }
                else
                    break;
            }
        }
    }
    return result;
}

/**
 *  generateDeviceArrivals
 *
 *  internal function to generate device
 *  arrival notifications when the delegate
 *  change to a new delegate.
 *  This is used in a multi views application
 *  that has more than one view to receive the
 *  decoded data
 */
-(void)generateDeviceArrivals{
    // generate a device Arrival for each scanner we've already receive
    // so that the new view can be aware of the connected scanners
    if(_delegate!=nil && [_delegate respondsToSelector:@selector(onDeviceArrival:device:)]){
        for (NSString* key in _deviceInfoList) {
            DeviceInfo* device=[_deviceInfoList objectForKey:key];
            [_delegate onDeviceArrival:ESKT_NOERROR device:device];
        }
    }
}

@end
