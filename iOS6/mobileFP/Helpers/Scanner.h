//
//  Scanner.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/9/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Scanner : NSObject <ScanApiHelperDelegate>

@property int identity;
@property UIView *overlayView;
@property UILabel *label;

@property NSTimer *notifTimer;
@property NSTimer *notifTimerEnd;

@property ScanApiHelper *scanApi;
@property bool isConnected;

+ (Scanner *)getInstance;

- (void)initialize;
- (void)executeSearch:(NSString *)term;
- (void)search:(NSString *)term;
- (void)searchExact:(NSString *)term;

@end
