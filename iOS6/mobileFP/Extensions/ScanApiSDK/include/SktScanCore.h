/*
SktScanCore.h
API definitions for Socket ScanAPI
(c) Socket Mobile, Inc.
*/

/*
NOTES: 
IF ANY MODIFICATION IS MADE IN THIS FILE THE SCANAPI INTERFACE VERSION
WILL NEED TO BE UPDATED TO IDENTIFY THIS CHANGE.
THE SCANAPI INTERFACE VERSION IS DEFINED IN SktScanAPI.h
THE MODIFICATION MUST BE DESCRIBED IN ScanAPI.doc
*/

#ifndef _SktScanCore_h
#define _SktScanCore_h

#define SKTSCANAPI_CONFIGURATOR_GUID "{11D47F36-BE62-4d28-9177-89F1BF3DDD4B}"

SKTRESULT
SktScanOpen(
	const char* lpszDeviceName,
	SKTHANDLE* pHandle
	);

SKTRESULT
SktScanClose(
	SKTHANDLE Handle
	);

SKTRESULT
SktScanGet(
	SKTHANDLE Handle,
	TSktScanObject* pScanObj
	);

SKTRESULT
SktScanSet(
	SKTHANDLE Handle,
	TSktScanObject* pScanObj
	);

SKTRESULT
SktScanWait(
	SKTHANDLE Handle,
	TSktScanObject** ppScanObj,
	unsigned long ulTimeout
	);

SKTRESULT
SktScanRelease(
	SKTHANDLE Handle,
	TSktScanObject* pScanObj
	);

#endif //_SktScanCore_h

