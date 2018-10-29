//
//  PendingPhoto.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-06-01.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PendingPhoto : NSObject

@property int claimIndex;
@property int phaseIndex;
@property NSString *claimName;
@property NSString *phaseName;
@property int photos;

- (id)init;

@end
