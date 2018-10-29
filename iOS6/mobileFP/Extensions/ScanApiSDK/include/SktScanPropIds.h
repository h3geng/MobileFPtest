/*
SktScanPropIds.h
Property ID definitions for Socket ScanAPI
(c) Socket Mobile, Inc.
*/

/*
NOTES:
IF ANY MODIFICATION IS MADE IN THIS FILE THE SCANAPI INTERFACE VERSION
WILL NEED TO BE UPDATED TO IDENTIFY THIS CHANGE.
THE SCANAPI INTERFACE VERSION IS DEFINED IN SktScanAPI.h
THE MODIFICATION MUST BE DESCRIBED IN ScanAPI.doc
*/

/*
Definition of a Socket Scan Prop ID

  31  30  29  28  27  26  25  24  23  22  21  20  19  18  17  16  15  14  13  12  11  10  9   8   7   6   5   4   3   2   1   0
---------------------------------------------------------------------------------------------------------------------------------
|   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
---------------------------------------------------------------------------------------------------------------------------------
  |	  |                       |   |           |   |           |   |           |   |           |    |                           |
  |   \=======================/   \===========/   \===========/   \===========/   \===========/    \===========================/
  |               |                     |               |              |               |                         |
  |               |                     |               |              |               | Group ID                \------------------>Property ID
  |               |                     |               |              | Reserved      \-------------------------------------------->Group ID
  |               |                     |               | Set Type     \------------------------------------------------------------>Reserved must be 0
  |               |                     | Get Type      \--------------------------------------------------------------------------->Set Type (type of the property during a Set operation)
  |               | Reserved            \------------------------------------------------------------------------------------------->Get Type (type of the property during a Get operation)
  |  ScanAPI      \----------------------------------------------------------------------------------------------------------------->Reserved must be 0
  \--------------------------------------------------------------------------------------------------------------------------------->ScanAPI Prop ID (property only for ScanAPI)

*/
#ifndef _SktScanPropIds_h
#define _SktScanPropIds_h

#ifdef __cplusplus
extern "C" {
#endif
long SKTPROPIDSCANAPI(const long scanApi);
long SKTGETTYPE(const long type);
long SKTSETTYPE(const long type);
long SKTSETGROUPID(const long groupId);
long SKTSETPROPID(const long propId);
long SKTISSCANAPI(const long propId);
long SKTRETRIEVEID(const long propId);
long SKTRETRIEVESETTYPE(const long propId);
long SKTRETRIEVEGETTYPE(const long propId);
long SKTRETRIEVEGROUPID(const long groupId);

// ScanAPI configuration
extern const char* kSktScanConfigSerialComPort;		// indicates which com port ScanAPI listens
extern const char* kSktScanConfigPath;				// indicates where ScanAPI config file is located

// Monitor Debug -only available on build with traces turned on-
extern const char* kSktScanConfigMonitorDbgLevel;			// indicates what ScanAPI monitor Debug Level should be used
extern const char* kSktScanConfigMonitorDbgFileLineLevel;	// indicates what ScanAPI monitor Debug File Line level should be used
extern const char* kSktScanConfigMonitorDbgChannel;			// indicates what ScanAPI monitor Debug Channel should be used
#ifdef __cplusplus
}
#endif


// Data Confirmation Mode indicates what is
// expected to the send the Data ACK back to the scanner
enum ESktScanDataConfirmationMode
{
	kSktScanDataConfirmationModeOff,			// use the device configuration (Local Confirmation or App)
	kSktScanDataConfirmationModeDevice,			// the device confirms the decoded data locally
	kSktScanDataConfirmationModeScanAPI,		// ScanAPI confirms the decoded data as it receives them and there is one app
	kSktScanDataConfirmationModeApp				// the Application confirms the decoded data as it receives them
};

// Device Data Acknowledgment mode
enum ESktScanDeviceDataAcknowledgment
{
	kSktScanDeviceDataAcknowledgmentOff,	// the device won't locally acknowledge decoded data
	kSktScanDeviceDataAcknowledgmentOn		// the device will locally acknowledge decoded data
};

// Security Mode
enum ESktScanSecurityMode
{
	kSktScanSecurityModeNone,
	kSktScanSecurityModeAuthentication,
	kSktScanSecurityModeAuthenticationEncryption
};

// Trigger parameter
enum
{
    kSktScanTriggerStart=1,          // start a scan
    kSktScanTriggerStop,             // stop a scan
    kSktScanTriggerEnable,           // enable the trigger
    kSktScanTriggerDisable,          // disable the trigger
    kSktScanTriggerContinuousScan    // start a scan in continuous mode (SoftScan scanner only, ESKT_NOTSUPPORTED returned when used with other scanner)
};

// Delete Pairing Parameter
enum
{
	kSktScanDeletePairingCurrent=0,
	kSktScanDeletePairingAll=1
};


// Sound configuration parameters
// sound configuration Action Type
enum
{
	kSktScanSoundActionTypeGoodScan,
	kSktScanSoundActionTypeGoodScanLocal,
	kSktScanSoundActionTypeBadScan,
	kSktScanSoundActionTypeBadScanLocal
};

// sound configuration frequency
enum
{
	kSktScanSoundFrequencyNone=0,
	kSktScanSoundFrequencyLow,
	kSktScanSoundFrequencyMedium,
	kSktScanSoundFrequencyHigh,
	kSktScanSoundFrequencyLast		// max count, not an actual frequency
};

// Rumble configuration parameters
// Rumble configuration Action Type
enum
{
	kSktScanRumbleActionTypeGoodScan,
	kSktScanRumbleActionTypeGoodScanLocal,
	kSktScanRumbleActionTypeBadScan,
	kSktScanRumbleActionTypeBadScanLocal
};


// configuration for the Local Decode Action
enum
{
	kSktScanLocalDecodeActionNone=0,
	kSktScanLocalDecodeActionBeep=1,
	kSktScanLocalDecodeActionFlash=2,
	kSktScanLocalDecodeActionRumble=4
};

// configuration for the Data Confirmation property
enum
{
	kSktScanDataConfirmationLedNone=0,
	kSktScanDataConfirmationLedGreen=1,
	kSktScanDataConfirmationLedRed=2,
};
enum
{
	kSktScanDataConfirmationBeepNone=0,
	kSktScanDataConfirmationBeepGood=1,
	kSktScanDataConfirmationBeepBad=2,
};
enum
{
	kSktScanDataConfirmationRumbleNone=0,
	kSktScanDataConfirmationRumbleGood=1,
	kSktScanDataConfirmationRumbleBad=2
};
enum
{
	kSktScanFlashOff=0,
	kSktScanFlashOn=1
};
enum
{
	kSktScanEnableSoftScan=0,
	kSktScanDisableSoftScan=1,
    kSktScanSoftScanNotSupported=2,// make the SoftScan feature not supported (Set Property only)
    kSktScanSoftScanSupported=3// make the SoftScan feature supported (Set property only)
};

#ifdef __cplusplus
extern "C" {
#endif
// Macros to build a Data Confirmation or to extract fields
// from the Data Confirmation. Note: reserved should be set to 0.
unsigned long SKTDATACONFIRMATION(unsigned char reserved, unsigned char rumble, unsigned char beep, unsigned char led);
unsigned char SKTDATACONFIRMATION_LED(unsigned long dataConfirmation);
unsigned char SKTDATACONFIRMATION_BEEP(unsigned long dataConfirmation);
unsigned char SKTDATACONFIRMATION_RUMBLE(unsigned long dataConfirmation);


// Macros to retrieve the Buttons status
bool SKTBUTTON_ISLEFTPRESSED(unsigned char buttonsStatus);
bool SKTBUTTON_ISRIGHTPRESSED(unsigned char buttonsStatus);
bool SKTBUTTON_ISMIDDLEPRESSED(unsigned char buttonsStatus);
bool SKTBUTTON_ISPOWERPRESSED(unsigned char buttonsStatus);
bool SKTBUTTON_ISRINGDETACHED(unsigned char buttonsStatus);

unsigned char SKTBUTTON_LEFTPRESSED(unsigned char pressed);
unsigned char SKTBUTTON_RIGHTPRESSED(unsigned char pressed);
unsigned char SKTBUTTON_MIDDLEPRESSED(unsigned char pressed);
unsigned char SKTBUTTON_POWERPRESSED(unsigned char pressed);
unsigned char SKTBUTTON_RINGDETACHED(unsigned char detached);
#ifdef __cplusplus
}
#endif

// Power State
enum
{
	kSktScanPowerStatusUnknown=		0x00,
	kSktScanPowerStatusOnBattery=	0x01,
	kSktScanPowerStatusOnCradle=	0x02,
	kSktScanPowerStatusOnAc=		0x04
};

#ifdef __cplusplus
extern "C" {
#endif
// Macros to retrieve the Power status
unsigned char SKTPOWER_GETSTATE(unsigned long powerStatus);
unsigned long SKTPOWER_SETSTATE(unsigned long powerStatus);

// Macro to retrieve the Battery Level
unsigned char SKTBATTERY_GETMINLEVEL(unsigned long powerStatus);
unsigned char SKTBATTERY_GETMAXLEVEL(unsigned long powerStatus);
unsigned char SKTBATTERY_GETCURLEVEL(unsigned long powerStatus);
unsigned long SKTBATTERY_SETMINLEVEL(unsigned long powerStatus);
unsigned long SKTBATTERY_SETMAXLEVEL(unsigned long powerStatus);
unsigned long SKTBATTERY_SETCURLEVEL(unsigned long powerStatus);
#ifdef __cplusplus
}
#endif


//Monitor property
enum
{
	kSktScanMonitorDbgLevel=1,
	kSktScanMonitorDbgChannel,
	kSktScanMonitorDbgFileLineLevel,
	kSktScanMonitorLast
};


// Capability Groups
enum
{
	kSktScanCapabilityGeneral=1,		// Capabilities supported by all devices
	kSktScanCapabilityLocalFunctions=2	// Capabilities for devices supporting Local Function
};

// General Capabilities
enum
{
	kSktScanCapabilityGeneralLocalFunctions=0x00000001	// when this bit is on the device has the Local Functions capability
};

// Local Functions Capabilities
enum
{
	kSktScanCapabilityLocalFunctionRumble	=0x00000001,	// when this bit is on the device has the Rumble feature
	kSktScanCapabilityLocalFunctionChangeID	=0x00000002		// when this bit is on the device has the Change ID feature
};


// statistic Counter identifiers
enum
{
	kSktScanCounterUnknown=0,
	kSktScanCounterConnect=1,
	kSktScanCounterDisconnect=2,
	kSktScanCounterUnbond=3,
	kSktScanCounterFactoryReset=4,
	kSktScanCounterScans=5,
	kSktScanCounterScanButtonUp=6,
	kSktScanCounterScanButtonDown=7,
	kSktScanCounterPowerButtonUp=8,
	kSktScanCounterPowerButtonDown=9,
	kSktScanCounterPowerOnACTimeInMinutes=10,
	kSktScanCounterPowerOnBatTimeInMinutes=11,
// SSI only
	kSktScanCounterRfcommSend=12,
	kSktScanCounterRfcommReceive=13,
	kSktScanCounterRfcommReceiveDiscarded=14,
	kSktScanCounterUartSend=15,
	kSktScanCounterUartReceive=16,
	kSktScanCounterUartReceiveDiscarded=17,
// Specific to CRS
	kSktScanCounterButtonLeftPress=18,
    kSktScanCounterButtonLeftRelease=19,
    kSktScanCounterButtonRightPress=20,
    kSktScanCounterButtonRightRelease=21,
    kSktScanCounterRingUnitDetachEvents=22,
    kSktScanCounterRingUnitAttachEvents=23,

// 7X only (ISCI)
	kSktScanCounterDecodedBytes=24,
	kSktScanCounterAbnormalShutDowns=25,
	kSktScanCounterBatteryChargeCycles=26,
	kSktScanCounterBatteryChangeCount=27,

// Only on 8Ci
	kSktScanCounterPowerOn=28,
	kSktScanCounterPowerOff=29,

// 7X/Q only 7630 and higher
kSktScanStandModeChange = 30,

	kSktScanCounterLast // this is not a counter, just the last index
};

// disconnect parameter
enum
{
	kSktScanDisconnectStartProfile=0, // disconnect and then start the selected profile
	kSktScanDisconnectDisableRadio=1  // disconnect and disable radio (low power)
};

// profile select parameter
enum
{
	kSktScanProfileSelectNone=0,
	kSktScanProfileSelectSpp=1,
	kSktScanProfileSelectHid=2
};

// profile Config Role parameter
enum
{
	kSktScanProfileConfigNone=0,
	kSktScanProfileConfigAcceptor=1,
	kSktScanProfileConfigInitiator=2
};

// notifications masks
enum
{
    kSktScanNotificationsScanButtonPress      = 1 << 0,       // Enable scan button press notifications
    kSktScanNotificationsScanButtonRelease    = 1 << 1,       // Enable scan button release notifications
    kSktScanNotificationsPowerButtonPress     = 1 << 2,       // Enable power button release notifications
    kSktScanNotificationsPowerButtonRelease   = 1 << 3,       // Enable power button release notifications
    kSktScanNotificationsPowerState           = 1 << 4,       // Enable power state change notifications
    kSktScanNotificationsBatteryLevelChange   = 1 << 5        // Enable battery level change notifications
};

// timer identifications
enum
{
    kSktScanTimerTriggerAutoLockTimeout = 1,   // Trigger lock selected
    kSktScanTimerPowerOffDisconnected   = 2,   // Disconnected state timeout
    kSktScanTimerPowerOffConnected      = 4,   // Connected state timeout
};

// Data format
enum
{
	kSktScanDataFormatRaw	=0,
	kSktScanDataFormatPacket=1
};

// Trigger Mode
enum
{
	kSktScanTriggerModeLocalOnly		=1, // Normal trigger on the device
	kSktScanTriggerModeRemoteAndLocal	=2, // Normal trigger on the device or trigger from host
	kSktScanTriggerModeAutoLock			=3, // Auto Trigger Lock waiting for the host to unlock
	kSktScanTriggerModeNormalLock		=4, // the trigger is locked and unlocked locally
	kSktScanTriggerModePresentation		=5
};

// Connect Reason
enum
{
	kSktScanConnectReasonUnknown	=0, // unknown reason
	kSktScanConnectReasonPowerOn	=1, // the device has connected because it powers on
	kSktScanConnectReasonBarcode	=2,	// the device has connected because it scans a connect barcode
	kSktScanConnectReasonUserAction =3, // the device has connected because the user press the power button or the trigger button
	kSktScanConnectReasonHostChange	=4, // the device has connected because the host has changed
	kSktScanConnectReasonRetry		=5	// the device has connected because it is back in range
};

// Start Up Role SPP
enum
{
	kSktScanStartUpRoleSPPAcceptor	=0, // the SPP Role will always be Acceptor
	kSktScanStartUpRoleSPPLastRole	=1	// the SPP Role will always be what was the last SPP Role config
};

// Connect Beep Config
enum
{
	kSktScanConnectBeepConfigNoBeep	=0,	// don't beep when a connection is established
	kSktScanConnectBeepConfigBeep	=1	// Beep when a connection is established
};

// Stand Config
// 0 - Mobile mode Works like today existing firmware Engine is always in
//     trigger mode Engine hibernate enabled
// 1 - Stand mode Engine always in presentation mode Engine hibernate
//     disabled Scanner turns on immediately Power timers disabled Connection
//     retries forever
// 2 - Detect mode On stand engine in presentation mode On stand engine
//     hibernate disabled On stand charging led state not show On stand
//     scanner turns on immediately On stand power timers disabled On stand
//     connection retries forever Off stand engine in level mode Off stand
//     battery led state reported Off stand engine hibernate enabled Off stand
//     power off timers running Off stand connection retries halt after max
//     count
// 3 - Auto mode On stand engine in presentation mode On stand engine hibernate
//     disabled On stand charging led state not show On stand scanner turns on
//     immediately On stand power timers disabled On stand connection retries
//     forever Off stand does nothing, engine remains in presentation mode Off
//     stand trigger press causes engine to enter level mode Engine in level
//     mode battery led state reported Engine in level mode hibernate enabled
//     Engine in level mode power off timers running Engine in level mode
//     connection retries halt after max count
enum
{
	kSktScanStandConfigMobileMode=0,
	kSktScanStandConfigStandMode=1,
	kSktScanStandConfigDetectMode=2,
	kSktScanStandConfigAutoMode=3
};

#ifdef __cplusplus
extern "C" {
#endif
//========================================================
//			Property ID
//========================================================
// Property Types
enum ESktScanPropType {
	kSktScanPropTypeByte = 2,
	kSktScanPropTypeEnum = 8,
	kSktScanPropTypeArray = 4,
	kSktScanPropTypeVersion = 6,
	kSktScanPropTypeSymbology = 7,
	kSktScanPropTypeUlong = 3,
	kSktScanPropTypeObject = 9,
	kSktScanPropTypeLastType = 10,
	kSktScanPropTypeNotApplicable = 1,
	kSktScanPropTypeNone = 0,
	kSktScanPropTypeString = 5,
};

// Group IDs
enum {
	kSktScanGroupLocalFunctions=1,
	kSktScanGroupGeneral=0,
};

// Properties
enum {
	kSktScanIdConfiguration=3,
	kSktScanIdDeviceSecurityMode=1,
	kSktScanIdDeviceConnectReason=20,
	kSktScanIdDeviceConnectionBeepConfig=23,
	kSktScanIdDeviceStartUpRoleSPP=22,
	kSktScanIdDataConfirmationAction=5,
	kSktScanIdDataEditingCurrentProfile=10,
	kSktScanIdAbort=0,
	kSktScanIdDeviceCapabilities=9,
	kSktScanIdDeviceRestoreFactoryDefaults=4,
	kSktScanIdDataEditingProfile=9,
	kSktScanIdDeviceProfileConfig=16,
	kSktScanIdDevicePostamble=8,
	kSktScanIdDeviceType=2,
	kSktScanIdDeviceDeletePairingBonding=3,
	kSktScanIdDeviceDataConfirmation=10,
	kSktScanIdDeviceBluetoothAddress=13,
	kSktScanIdDeviceDataStore=18,
	kSktScanIdDeviceRumbleConfig=15,
	kSktScanIdDataEditingTriggerMinLength=12,
	kSktScanIdDataEditingTriggerSymbologies=11,
	kSktScanIdInterfaceVersion=2,
	kSktScanIdDeviceSoundConfig=7,
	kSktScanIdDevicePowerState=21,
	kSktScanIdDeviceLocalAcknowledgement=9,
	kSktScanIdDataEditingImportExport=18,
	kSktScanIdDataEditingTriggerEndsWith=15,
	kSktScanIdDeviceApplyConfig=6,
	kSktScanIdDataEditingTriggerContains=16,
	kSktScanIdDevicePinCode=2,
	kSktScanIdDeviceSpecific=3,
	kSktScanIdDeviceTimers=8,
	kSktScanIdSoftScanStatus=7,
	kSktScanIdMonitorMode=6,
	kSktScanIdSymbologyInfo=8,
	kSktScanIdDataEditingOperation=17,
	kSktScanLastDeviceGeneralGroup=12,
	kSktScanIdDeviceChangeId=10,
	kSktScanIdDataEditingTriggerStartsBy=14,
	kSktScanIdDeviceFlash=24,
	kSktScanIdDeviceFriendlyName=0,
	kSktScanIdDeviceBatteryLevel=11,
	kSktScanIdDevicePreamble=7,
	kSktScanIdDataConfirmationMode=4,
	kSktScanIdVersion=1,
	kSktScanIdDeviceSetPowerOff=5,
	kSktScanIdDeviceStatisticCounters=14,
	kSktScanIdDeviceTrigger=5,
	kSktScanIdDeviceDisconnect=17,
	kSktScanIdDeviceNotifications=19,
	kSktScanIdDeviceStandConfig=26,
	kSktScanIdDeviceOverlayView=25,
	kSktScanIdDeviceDataFormat=11,
	kSktScanIdDeviceInterfaceVersion=1,
	kSktScanIdDeviceButtonsStatus=6,
	kSktScanIdDeviceVersion=0,
	kSktScanIdDeviceSymbology=4,
	kSktScanIdDataEditingTriggerMaxLength=13,
	kSktScanLastDeviceLocalFunctions=27,
	kSktScanLastGeneralGroup=19,
	kSktScanIdDeviceLocalDecodeAction=12,
};

// Property IDs
enum {
	kSktScanPropIdAbort = -2146435072,		// SKTPROPIDSCANAPI(True)|SKTGETTYPE(kSktScanPropTypeNotApplicable)|SKTSETTYPE(kSktScanPropTypeNone)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdAbort)
	kSktScanPropIdVersion = -2147418111,		// SKTPROPIDSCANAPI(True)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeNotApplicable)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdVersion)
	kSktScanPropIdInterfaceVersion = -2147418110,		// SKTPROPIDSCANAPI(True)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeNotApplicable)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdInterfaceVersion)
	kSktScanPropIdConfiguration = -2141913085,		// SKTPROPIDSCANAPI(True)|SKTGETTYPE(kSktScanPropTypeString)|SKTSETTYPE(kSktScanPropTypeString)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdConfiguration)
	kSktScanPropIdDataConfirmationMode = -2147352572,		// SKTPROPIDSCANAPI(True)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeByte)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdDataConfirmationMode)
	kSktScanPropIdDataConfirmationAction = -2147287035,		// SKTPROPIDSCANAPI(True)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeUlong)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdDataConfirmationAction)
	kSktScanPropIdMonitorMode = -2145124346,		// SKTPROPIDSCANAPI(True)|SKTGETTYPE(kSktScanPropTypeByte)|SKTSETTYPE(kSktScanPropTypeArray)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdMonitorMode)
	kSktScanPropIdSoftScanStatus = -2147352569,		// SKTPROPIDSCANAPI(True)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeByte)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdSoftScanStatus)
	kSktScanPropIdDataEditingProfile = -2147155959,		// SKTPROPIDSCANAPI(True)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeString)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdDataEditingProfile)
	kSktScanPropIdDataEditingCurrentProfile = -2147155958,		// SKTPROPIDSCANAPI(True)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeString)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdDataEditingCurrentProfile)
	kSktScanPropIdDataEditingTriggerSymbologies = -2141913077,		// SKTPROPIDSCANAPI(True)|SKTGETTYPE(kSktScanPropTypeString)|SKTSETTYPE(kSktScanPropTypeString)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdDataEditingTriggerSymbologies)
	kSktScanPropIdDataEditingTriggerMinLength = -2141913076,		// SKTPROPIDSCANAPI(True)|SKTGETTYPE(kSktScanPropTypeString)|SKTSETTYPE(kSktScanPropTypeString)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdDataEditingTriggerMinLength)
	kSktScanPropIdDataEditingTriggerMaxLength = -2141913075,		// SKTPROPIDSCANAPI(True)|SKTGETTYPE(kSktScanPropTypeString)|SKTSETTYPE(kSktScanPropTypeString)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdDataEditingTriggerMaxLength)
	kSktScanPropIdDataEditingTriggerStartsBy = -2141913074,		// SKTPROPIDSCANAPI(True)|SKTGETTYPE(kSktScanPropTypeString)|SKTSETTYPE(kSktScanPropTypeString)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdDataEditingTriggerStartsBy)
	kSktScanPropIdDataEditingTriggerEndsWith = -2141913073,		// SKTPROPIDSCANAPI(True)|SKTGETTYPE(kSktScanPropTypeString)|SKTSETTYPE(kSktScanPropTypeString)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdDataEditingTriggerEndsWith)
	kSktScanPropIdDataEditingTriggerContains = -2141913072,		// SKTPROPIDSCANAPI(True)|SKTGETTYPE(kSktScanPropTypeString)|SKTSETTYPE(kSktScanPropTypeString)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdDataEditingTriggerContains)
	kSktScanPropIdDataEditingOperation = -2141913071,		// SKTPROPIDSCANAPI(True)|SKTGETTYPE(kSktScanPropTypeString)|SKTSETTYPE(kSktScanPropTypeString)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdDataEditingOperation)
	kSktScanPropIdDataEditingImportExport = -2141913070,		// SKTPROPIDSCANAPI(True)|SKTGETTYPE(kSktScanPropTypeString)|SKTSETTYPE(kSktScanPropTypeString)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdDataEditingImportExport)
	kSktScanPropIdVersionDevice = 65536,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeNotApplicable)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdDeviceVersion)
	kSktScanPropIdDeviceType = 65538,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeNotApplicable)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdDeviceType)
	kSktScanPropIdDeviceSpecific = 4456451,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeArray)|SKTSETTYPE(kSktScanPropTypeArray)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdDeviceSpecific)
	kSktScanPropIdSymbologyDevice = 7798788,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeSymbology)|SKTSETTYPE(kSktScanPropTypeSymbology)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdDeviceSymbology)
	kSktScanPropIdTriggerDevice = 1179653,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNotApplicable)|SKTSETTYPE(kSktScanPropTypeByte)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdDeviceTrigger)
	kSktScanPropIdApplyConfigDevice = 1048582,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNotApplicable)|SKTSETTYPE(kSktScanPropTypeNone)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdDeviceApplyConfig)
	kSktScanPropIdPreambleDevice = 327687,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeString)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdDevicePreamble)
	kSktScanPropIdPostambleDevice = 327688,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeString)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdDevicePostamble)
	kSktScanPropIdCapabilitiesDevice = 2162697,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeByte)|SKTSETTYPE(kSktScanPropTypeNotApplicable)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdDeviceCapabilities)
	kSktScanPropIdChangeIdDevice = 65546,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeNotApplicable)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdDeviceChangeId)
	kSktScanPropIdDataFormatDevice = 131083,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeByte)|SKTSETGROUPID(kSktScanGroupGeneral)|SKTSETPROPID(kSktScanIdDeviceDataFormat)
	kSktScanPropIdFriendlyNameDevice = 327936,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeString)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDeviceFriendlyName)
	kSktScanPropIdSecurityModeDevice = 131329,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeByte)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDeviceSecurityMode)
	kSktScanPropIdPinCodeDevice = 1376514,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNotApplicable)|SKTSETTYPE(kSktScanPropTypeString)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDevicePinCode)
	kSktScanPropIdDeletePairingBondingDevice = 1179907,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNotApplicable)|SKTSETTYPE(kSktScanPropTypeByte)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDeviceDeletePairingBonding)
	kSktScanPropIdRestoreFactoryDefaultsDevice = 1048836,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNotApplicable)|SKTSETTYPE(kSktScanPropTypeNone)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDeviceRestoreFactoryDefaults)
	kSktScanPropIdSetPowerOffDevice = 1048837,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNotApplicable)|SKTSETTYPE(kSktScanPropTypeNone)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDeviceSetPowerOff)
	kSktScanPropIdButtonsStatusDevice = 65798,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeNotApplicable)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDeviceButtonsStatus)
	kSktScanPropIdSoundConfigDevice = 2359559,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeByte)|SKTSETTYPE(kSktScanPropTypeArray)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDeviceSoundConfig)
	kSktScanPropIdTimersDevice = 262408,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeArray)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDeviceTimers)
	kSktScanPropIdLocalAcknowledgmentDevice = 131337,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeByte)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDeviceLocalAcknowledgement)
	kSktScanPropIdDataConfirmationDevice = 1245450,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNotApplicable)|SKTSETTYPE(kSktScanPropTypeUlong)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDeviceDataConfirmation)
	kSktScanPropIdBatteryLevelDevice = 65803,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeNotApplicable)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDeviceBatteryLevel)
	kSktScanPropIdLocalDecodeActionDevice = 131340,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeByte)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDeviceLocalDecodeAction)
	kSktScanPropIdBluetoothAddressDevice = 65805,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeNotApplicable)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDeviceBluetoothAddress)
	kSktScanPropIdStatisticCountersDevice = 65806,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeNotApplicable)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDeviceStatisticCounters)
	kSktScanPropIdRumbleConfigDevice = 2359567,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeByte)|SKTSETTYPE(kSktScanPropTypeArray)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDeviceRumbleConfig)
	kSktScanPropIdProfileConfigDevice = 262416,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeArray)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDeviceProfileConfig)
	kSktScanPropIdDisconnectDevice = 1179921,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNotApplicable)|SKTSETTYPE(kSktScanPropTypeByte)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDeviceDisconnect)
	kSktScanPropIdDataStoreDevice = 4456722,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeArray)|SKTSETTYPE(kSktScanPropTypeArray)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDeviceDataStore)
	kSktScanPropIdNotificationsDevice = 196883,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeUlong)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDeviceNotifications)
	kSktScanPropIdConnectReasonDevice = 65812,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeNotApplicable)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDeviceConnectReason)
	kSktScanPropIdPowerStateDevice = 65813,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeNotApplicable)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDevicePowerState)
	kSktScanPropIdStartUpRoleSPPDevice = 131350,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeByte)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDeviceStartUpRoleSPP)
	kSktScanPropIdConnectionBeepConfigDevice = 131351,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeByte)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDeviceConnectionBeepConfig)
	kSktScanPropIdFlashDevice = 131352,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeByte)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDeviceFlash)
	kSktScanPropIdOverlayViewDevice = 590105,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeObject)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDeviceOverlayView)
	kSktScanPropIdStandConfigDevice = 196890,		// SKTPROPIDSCANAPI(False)|SKTGETTYPE(kSktScanPropTypeNone)|SKTSETTYPE(kSktScanPropTypeUlong)|SKTSETGROUPID(kSktScanGroupLocalFunctions)|SKTSETPROPID(kSktScanIdDeviceStandConfig)
};



#ifdef __cplusplus
}
#endif

#endif //_SktScanPropIds_h
