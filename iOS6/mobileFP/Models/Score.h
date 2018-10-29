//
//  Score.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/10/13.
//  Copyright (c) 2013 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Score : NSObject

@property NSString *custContact;
@property int isException;
@property NSString *overall;
@property NSMutableArray *phaseScores;
@property NSString *siteInspect;

- (id)init;
- (void)initWithData:(NSMutableArray *)data;
- (NSMutableArray *)createPhaseScores:(NSMutableArray *)data;

@end
