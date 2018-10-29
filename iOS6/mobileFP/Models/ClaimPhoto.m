//
//  ClaimPhoto.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/6/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "ClaimPhoto.h"

@implementation ClaimPhoto

- (id)init {
    self = [super init];
    if (self) {
        _claimIndx = 0;
        _dateUploaded = @"";
        _photoDescription = @"";
        _file = @"";
        _fileBase64 = @"";
        _fileExt = @"";
        _fileName = @"";
        _fileType = @"";
        _imageURL = @"";
        _phaseIndx = 0;
        _regionId = 0;
        _sendToXAEM = 0;
        _sendToXARE = 0;
        _sentToXASuccess = 0;
        _fileMetaData = @"";
        _thumbURL = @"";
    }
    return self;
}

- (void)initWithData:(NSMutableArray *)data {
    _claimIndx = ([data valueForKey:@"claimIndx"] && [data valueForKey:@"claimIndx"] != [NSNull null]) ? [[data valueForKey:@"claimIndx"] intValue] : 0;
    _dateUploaded = ([data valueForKey:@"dateUploaded"] && [data valueForKey:@"dateUploaded"] != [NSNull null]) ? [data valueForKey:@"dateUploaded"] : @"";
    _photoDescription = ([data valueForKey:@"description"] && [data valueForKey:@"description"] != [NSNull null]) ? [data valueForKey:@"description"] : @"";
    _file = ([data valueForKey:@"file"] && [data valueForKey:@"file"] != [NSNull null]) ? [data valueForKey:@"file"] : @"";
    _fileBase64 = ([data valueForKey:@"fileBase64"] && [data valueForKey:@"fileBase64"] != [NSNull null]) ? [data valueForKey:@"fileBase64"] : @"";
    _fileExt = ([data valueForKey:@"fileExt"] && [data valueForKey:@"fileExt"] != [NSNull null]) ? [data valueForKey:@"fileExt"] : @"";
    _fileName = ([data valueForKey:@"fileName"] && [data valueForKey:@"fileName"] != [NSNull null]) ? [data valueForKey:@"fileName"] : @"";
    _fileType = ([data valueForKey:@"fileType"] && [data valueForKey:@"fileType"] != [NSNull null]) ? [data valueForKey:@"fileType"] : @"";
    _imageURL = ([data valueForKey:@"imageURL"] && [data valueForKey:@"imageURL"] != [NSNull null]) ? [data valueForKey:@"imageURL"] : @"";
    _phaseIndx = ([data valueForKey:@"phaseIndx"] && [data valueForKey:@"phaseIndx"] != [NSNull null]) ? [[data valueForKey:@"phaseIndx"] intValue] : 0;
    _regionId = ([data valueForKey:@"regionId"] && [data valueForKey:@"regionId"] != [NSNull null]) ? [[data valueForKey:@"regionId"] intValue] : 0;
    _sendToXAEM = ([data valueForKey:@"sendToXAEM"] && [data valueForKey:@"sendToXAEM"] != [NSNull null]) ? [[data valueForKey:@"sendToXAEM"] intValue] : 0;
    _sendToXARE = ([data valueForKey:@"sendToXARE"] && [data valueForKey:@"sendToXARE"] != [NSNull null]) ? [[data valueForKey:@"sendToXARE"] intValue] : 0;
    _sentToXASuccess = ([data valueForKey:@"sentToXASuccess"] && [data valueForKey:@"sentToXASuccess"] != [NSNull null]) ? [[data valueForKey:@"sentToXASuccess"] intValue] : 0;
    _fileMetaData = ([data valueForKey:@"fileMetaData"] && [data valueForKey:@"fileMetaData"] != [NSNull null]) ? [data valueForKey:@"fileMetaData"] : @"";
    _thumbURL = ([data valueForKey:@"thumbURL"] && [data valueForKey:@"thumbURL"] != [NSNull null]) ? [data valueForKey:@"thumbURL"] : @"";
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:_claimIndx forKey:@"claimIndx"];
    [encoder encodeObject:_dateUploaded forKey:@"dateUploaded"];
    [encoder encodeObject:_photoDescription forKey:@"photoDescription"];
    [encoder encodeObject:_file forKey:@"file"];
    [encoder encodeObject:_fileBase64 forKey:@"fileBase64"];
    [encoder encodeObject:_fileExt forKey:@"fileExt"];
    [encoder encodeObject:_fileName forKey:@"fileName"];
    [encoder encodeObject:_fileType forKey:@"fileType"];
    [encoder encodeObject:_imageURL forKey:@"imageURL"];
    [encoder encodeInt:_phaseIndx forKey:@"phaseIndx"];
    [encoder encodeInt:_regionId forKey:@"regionId"];
    [encoder encodeInt:_sendToXAEM forKey:@"sendToXAEM"];
    [encoder encodeInt:_sendToXARE forKey:@"sendToXARE"];
    [encoder encodeInt:_sentToXASuccess forKey:@"sentToXASuccess"];
    [encoder encodeObject:_fileMetaData forKey:@"fileMetaData"];
    [encoder encodeObject:_thumbURL forKey:@"thumbURL"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _claimIndx = [decoder decodeIntForKey:@"claimIndx"];
        _dateUploaded = [decoder decodeObjectForKey:@"dateUploaded"];
        _photoDescription = [decoder decodeObjectForKey:@"photoDescription"];
        _file = [decoder decodeObjectForKey:@"file"];
        _fileBase64 = [decoder decodeObjectForKey:@"fileBase64"];
        _fileExt = [decoder decodeObjectForKey:@"fileExt"];
        _fileName = [decoder decodeObjectForKey:@"fileName"];
        _fileType = [decoder decodeObjectForKey:@"fileType"];
        _imageURL = [decoder decodeObjectForKey:@"imageURL"];
        _phaseIndx = [decoder decodeIntForKey:@"phaseIndx"];
        _regionId = [decoder decodeIntForKey:@"regionId"];
        _sendToXAEM = [decoder decodeIntForKey:@"sendToXAEM"];
        _sendToXARE = [decoder decodeIntForKey:@"sendToXARE"];
        _sentToXASuccess = [decoder decodeIntForKey:@"sentToXASuccess"];
        _fileMetaData = [decoder decodeObjectForKey:@"fileMetaData"];
        _thumbURL = [decoder decodeObjectForKey:@"thumbURL"];
    }
    return self;
}

@end
