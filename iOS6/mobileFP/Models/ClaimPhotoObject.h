//
//  ClaimPhotoObject.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-05-16.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClaimPhotoObject : NSObject

@property int selfId;
@property int claimIndx;
@property int phaseIndx;
@property NSString *phaseName;
@property UIImage *photo;
@property UIImage *thumbnail;
@property NSString *photoDescription;

- (id)init;
- (void)upload:(void(^)(bool result))completion;

@end
