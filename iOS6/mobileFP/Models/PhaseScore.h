//
//  PhaseScore.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/10/13.
//  Copyright (c) 2013 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhaseScore : NSObject

@property NSString *estimate;
@property NSString *invoice;
@property NSString *lastrev;
@property NSString *overall;
@property NSString *phaseCode;
@property NSString *workAssignToStop;
@property NSString *workStartToStop;
@property int isException;

- (id)init;
- (void)initWithData:(NSMutableArray *)data;

@end
