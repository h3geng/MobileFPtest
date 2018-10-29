//
//  ScanApiHelper.h
//  ScannerSettings
//
//  Created by Eric Glaenzer on 7/29/11.
//  Copyright 2011 Socket Mobile, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScanApiIncludes.h"

#import "DeviceInfo.h"

@class ISktScanObject;
@class ISktScanDevice;
@class ISktScanDecodedData;
@class ISktScanApi;

#define CMD_MAX_RETRY 3 // maximum retry for a command

/**
 * CommandContextDelegate
 * Each time a property command has completed,
 * this optional delegate will be called so
 * the ScanApiHelper user can either refresh the UI
 * with a property response and/or ask for another
 * property
 */
@protocol CommandContextDelegate <NSObject>
-(void)run:(ISktScanObject*)scanObj;
@end

@interface CommandContext : NSObject{
    id _target;
    SEL _response;
    enum eStatus{
        statusReady=1,
        statusNotCompleted,
        statusCompleted
    }status;
    BOOL _getOperation;
    ISktScanObject* _scanObj;
    ISktScanDevice* _device;
    DeviceInfo* _deviceInfo;
    int _symbologyId;
    int retry;
}

@property (nonatomic,readwrite)int retry;
@property (nonatomic,readwrite)enum eStatus status;

-(id)initWithParam:(BOOL)getOperation
           ScanObj:(ISktScanObject*)scanObj
        ScanDevice:(ISktScanDevice*)scanDevice
            Device:(DeviceInfo*)device
            Target:(id)target
          Response:(SEL)response;
-(void)dealloc;

-(ISktScanDevice*)getScanDevice;
-(ISktScanObject*)getScanObject;
-(DeviceInfo*)getDeviceInfo;
-(SKTRESULT)doCallback:(ISktScanObject*)scanObj;
-(SKTRESULT)doCommand;
@end

@protocol ScanApiHelperDelegate <NSObject>
@optional
/**
 * called each time a device connects to the host
 * @param result contains the result of the connection
 * @param deviceInfo contains the device information
 */
-(void)onDeviceArrival:(SKTRESULT)result device:(DeviceInfo*)deviceInfo;

/**
 * called each time a device disconnect from the host
 * @param deviceRemoved contains the device information
 */
-(void) onDeviceRemoval:(DeviceInfo*) deviceRemoved;

/**
 * called each time ScanAPI is reporting an error
 * @param result contains the error code
 */
-(void) onError:(SKTRESULT) result;

/**
 * called when ScanAPI initialization has been completed
 * @param result contains the initialization result
 */
-(void) onScanApiInitializeComplete:(SKTRESULT) result;

/**
 * called when ScanAPI has been terminated. This will be
 * the last message received from ScanAPI
 */
-(void) onScanApiTerminated;

/**
 * called when an error occurs during the retrieval
 * of a ScanObject from ScanAPI.
 * @param result contains the retrieval error code
 */
-(void) onErrorRetrievingScanObject:(SKTRESULT) result;

/**
 * called each time ScanAPI receives decoded data from scanner
 * @param result is ESKT_NOERROR when decodedData contains actual
 * decoded data. The result can be set to ESKT_CANCEL when the
 * end-user cancels a SoftScan operation
 * @param device contains the device information from which
 * the data has been decoded
 * @param decodedData contains the decoded data information
 */
-(void) onDecodedDataResult:(long) result device:(DeviceInfo*) device decodedData:(ISktScanDecodedData*) decodedData;

// THIS IS THE PREVIOUS onDecodedData THAT WE KEEP FOR BACKWARD
// COMPATIBILITY BUT THE BEST IS TO USE onDecodedDataResult THAT
// PROVIDES A RESULT FIELD THAT COULD BE SET TO ESKT_CANCEL WHEN
// THE END-USER CANCELS A SOFTSCAN OPERATION
/**
 * called each time ScanAPI receives decoded data from scanner
 * @param device contains the device information from which
 * the data has been decoded
 * @param decodedData contains the decoded data information
 */
-(void) onDecodedData:(DeviceInfo*) device decodedData:(ISktScanDecodedData*) decodedData;

/**
 * called each time the device power state changes, from Battery to AC by example.
 * The notification parameter contains the state of the device power.
 *
 * Values:
 * kSktScanPowerStatusUnknown=		0x00,
 * kSktScanPowerStatusOnBattery=	0x01,
 * kSktScanPowerStatusOnCradle=     0x02,
 * kSktScanPowerStatusOnAc=         0x04
 *
 */
-(void) onEventPowerResult:(long)result device:(DeviceInfo*) deviceInfo power:(int)powerResult;

/**
 * called each time the device buttons state changes depending on the button notifications
 * configuration. This configuration indicates when this event is triggered.
 * The buttonState actually contains the state of all the buttons at the time the event is triggered.
 *
 * The buttonState is a bitmask for each buttons:
 * Bit 0 : Left Button state: 0 released, 1 press
 * Bit 1 : Right Button state: 0 release, 1 press
 * Bit 2 : Middle Button state: 0 release, 1 press
 * Bit 3 : Power Button state: 0 release, 1 press
 * Bit 4 : Ring Detached state: 0 connected, 1 detached (CRS Ring Scanner only)
 */
-(void) onEventButtonsResult:(long)result device:(DeviceInfo*) deviceInfo buttons:(int)buttonState;

/**
 * called each time the device battery level changes.
 * The notification parameter contains the level of the device battery including the range min and max.
 * Most of the scanners report a range from 0 to 100, where the value can then be expressed in percentile.
 *
 */
-(void) onEventBatteryLevelResult:(long)result device:(DeviceInfo*) deviceInfo batteryLevel:(int)battery;
@end


/**
 * this class provides a set of common functions to retrieve
 * or configure a scanner or ScanAPI and to receive decoded
 * data from a scanner.<p>
 * This helper manages a commands list so the application
 * can send multiple command in a row, the helper will send
 * them one at a time. Each command has an optional callback
 * function that will be called each time a command complete.
 * By example, to get a device friendly name, use the
 * PostGetFriendlyName method and pass a callback function in
 * which you can update the UI with the newly fetched friendly
 * name. This operation will be completely asynchronous.<p>
 * ScanAPI Helper manages a list of device information. Most of
 * the time only one device is connected to the host. This list
 * could be configured to have always one item, that will be a
 * "No device connected" item in the case where there is no device
 * connected, or simply a device name when there is one device
 * connected. Use isDeviceConnected method to know if there is at
 * least one device connected to the host.<br>
 * Common usage scenario of ScanAPIHelper:<br>
 * <li> create an instance of ScanApiHelper: _scanApi=new ScanApiHelper();
 * <li> [optional] if a UI device list is used a no device connected
 * string can be specified:_scanApi.setNoDeviceText(getString(R.string.no_device_connected));
 * <li> register for notification: _scanApi.setDelegate(_scanApiNotification);
 * <li> derive from ScanApiHelperNotification to handle the notifications coming
 * from ScanAPI including "Device Arrival", "Device Removal", "Decoded Data" etc...
 * <li> open ScanAPI to start using it:_scanApi.open();
 * <li> check the ScanAPI initialization result in the notifications:
 * _scanApiNotification.onScanApiInitializeComplete(long result){}
 * <li> monitor a scanner connection by using the notifications:
 * _scanApiNotification.onDeviceArrival(long result,DeviceInfo newDevice){}
 * _scanApiNotification.onDeviceRemoval(DeviceInfo deviceRemoved){}
 * <li> retrieve the decoded data from a scanner
 * _scanApiNotification.onDecodedData(DeviceInfo device,ISktScanDecodedData decodedData){}
 * <li> once the application is done using ScanAPI, close it using:
 * _scanApi.close();
 * @author ericg
 *
 */
@interface ScanApiHelper : NSObject {
    id<ScanApiHelperDelegate> _delegate;
    NSString* _noDeviceText;// text to display when no device is connected
    NSMutableDictionary* _deviceInfoList;// list of device info
    BOOL _scanApiOpen;
    BOOL _scanApiTerminated;
    NSMutableArray* _commandContexts;
    ISktScanApi* _scanApi;
    ISktScanObject*_scanObjectReceived;
    NSObject* _commandContextsLock;
    NSMutableArray* _delegateStack;
}

+(ScanApiHelper*)sharedScanApiHelper;

-(void)pushDelegate:(id<ScanApiHelperDelegate>)delegate;
-(void)popDelegate:(id<ScanApiHelperDelegate>)delegate;

/**
 * register for notifications in order to receive notifications such as
 * "Device Arrival", "Device Removal", "Decoded Data"...etc...
 * @param delegate is the delegate
 */
-(void)setDelegate:(id<ScanApiHelperDelegate>)delegate;

/**
 * specifying a name to display when no device is connected
 * will add a no device connected item in the list with
 * the name specified, otherwise if there is no device connected
 * the list will be empty.
 */
-(void)setNoDeviceText:(NSString*) noDeviceText;

/**
 * get the list of devices. If there is no device
 * connected and a text has been specified for
 * when there is no device then the list will
 * contain one item which is the no device in the
 * list
 * @return a result
 */
-(NSDictionary*) getDevicesList;

/**
 * get a DeviceInfo object from a ScanObject received by ScanAPI.
 *
 * If no DeviceInfo matches, this method returns nil
 * @param scanObj ScanObject received by ScanAPI that contains the
 * device information.
 *
 * @return a device info instance or nil if no device info in the list
 * matches to the ScanObj device information.
 */
-(DeviceInfo*) getDeviceInfoFromScanObject:(ISktScanObject*)scanObj;

/**
 * check if there is a device connected
 * @return a result
 */
-(BOOL) isDeviceConnected;

/**
 * flag to know if ScanAPI is open
 * @return a result
 */
-(BOOL)isScanApiOpen;


/**
 * open ScanAPI and initialize ScanAPI
 * The result of opening ScanAPI is returned in the callback
 * onScanApiInitializeComplete
 */
-(void)open;

/**
 * close ScanAPI. The callback onScanApiTerminated
 * is invoked as soon as ScanAPI is completely closed.
 * If a device is connected, a device removal will be received
 * during the process of closing ScanAPI.
 */
-(void)close;

/**
 * Check and consume asynchronous event from ScanAPI.
 * Typically this message could be called from a timer
 * handler
 */
-(SKTRESULT)doScanApiReceive;

/**
 * remove the pending commands for a specific device
 * or all the pending commands if null is passed as
 * iDevice parameter
 * @param deviceInfo reference to the device for which
 * the commands must be removed from the list or <b>null</b>
 * if all the commands must be removed.
 */
-(void)removeCommand:(DeviceInfo*)deviceInfo;


/**
 * postGetScanAPIVersion
 * retrieve the ScanAPI Version
 */
-(void)postGetScanApiVersion:(id)target Response:(SEL)response;


/**
 * postSetConfirmationMode
 * Configures ScanAPI so that scanned data must be confirmed by this application before the
 * scanner can be triggered again.
 */
-(void)postSetConfirmationMode:(unsigned char)mode Target:(id)target Response:(SEL)response;


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
-(void)postScanApiAbort:(id)target Response:(SEL)response;

/**
 * postSetDataConfirmation
 * acknowledge the decoded data<p>
 * This is only required if the scanner Confirmation Mode is set to kSktScanDataConfirmationModeApp
 */
-(void)postSetDataConfirmation:(DeviceInfo*)deviceInfo goodData:(BOOL) good Target:(id)target Response:(SEL)response;

/**
 * postSetSoftScanStatus
 * enable or disable the softscan feature.
 */
-(void)postSetSoftScanStatus:(unsigned char)action Target:(id)target Response:(SEL)response;

/**
 * postGetSoftScanStatus
 * Retrieve the status of the softscan feature.
 */
-(void)postGetSoftScanStatus:(id)target Response:(SEL)response;

/**
 * postGetBtAddress
 * Creates a SktScanObject and initializes it to perform a request for the
 * Bluetooth address in the scanner.
 */
-(void)postGetBtAddress:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response;

/**
 * postGetDeviceType
 * Creates a SktScanObject and initializes it to perform a request for the
 * device type of the scanner.
 */
-(void)postGetDeviceType:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response;

/**
 * postGetFirmwareVersion
 * Creates a SktScanObject and initializes it to perform a request for the
 * firmware revision in the scanner.
 */
-(void)postGetFirmwareVersion:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response;


/**
 * postGetBattery
 * Creates a SktScanObject and initializes it to perform a request for the
 * battery level in the scanner.
 */
-(void)postGetBattery:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response;

/**
 * postGetStandConfig
 * Creates a SktScanObject and initializes it to perform a request for the
 * stand config of the scanner.
 */
-(void)postGetStandConfig:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response;

/**
 * postSetStandConfig
 * Creates a SktScanObject and initializes it to perform a request for changing the
 * stand config of the scanner.
 */
-(void)postSetStandConfig:(DeviceInfo*)deviceInfo StandConfig:(long) standConfig Target:(id)target Response:(SEL)response;

/**
 * postGetDecodeActionDevice
 *
 * Creates a TSktScanObject and initializes it to perform a request for the
 * Decode Action in the scanner.
 *
 */
-(void)postGetDecodeActionDevice:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response;

/**
 * postGetCapabilitiesDevice
 *
 * Creates a SktScanObject and initializes it to perform a request for the
 * Capabilities Device in the scanner.
 */
-(void)postGetCapabilitiesDevice:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response;

/**
 * postGetPostambleDevice
 *
 * Creates a SktScanObject and initializes it to perform a request for the
 * Postamble Device in the scanner.
 *
 */
-(void)postGetPostambleDevice:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response;


/**
 * postSetPostamble
 *
 * Configure the postamble of the device
 * @param deviceInfo for
 * @param postamble for
 */
-(void)postSetPostambleDevice:(DeviceInfo*)deviceInfo Postamble:(NSString*)postamble Target:(id)target Response:(SEL)response;

/**
 * postGetSymbologyInfo
 *
 * Creates a SktScanObject and initializes it to perform a request for the
 * Symbology Info in the scanner.
 *
 */
-(void)postGetSymbologyInfo:(DeviceInfo*)deviceInfo SymbologyId:(int)symbologyId Target:(id)target Response:(SEL)response;

/**
 * postSetSymbologyInfo
 * Constructs a request object for setting the Symbology Info in the scanner
 *
 */
-(void)postSetSymbologyInfo:(DeviceInfo*)deviceInfo SymbologyId:(int)symbologyId Status:(BOOL)status Target:(id)target Response:(SEL)response;


/**
 * postGetFriendlyName
 *
 * Creates a SktScanObject and initializes it to perform a request for the
 * friendly name in the scanner.
 *
 */
-(void)postGetFriendlyName:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response;

/**
 * postSetFriendlyName
 * Constructs a request object for setting the Friendly Name in the scanner
 *
 */
-(void)postSetFriendlyName:(DeviceInfo*)deviceInfo FriendlyName:(NSString*)friendlyName Target:(id)target Response:(SEL)response;

/**
 * postSetDecodeActionDevice
 *
 * Configure the local decode action of the device
 *
 * @param deviceInfo for
 * @param decodeAction for
 */
-(void)postSetDecodeActionDevice:(DeviceInfo*)deviceInfo DecodeAction:(int)decodeAction Target:(id)target Response:(SEL)response;

/**
 * postGetLocalAcknowledgmentDevice
 *
 * Creates a SktScanObject and initializes it to perform a request for the
 * Local Acknowledgment of the scanner.
 *
 */
-(void)postGetLocalAcknowledgmentDevice:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response;

/**
 * postSetLocalAcknowledgmentDevice
 *
 * Configure the local Acknownledgment of the device
 *
 * @param deviceInfo for
 * @param localAcknowledgment for
 */
-(void)postSetLocalAcknowledgmentDevice:(DeviceInfo*)deviceInfo LocalAcknowledgment:(unsigned char)localAcknowledgment Target:(id)target Response:(SEL)response;

/**
 * postSetOverlayView
 *
 * Configure the Overlay view of softscan
 *
 * @param deviceInfo for
 */
-(void)postSetOverlayView:(DeviceInfo*)deviceInfo OverlayView:(id)overlayview Target:(id)target Response:(SEL)response;

/**
 * postSetTriggerDevice
 *
 * start scanning
 *
 * @param deviceInfo for
 * @param action for
 */
-(void)postSetTriggerDevice:(DeviceInfo*)deviceInfo Action:(unsigned char)action Target:(id)target Response:(SEL)response;
/**
 * postGetDataEditingProfiles
 *
 * Get the list of Data Editing profiles
 *
 */
-(void)postGetDataEditingProfiles:(id)target Response:(SEL)response;

/**
 * postSetDataEditingProfiles
 *
 * Set the list of Data Editing profiles
 * This will add or remove profiles in function of
 * the current profiles list
 * @param profiles semi colon separated list of the new profiles
 */
-(void)postSetDataEditingProfiles:(NSString*)profiles Target:(id)target Response:(SEL)response;

/**
 * postGetDataEditingCurrentProfile
 *
 * Get the Data Editing current profile
 *
 */
-(void)postGetDataEditingCurrentProfile:(id)target Response:(SEL)response;

/**
 * postSetDataEditingCurrentProfile
 *
 * Set the Data Editing current profile
 *
 * @param profile new current profile selected
 */
-(void)postSetDataEditingCurrentProfile:(NSString*)profile Target:(id)target Response:(SEL)response;

/**
 * postGetDataEditingTriggerSymbology
 *
 * Get the Data Editing profile Trigger symbology list the
 * decoded data must come from
 *
 * @param profile to retrieve the trigger symbology list from
 */
-(void)postGetDataEditingTriggerSymbology:(NSString*)profile Target:(id)target Response:(SEL)response;

/**
 * postSetDataEditingTriggerSymbology
 *
 * Set the Data Editing profile Trigger symbology list
 *
 */
-(void)postSetDataEditingTriggerSymbology:(NSString*)profileAndSymbology Target:(id)target Response:(SEL)response;

/**
 * postGetDataEditingTriggerMinLength
 *
 * Get the Data Editing profile Trigger Minimum Length for the decoded Data
 *
 * @param profile to get the trigger minimum length
 */
-(void)postGetDataEditingTriggerMinLength:(NSString*)profile Target:(id)target Response:(SEL)response;

/**
 * postSetDataEditingTriggerMinLength
 *
 * Set the Data Editing profile Trigger Minimum Length for the decoded Data
 *
 * @param profileAndLength contains the profile and the minimum length in decimal
 */
-(void)postSetDataEditingTriggerMinLength:(NSString*)profileAndLength Target:(id)target Response:(SEL)response;

/**
 * postGetDataEditingTriggerMaxLength
 *
 * Get the Data Editing profile Trigger Maximum Length for the decoded Data
 *
 * @param profile to get the trigger maximum length
 */
-(void)postGetDataEditingTriggerMaxLength:(NSString*)profile Target:(id)target Response:(SEL)response;

/**
 * postSetDataEditingTriggerMaxLength
 *
 * Set the Data Editing profile Trigger Maximum Length for the decoded Data
 *
 * @param profileAndLength contains the profile and the maximum length in decimal
 */
-(void)postSetDataEditingTriggerMaxLength:(NSString*)profileAndLength Target:(id)target Response:(SEL)response;

/**
 * postGetDataEditingTriggerStartsBy
 *
 * Get the Data Editing profile Trigger Starts by string for the decoded Data
 *
 * @param profile to retrieve the trigger Starts by
 */
-(void)postGetDataEditingTriggerStartsBy:(NSString*)profile Target:(id)target Response:(SEL)response;

/**
 * postSetDataEditingTriggerStartsBy
 *
 * Set the Data Editing profile Trigger Starts by string for the decoded Data
 *
 * @param profileAndString contains the profile and Starts by string
 */
-(void)postSetDataEditingTriggerStartsBy:(NSString*)profileAndString Target:(id)target Response:(SEL)response;

/**
 * postGetDataEditingTriggerEndsWith
 *
 * Get the Data Editing profile Trigger Ends with string for the decoded Data
 *
 * @param profile to retrieve the trigger Ends with
 */
-(void)postGetDataEditingTriggerEndsWith:(NSString*)profile Target:(id)target Response:(SEL)response;

/**
 * postSetDataEditingTriggerEndsWith
 *
 * Set the Data Editing profile Trigger Ends with string for the decoded Data
 *
 * @param profileAndString contains the profile and the Ends With string
 */
-(void)postSetDataEditingTriggerEndsWith:(NSString*)profileAndString Target:(id)target Response:(SEL)response;

/**
 * postGetDataEditingTriggerContains
 *
 * Get the Data Editing profile Trigger Contains a string for the decoded Data
 *
 * @param profile to retrieve the trigger Contains string
 */
-(void)postGetDataEditingTriggerContains:(NSString*)profile Target:(id)target Response:(SEL)response;

/**
 * postSetDataEditingTriggerContains
 *
 * Set the Data Editing profile Trigger Contains a string for the decoded Data
 *
 * @param profileAndString contains the profile and the Contains string
 */
-(void)postSetDataEditingTriggerContains:(NSString*)profileAndString Target:(id)target Response:(SEL)response;

/**
 * postGetDataEditingOperations
 *
 * Get the Data Editing profile Operations applied to the decoded Data
 *
 * @param profile to retrieve the operations from
 */
-(void)postGetDataEditingOperations:(NSString*)profile Target:(id)target Response:(SEL)response;

/**
 * postSetDataEditingOperations
 *
 * Set the Data Editing profile Operations applied to the decoded Data
 *
 * @param profileAndOperations contains the profile and the operation to set to
 */
-(void)postSetDataEditingOperations:(NSString*)profileAndOperations Target:(id)target Response:(SEL)response;

/**
 * postGetDataEditingExport
 *
 * Export the Data Editing profile
 *
 * @param profile to export
 */
-(void)postGetDataEditingExport:(NSString*)profile Target:(id)target Response:(SEL)response;

/**
 * postSetDataEditingImport
 *
 * Import the Data Editing profile
 *
 * @param profile to Import from
 */
-(void)postSetDataEditingImport:(NSString*)profile Target:(id)target Response:(SEL)response;

/**
 * postSetNotificationsForDevice
 *
 * Configure the Device Notifications
 *
 * @param deviceInfo device to configure the notifications
 * @param notifications notifications to receive
 */
-(void)postSetNotificationsForDevice:(DeviceInfo*)deviceInfo forNotifications:(int)notifications Target:(id)target Response:(SEL)response;

/**
 * postGetNotificationsFromDevice
 *
 * Retrieve the Device Notifications
 *
 * @param deviceInfo device to configure the notifications
 */
-(void)postGetNotificationsFromDevice:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response;

/**
 * postGetPowerStateFromDevice
 *
 * Retrieve the Device Power State
 *
 * @param deviceInfo device to retrieve the power state from
 */
-(void)postGetPowerStateFromDevice:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response;

/**
 * postGetButtonsStateFromDevice
 *
 * Retrieve the Device Buttons State
 *
 * @param deviceInfo device to retrieve the buttons state from
 */
-(void)postGetButtonsStateFromDevice:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response;

/**
 * postGetBatteryLevelFromDevice
 *
 * Retrieve the Device Battery Level
 *
 * @param deviceInfo device to retrieve the battery level from
 */
-(void)postGetBatteryLevelFromDevice:(DeviceInfo*)deviceInfo Target:(id)target Response:(SEL)response;

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
-(void)postGetDeviceSpecific:(DeviceInfo*)deviceInfo Command:(unsigned char*)pCommand Length:(int) length Target:(id)target Response:(SEL) response;

-(void)addCommand:(CommandContext*)command;
-(void)initializeScanAPIThread:(id)arg;
-(BOOL)handleScanObject:(ISktScanObject*)scanObj;
-(SKTRESULT)handleDeviceArrival:(ISktScanObject*)scanObj;
-(SKTRESULT)handleDeviceRemoval:(ISktScanObject*)scanObj;

-(SKTRESULT)handleSetOrGetComplete:(ISktScanObject*)scanObj;
-(SKTRESULT)handleEvent:(ISktScanObject*)scanObj;
-(SKTRESULT)handleDecodedData:(ISktScanObject*)scanObj;
-(SKTRESULT)sendNextCommand;

@end
