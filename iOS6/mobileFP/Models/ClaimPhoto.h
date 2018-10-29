//
//  ClaimPhoto.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/6/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClaimPhoto : NSObject

@property int claimIndx;
@property NSString *dateUploaded;
@property NSString *photoDescription;
@property NSString *file;
@property NSString *fileBase64;
@property NSString *fileExt;
@property NSString *fileName;
@property NSString *fileType;
@property NSString *imageURL;
@property int phaseIndx;
@property int regionId;
@property int sendToXAEM;
@property int sendToXARE;
@property int sentToXASuccess;
@property NSString *fileMetaData;
@property NSString *thumbURL;

- (id)init;
- (void)initWithData:(NSMutableArray *)data;

@end
