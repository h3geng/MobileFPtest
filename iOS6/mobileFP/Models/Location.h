//
//  Location.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/7/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Location : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) CLLocation *lastSavedLocation;

+ (Location *)getInstance;
- (void)checkLocationService;

@end
