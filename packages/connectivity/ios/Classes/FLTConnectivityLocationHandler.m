// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTConnectivityLocationHandler.h"

@interface FLTConnectivityLocationHandler () <CLLocationManagerDelegate>

@property(copy, nonatomic) FLTConnectivityLocationCompletion completion;
@property(strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation FLTConnectivityLocationHandler

+ (CLAuthorizationStatus)locationAuthorizationStatus {
  return CLLocationManager.authorizationStatus;
}

- (void)requestLocationAuthorization:(BOOL)always
                          completion:(FLTConnectivityLocationCompletion)completionHandler {
  CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
  if (status != kCLAuthorizationStatusAuthorizedWhenInUse && always) {
    completionHandler(kCLAuthorizationStatusDenied);
    return;
  } else if (status != kCLAuthorizationStatusNotDetermined) {
    completionHandler(status);
    return;
  }

  if (self.completion) {
    // If a request is still in process, immediately return.
    completionHandler(kCLAuthorizationStatusNotDetermined);
    return;
  }

  self.completion = completionHandler;
  self.locationManager = [CLLocationManager new];
  self.locationManager.delegate = self;
  if (always) {
    [self.locationManager requestAlwaysAuthorization];
  } else {
    [self.locationManager requestWhenInUseAuthorization];
  }
}

- (void)locationManager:(CLLocationManager *)manager
    didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  if (status == kCLAuthorizationStatusNotDetermined) {
    return;
  }
  if (self.completion) {
    self.completion(status);
    self.completion = nil;
  }
}

@end
