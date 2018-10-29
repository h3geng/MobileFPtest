//
//  DeviceInfo.m
//  ScannerSettings
//
//  Created by Jimmy Yang on 11-2-23.
//  Copyright 2011 Socket Mobile, Inc. All rights reserved.
//

#import "DeviceInfo.h"

@implementation DecodedDataInfo

-(DecodedDataInfo*)initWithDecodedData:(ISktScanDecodedData*)decodedData{
    self=[super init];
    if(self!=nil){
#if __has_feature(objc_arc)
        _symbologyName=[decodedData Name];
#else
        _symbologyName=[[decodedData Name]retain];
#endif
        _length=[decodedData getDataSize];
        _data=[[NSMutableData alloc]initWithBytes:[decodedData getData] length:_length];
    }
    return self;
}

#if __has_feature(objc_arc)
#else
-(void)dealloc{
    [_symbologyName release];
    [_data release];
    [super dealloc];
}
#endif

-(NSString*)getSymbologyName{
    return _symbologyName;
}

-(void)setSymbologyName:(NSString*)symbologyName{
#if __has_feature(objc_arc)
    _symbologyName=symbologyName;
#else
    [_symbologyName release];
    _symbologyName=[symbologyName retain];
#endif
}

-(uint8_t*)getData{
    return (uint8_t*)[_data bytes];
}

-(void)setData:(uint8_t*)data Length:(int) length{
#if __has_feature(objc_arc)
#else
    [_data release];
#endif
    _data=[[NSMutableData alloc]initWithBytes:data length:length];
}

-(int)getLength{
    return _length;
}

-(void)setLength:(int)length{
    _length=length;
}

@end


@implementation SymbologyInfo

-(SymbologyInfo*)initWithSymbology:(ISktScanSymbology*)symbology{
    self=[super init];
    if(self!=nil){
        _id=[symbology getID];
#if __has_feature(objc_arc)
        _name=[symbology getName];
#else
        _name=[[symbology getName]retain];
#endif
        _enabled=[symbology getStatus]==kSktScanSymbologyStatusEnable;
    }
    return self;
}

#if __has_feature(objc_arc)
#else
-(void)dealloc{
    [_name release];
    [super dealloc];
}
#endif

-(enum ESktScanSymbologyID)getId{
    return _id;
}
-(void)setId:(enum ESktScanSymbologyID)symbologyId{
    _id=symbologyId;
}

-(NSString*)getName{
    return _name;
}
-(void)setName:(NSString *)name{
#if __has_feature(objc_arc)
#else
    [_name release];
    [name retain];
#endif
    _name=name;
}
-(BOOL)isEnabled{
    return _enabled;
}
-(void)setEnabled:(BOOL)enabled{
    _enabled=enabled;
}

@end

@implementation DeviceInfo


-(DeviceInfo*)init:(ISktScanDevice*)device name:(NSString*)name type:(long)type{
	self=[super init];
    if(self!=nil){
        _device=device;
#if __has_feature(objc_arc)
#else
        [name retain];
#endif
        _name=name;
        _type=type;
        _symbologies=[[NSMutableArray alloc]init];
    }
	return self;
}


-(void)dealloc{
    free(_healthValues);
#if __has_feature(objc_arc)
#else
    [_name release];
    [_bdAddress release];
    [_batterylevel release];
    [_standConfig release];
    [_version release];
    [_postamble release];
    [_symbologies release];
    [_decodedData release];
    [super dealloc];
#endif
}

-(ISktScanDevice*) getSktScanDevice{
	return _device;
}

-(void) setNotification:(id)notification{
	_notification=notification;
}

-(id) getNotification{
	return _notification;
}

-(NSString*) getName{
	return _name;
}

-(void) setName:(NSString*)name{
#if __has_feature(objc_arc)
    _name=name;
#else
	[_name release];
	_name=[name retain];
#endif
	[_notification OnNotify:self notificationType:kNotificationFriendlyName];
}

-(NSString*)getBdAddress{
    return _bdAddress;
}

-(void)setBdAddress:(NSString*) bdAddress{
#if __has_feature(objc_arc)
    _bdAddress=bdAddress;
#else
    [_bdAddress release];
    _bdAddress=[bdAddress retain];
#endif
	[_notification OnNotify:self notificationType:kNotificationBluetoothAddress];
}


-(NSString*) getTypeString{
	NSString *type;
	if(_type==kSktScanDeviceTypeScanner7)
		type=@"CHS 7 Scanner";
	else if(_type==kSktScanDeviceTypeScanner7x)
		type=@"CHS 7X Scanner";
	else if(_type==kSktScanDeviceTypeScanner7xi)
		type=@"CHS 7Xi Scanner";
	else if(_type==kSktScanDeviceTypeScanner9)
		type=@"CRS Scanner";
	else if(_type==kSktScanDeviceTypeSoftScan)
		type=@"SoftScan";
	else if(_type==kSktScanDeviceTypeScanner8ci)
		type=@"SocketScan S800 Scanner";
    else if(_type==kSktScanDeviceTypeScanner8qi)
        type=@"SocketScan S850 Scanner";
    else if(_type==kSktScanDeviceTypeScannerD700)
        type=@"DuraScan D700 Scanner";
    else if(_type==kSktScanDeviceTypeScannerD730)
        type=@"DuraScan D730 Scanner";
    else if(_type==kSktScanDeviceTypeScannerD750)
        type=@"DuraScan D750 Scanner";
	else {
		type=@"Unknown scanner type";
	}
	return type;
}

-(void) setType:(long)type{
	_type=type;
	[_notification OnNotify:self notificationType:kNotificationDeviceType];
}

-(long) getType{
    return _type;
}

-(NSString*)getFirmwareVersion{
    return _version;
}

-(void)setFirmwareVersion:(NSString *)version{
#if __has_feature(objc_arc)
    _version = version;
#else
    [_version release];
    _version=[version retain];
#endif
	[_notification OnNotify:self notificationType:kNotificationFirmwareVersion];
}

-(NSString*)getBatteryLevel{
    return _batterylevel;
}
-(void)setBatteryLevel:(NSString *)level{
#if __has_feature(objc_arc)
    _batterylevel = level;
#else
    [_batterylevel release];
    _batterylevel = [level retain];
#endif
	[_notification OnNotify:self notificationType:kNotificationBattery];
}

-(NSString*)getStandConfig{
    return _standConfig;
}
-(void)setStandConfig:(NSString *)config{
#if __has_feature(objc_arc)
    _standConfig = config;
#else
    [_standConfig release];
    _standConfig = [config retain];
#endif
	[_notification OnNotify:self notificationType:kNotificationStandConfig];
}

-(int) getLocalDecodeAction{
	return _localDecodeAction;
}

-(void) setLocalDecodeAction:(int)decodeAction{
	_localDecodeAction=decodeAction;
	[_notification OnNotify:self notificationType:kNotificationLocalDecodeAction];
}

-(BOOL) getRumbleSupport{
	return _rumbleSupport;
}
-(void) setRumbleSupport:(BOOL)support{
	_rumbleSupport=support;
	[_notification OnNotify:self notificationType:kNotificationCapabilities];
}

-(NSString*)getPostamble{
    return _postamble;
}

-(void)setPostamble:(NSString*) postamble{
#if __has_feature(objc_arc)
    _postamble = postamble;
#else
    [_postamble release];
    _postamble = [postamble retain];
#endif
	[_notification OnNotify:self notificationType:kNotificationPostamble];
}


-(DecodedDataInfo*) getDecodedData{
	return _decodedData;
}

-(void) setDecodeData:(ISktScanDecodedData*)decodedData{
#if __has_feature(objc_arc)
#else
	[_decodedData release];
#endif
    _decodedData=[[DecodedDataInfo alloc] initWithDecodedData:decodedData];
	[_notification OnNotify:self notificationType:kNotificationDecodedData];
}

-(void) setDecodedDataInfo:(DecodedDataInfo*)decodedData{
#if __has_feature(objc_arc)
#else
	[_decodedData release];
    [decodedData retain];
#endif
    _decodedData=decodedData;
	[_notification OnNotify:self notificationType:kNotificationDecodedData];
}

-(SymbologyInfo*)getSymbologyInfo:(int)index{
    SymbologyInfo* symbologyInfo=nil;
    if(index<_symbologies.count){
        symbologyInfo=[_symbologies objectAtIndex:index];
    }
    return symbologyInfo;
}

-(void)addSymbologyInfo:(ISktScanSymbology*)symbologyInfo{

    // care only about the symbology that is supported by the device
    if([symbologyInfo getStatus]!=kSktScanSymbologyStatusNotSupported){
#if __has_feature(objc_arc)
        [_symbologies addObject:[[SymbologyInfo alloc]initWithSymbology:symbologyInfo] ];
#else
        [_symbologies addObject:[[[SymbologyInfo alloc]initWithSymbology:symbologyInfo] autorelease]];
#endif
        [_notification OnNotify:self notificationType:kNotificationSymbology];
    }
}

-(int)getSymbologyCount{
    int count=0;
    if(_symbologies!=nil)
        count=(int)_symbologies.count;
    return count;
}

-(void)setPropertyError:(long)propertyId Error:(long)error{
    _setPropertyId=propertyId;
    _setPropertyError=error;
    [_notification OnNotify:self notificationType:kNotificationSetPropertyError];
}

-(long)getPropertyErrorId{
    return _setPropertyId;
}

-(long)getPropertyError{
    return _setPropertyError;
}

-(void)setHealthValues:(short*)healthValues Size:(int)size{
    free(_healthValues);
    _healthValues = malloc(size*sizeof(short));
    memcpy(_healthValues,healthValues,size*sizeof(short));
    _healthValuesSize=size;
}

-(short*)getHealthValues{
    return _healthValues;
}

-(int)getHealthValuesSize{
    return _healthValuesSize;
}

-(void)setHealth:(int)health{
    _healthState=health;
    [_notification OnNotify:self notificationType:kNotificationHealth];
}

-(int)getHealth{
    return _healthState;
}
@end
