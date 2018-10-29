/*
SktScanTypes.h
Type definitions for Socket ScanAPI
(c) Socket Mobile, Inc.
*/

/*
NOTES: 
IF ANY MODIFICATION IS MADE IN THIS FILE THE SCANAPI INTERFACE VERSION
WILL NEED TO BE UPDATED TO IDENTIFY THIS CHANGE.
THE SCANAPI INTERFACE VERSION IS DEFINED IN SktScanAPI.h
THE MODIFICATION MUST BE DESCRIBED IN ScanAPI.doc
*/

#ifndef _SktScanTypes_h
#define _SktScanTypes_h

typedef void *SKTHANDLE;
typedef long SKTRESULT;
#define kSktScanDeviceNameSize 64
#ifndef IN
#define IN
#define OUT 
#define OPTIONAL
#endif

// identifies the type of message
// ScanAPI can send to the App
enum ESktScanMsgID
{
	kSktScanMsgIdNotInitialized,// this id should never be received
	kSktScanMsgIdDeviceArrival,
	kSktScanMsgIdDeviceRemoval,
	kSktScanMsgIdTerminate,
	kSktScanMsgSetComplete,
	kSktScanMsgGetComplete,
	kSktScanMsgEvent,
	kSktScanMsgLastID// just for marking the end of this enum
};

// identifies the type of Event
// ScanAPI can send to the App
enum ESktScanEventID
{
	kSktScanEventError,
	kSktScanEventDecodedData,
	kSktScanEventPower,
	kSktScanEventButtons,
	kSktScanEventBatteryLevel,// Battery Level has changed
	kSktScanEventListenerStarted,// the communucation port listener has started
	kSktScanEventLastID// just for marking the end of this enum
};

// identifies the type of data
// receive in the Event Data structure
enum ESktEventDataType
{
	kSktScanEventDataTypeNone,
	kSktScanEventDataTypeByte,
	kSktScanEventDataTypeUlong,
	kSktScanEventDataTypeArray,
	kSktScanEventDataTypeString,
	kSktScanEventDataTypeDecodedData,
	kSktScanEventDataTypeLastID// just for marking the end of this enum
};

// identifies symbologies
enum ESktScanSymbologyID
{
	kSktScanSymbologyNotSpecified,
	kSktScanSymbologyAustraliaPost,
	kSktScanSymbologyAztec,
	kSktScanSymbologyBooklandEan,
	kSktScanSymbologyBritishPost,
	kSktScanSymbologyCanadaPost,
	kSktScanSymbologyChinese2of5,
	kSktScanSymbologyCodabar,
	kSktScanSymbologyCodablockA,
	kSktScanSymbologyCodablockF,
	kSktScanSymbologyCode11,
	kSktScanSymbologyCode39,
	kSktScanSymbologyCode39Extended,
	kSktScanSymbologyCode39Trioptic,
	kSktScanSymbologyCode93,
	kSktScanSymbologyCode128,
	kSktScanSymbologyDataMatrix,
	kSktScanSymbologyDutchPost,
	kSktScanSymbologyEan8,
	kSktScanSymbologyEan13,
	kSktScanSymbologyEan128,
	kSktScanSymbologyEan128Irregular,
	kSktScanSymbologyEanUccCompositeAB,
	kSktScanSymbologyEanUccCompositeC,
	kSktScanSymbologyGs1Databar,
	kSktScanSymbologyGs1DatabarLimited,
	kSktScanSymbologyGs1DatabarExpanded,
	kSktScanSymbologyInterleaved2of5,
	kSktScanSymbologyIsbt128,
	kSktScanSymbologyJapanPost,
	kSktScanSymbologyMatrix2of5,
	kSktScanSymbologyMaxicode,
	kSktScanSymbologyMsi,
	kSktScanSymbologyPdf417,
	kSktScanSymbologyPdf417Micro,
	kSktScanSymbologyPlanet,
	kSktScanSymbologyPlessey,
	kSktScanSymbologyPostnet,
	kSktScanSymbologyQRCode,
	kSktScanSymbologyStandard2of5,// also called Industrial 2 of 5 or Discrete 2 of 5
	kSktScanSymbologyTelepen,
	kSktScanSymbologyTlc39,
	kSktScanSymbologyUpcA,
	kSktScanSymbologyUpcE0,
	kSktScanSymbologyUpcE1,
	kSktScanSymbologyUspsIntelligentMail,
	kSktScanSymbologyDirectPartMarking,
	kSktScanSymbologyHanXin,
	kSktScanSymbologyLastSymbologyID
};

// identifies what the symbology struct contains
enum ESktScanSymbologyFlags
{
	kSktScanSymbologyFlagStatus=0x01,
	kSktScanSymbologyFlagParam=0x02,
};

// identifies the status of a symbology
enum ESktScanSymbologyStatus
{
	kSktScanSymbologyStatusDisable=0x00,
	kSktScanSymbologyStatusEnable=0x01,
	kSktScanSymbologyStatusNotSupported=0x02
};


// define an Array
typedef struct 
{
	size_t Size;
	unsigned char* pData;
}TSktScanArray;

// define a string
typedef struct 
{
	size_t nLength;
	char* pValue;
}TSktScanString;

// define a version
typedef struct
{
	unsigned long dwMajor;
	unsigned long dwMiddle;
	unsigned long dwMinor;
	unsigned long dwBuild;
	unsigned short wMonth;
	unsigned short wDay;
	unsigned short wYear;
	unsigned short wHour;
	unsigned short wMinute;
}TSktScanVersion;

// define a decoded data structure
typedef struct
{
	enum ESktScanSymbologyID SymbologyID;
	TSktScanString SymbologyName;
	TSktScanString String;
}TSktScanDecodedData;

// define Event Data received
// when ScanAPI sends an Event to the application
typedef struct
{
	enum ESktEventDataType Type;
	union
	{
		unsigned char Byte;
		unsigned long Ulong;
		TSktScanArray Array;
		TSktScanString String;
		TSktScanDecodedData DecodedData;
	}Value;
}TSktEventData;


// define a parameter of a Symbology
typedef struct
{
	unsigned long Reserved;
}TSktScanSymbologyParam;

// Symbology information structure
typedef struct
{
	enum ESktScanSymbologyID ID;								// Symbology ID
	enum ESktScanSymbologyFlags Flags;						// Flags: Status  and/or Param
	enum ESktScanSymbologyStatus Status;						// Status: Disable, Enable or Not Supported
	TSktScanSymbologyParam Param;
	TSktScanString Name;								// Symbology name
}TSktScanSymbology;


// define a ScanObject Property
typedef struct 
{
	long ID;// property ID (defined in SktScanPropIds.h)
	enum ESktScanPropType Type;// define the type used in the following union
	union
	{
		unsigned char Byte;
		unsigned long Ulong;
		struct 
		{
			size_t Size;
			unsigned char* pData;
		}Array;
		TSktScanString String;
		TSktScanVersion Version;
		//TSktScanEnum Enum;
		TSktScanSymbology Symbology;
        void* Object;
	}Value;
	// context can travel with the property, 
	// so when a response is received, 
	// the context is the one used in the original request
	void* Context;
}TSktScanProperty;

// defines an enumeration struture
typedef struct
{
	unsigned int nCurrentIndex;
	unsigned int nTotal;
	TSktScanProperty Property;	
}TSktScanEnum;

// sample of a STRING GUID:"{D8DF7B22-6F5A-4f91-BF4F-C27E5BB8D286}"
#define kSktScanStringGuidSize		39 // including the null character
typedef char SKTSTRINGGUID [kSktScanStringGuidSize];

typedef struct
{
	enum ESktScanEventID ID;
	TSktEventData Data;
}TSktScanEvent;

typedef struct
{
	char szDeviceName[kSktScanDeviceNameSize];
	SKTHANDLE hDevice;
	unsigned long DeviceType;
	SKTSTRINGGUID Guid;
}TSktScanDevice;

// defines ScanObject struture
// ScanObject is used to exchange data
// between Application and ScanAPI or a device
// by using the Set/Get/Wait API
typedef struct 
{
	struct{
		enum ESktScanMsgID MsgID;// message ID received as asynchronous event
		SKTRESULT Result;// result of a complete message
		TSktScanDevice Device;
		TSktScanEvent Event;
	}Msg;
	TSktScanProperty Property;
}TSktScanObject;

extern const char* kSktScanSoftScanContext;
extern const char* kSktScanSoftScanLayoutId;
extern const char* kSktScanSoftScanViewFinderId;
extern const char* kSktScanSoftScanFlashButtonId;
extern const char* kSktScanSoftScanCancelButton;
extern const char* kSktScanSoftScanFlashButton;
extern const char* kSktScanSoftScanDirectionText;
extern const char* kSktScanSoftScanBackgroundColor;//"rgb() or rgba()
extern const char* kSktScanSoftScanTextColor;//"rgb() or rgba()
extern const char* kSktScanSoftScanCamera; // "front" "back"

#endif // _SktScanTypes_h


