/*
SktScanDeviceType.h
Device Type definitions for Socket ScanAPI
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
Definition of a Socket Device Type

  31  30  29  28  27  26  25  24  23  22  21  20  19  18  17  16  15  14  13  12  11  10  9   8   7   6   5   4   3   2   1   0 
---------------------------------------------------------------------------------------------------------------------------------
|   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
---------------------------------------------------------------------------------------------------------------------------------
  |	                          |   |                           |  |                            |   |                              |  
  \===========================/   \===========================/  \============================/   \==============================/
                |                               |                                       |                       |  
                |                               |                                       |                       |  
                |                               |                                       | Reserved              \------------------->Product ID 
                |                               | Interface Type                        \------------------------------------------->Reserved must be 0
                | Reserved                      \----------------------------------------------------------------------------------->Interface Type
                \------------------------------------------------------------------------------------------------------------------->Reserved must be 0
                                                                                                                                                       

*/


#ifndef _SktScanDeviceType_h
#define _SktScanDeviceType_h


#define SKTINTERFACETYPE(interfaceType)			(interfaceType<<16)
#define SKTRETRIEVE_INTERFACETYPE(deviceType)	((deviceType>>16)&0x000000ff)

#define SKTPRODUCTID(productId)					(productId)
#define SKTRETRIEVE_PRODUCTID(deviceType)		(deviceType&0x000000ff)

// Device Interface Type
enum
{
	kSktScanDeviceTypeInterfaceNone,
	kSktScanDeviceTypeInterfaceSD,
	kSktScanDeviceTypeInterfaceCF,
	kSktScanDeviceTypeInterfaceBluetooth,
	kSktScanDeviceTypeInterfaceSerial
};

// Product ID
enum
{
	kSktScanDeviceTypeProductIdNone=0,
	kSktScanDeviceTypeProductId7,
	kSktScanDeviceTypeProductId7x,
	kSktScanDeviceTypeProductId9,
	kSktScanDeviceTypeProductId7xi,
	kSktScanDeviceTypeProductIdSoftScan,
	kSktScanDeviceTypeProductId8ci,
	kSktScanDeviceTypeProductId8qi,
	kSktScanDeviceTypeProductIdD700,
	kSktScanDeviceTypeProductIdD730,
	kSktScanDeviceTypeProductIdD750,
	kSktScanDeviceTypeUnknown
};


#define kSktScanDeviceTypeNone			(SKTINTERFACETYPE(kSktScanDeviceTypeInterfaceNone)|SKTPRODUCTID(kSktScanDeviceTypeProductIdNone))
#define kSktScanDeviceTypeScanner7		(SKTINTERFACETYPE(kSktScanDeviceTypeInterfaceBluetooth)|SKTPRODUCTID(kSktScanDeviceTypeProductId7))
#define kSktScanDeviceTypeScanner7x		(SKTINTERFACETYPE(kSktScanDeviceTypeInterfaceBluetooth)|SKTPRODUCTID(kSktScanDeviceTypeProductId7x))
#define kSktScanDeviceTypeScanner9		(SKTINTERFACETYPE(kSktScanDeviceTypeInterfaceBluetooth)|SKTPRODUCTID(kSktScanDeviceTypeProductId9))
#define kSktScanDeviceTypeScanner7xi	(SKTINTERFACETYPE(kSktScanDeviceTypeInterfaceBluetooth)|SKTPRODUCTID(kSktScanDeviceTypeProductId7xi))
#define kSktScanDeviceTypeSoftScan		(SKTINTERFACETYPE(kSktScanDeviceTypeInterfaceNone)|SKTPRODUCTID(kSktScanDeviceTypeProductIdSoftScan))
#define kSktScanDeviceTypeScanner8ci	(SKTINTERFACETYPE(kSktScanDeviceTypeInterfaceBluetooth)|SKTPRODUCTID(kSktScanDeviceTypeProductId8ci))
#define	kSktScanDeviceTypeScanner8qi	(SKTINTERFACETYPE(kSktScanDeviceTypeInterfaceBluetooth)|SKTPRODUCTID(kSktScanDeviceTypeProductId8qi))
#define	kSktScanDeviceTypeScannerD700	(SKTINTERFACETYPE(kSktScanDeviceTypeInterfaceBluetooth)|SKTPRODUCTID(kSktScanDeviceTypeProductIdD700))
#define	kSktScanDeviceTypeScannerD730	(SKTINTERFACETYPE(kSktScanDeviceTypeInterfaceBluetooth)|SKTPRODUCTID(kSktScanDeviceTypeProductIdD730))
#define	kSktScanDeviceTypeScannerD750	(SKTINTERFACETYPE(kSktScanDeviceTypeInterfaceBluetooth)|SKTPRODUCTID(kSktScanDeviceTypeProductIdD750))
#define kSktScanDeviceTypeBtUnknown		(SKTINTERFACETYPE(kSktScanDeviceTypeInterfaceBluetooth)|SKTPRODUCTID(kSktScanDeviceTypeUnknown))

#endif //_SktScanDeviceType_h

