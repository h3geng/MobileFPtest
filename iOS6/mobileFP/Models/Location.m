//
//  Location.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/7/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "Location.h"

@implementation Location

/**
 * Gets the instance of self object.
 *
 * @return instance object.
 */
+ (Location *)getInstance {
    SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

#pragma mark - Functions

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    
    return _locationManager;
}

- (void)checkLocationService {
    if ([CLLocationManager locationServicesEnabled]) {
        [self checkLocationStatus:[self locationManager] authorizationStatus:[CLLocationManager authorizationStatus]];
    } else {
        [[self locationManager] stopUpdatingLocation];
        [self openSettings];
    }
}

- (void)openSettings {
    [ALERT alertWithHandler:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:[NSString stringWithFormat:@"%@, %@\n%@", NSLocalizedStringFromTable(@"location_services_enabled", [UTIL getLanguage], @""), NSLocalizedStringFromTable(@"app_permission_denied", [UTIL getLanguage], @""), NSLocalizedStringFromTable(@"turn_on_location_services", [UTIL getLanguage], @"")] completion:^(BOOL granted) {
        if (granted) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self checkLocationStatus:manager authorizationStatus:status];
}

- (void)checkLocationStatus:(CLLocationManager *)manager authorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            [_locationManager requestWhenInUseAuthorization];
            break;
        case kCLAuthorizationStatusDenied:
            [_locationManager stopUpdatingLocation];
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            [_locationManager startUpdatingLocation];
            break;
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation* location = [locations lastObject];
    
    if (_lastSavedLocation == nil || [location distanceFromLocation:_lastSavedLocation] > 100.0) {
        _lastSavedLocation = location;
        [API updateDeviceLocation:USER.sessionId location:_lastSavedLocation completion:^(NSMutableArray *result) {
        }];
    }
}

@end
