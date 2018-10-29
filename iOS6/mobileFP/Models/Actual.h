//
//  Actual.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/10/13.
//  Copyright (c) 2013 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Actual : NSObject

@property NSString *dateCalledIn;
@property NSString *dateComplete;
@property NSString *dateCustContact;
@property NSString *dateSiteInspect;
@property NSMutableArray *phaseTimelines;

- (id)init;
- (void)initWithData:(NSMutableArray *)data;
- (NSMutableArray *)createPhaseTimelines:(NSMutableArray *)data;

@end
