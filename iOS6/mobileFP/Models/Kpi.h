//
//  Kpi.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/10/13.
//  Copyright (c) 2013 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actual.h"
#import "Score.h"

@interface Kpi : NSObject

@property Actual *actuals;
@property int claimIndx;
@property int scoreType;
@property Score *scores;
@property NSString *targets;

- (id)init;
- (void)initWithData:(NSMutableArray *)data;

@end
