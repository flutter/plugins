// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "LocationBackgroundPlugin.h"

#import <CoreLocation/CoreLocation.h>

@implementation LocationBackgroundPlugin {
    CLLocationManager* _locationManager;
    FlutterHeadlessDartRunner* _headlessRunner;
    FlutterMethodChannel* _callbackChannel;
    FlutterMethodChannel* _mainChannel;
    NSObject<FlutterPluginRegistrar> *_registrar;
    int64_t _onLocationUpdateHandle;
}

static LocationBackgroundPlugin *instance = nil;

# pragma mark FlutterPlugin Methods

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  @synchronized(self) {
    if (instance == nil) {
      instance = [[LocationBackgroundPlugin alloc] init:registrar];
    }
  }
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSArray *arguments = call.arguments;
  if ([@"monitorLocationChanges" isEqualToString:call.method]) {
    NSAssert(arguments.count == 6,
             @"Invalid argument count for 'monitorLocationChanges'");
    [self monitorLocationChanges:arguments];
    result(@(YES));
  } else if ([@"startHeadlessService" isEqualToString:call.method]) {
    NSAssert(arguments.count == 1,
             @"Invalid argument count for 'startHeadlessService'");
    [self startHeadlessService:[arguments[0] longValue]];
  } else if ([@"cancelLocationUpdates" isEqualToString:call.method]) {
    NSAssert(arguments.count == 0,
             @"Invalid argument count for 'cancelLocationUpdates'");
    [self stopUpdatingLocation];
    result(nil);
  } else {
    NSLog(@"Unknown method: %@\n", call.method);
    result(FlutterMethodNotImplemented);
  }
}

# pragma mark LocationManagerDelegate Methods

// Location events come in here from our LocationManager and are forwarded to
// onLocationEvent.
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
  for (CLLocation *location in locations) {
    [self onLocationEvent:location];
  }
}

# pragma mark LocationBackgroundPlugin Methods

- (instancetype)init:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  _locationManager = [[CLLocationManager alloc] init];
  [_locationManager setDelegate:self];
  [_locationManager requestAlwaysAuthorization];
  
  _headlessRunner = [[FlutterHeadlessDartRunner alloc] init];
  _registrar = registrar;

  // This is the method channel used to communicate with the UI Isolate.
  _mainChannel = [FlutterMethodChannel
      methodChannelWithName:@"plugins.flutter.io/ios_background_location"
            binaryMessenger:[registrar messenger]];
  [registrar addMethodCallDelegate:self channel:_mainChannel];

  // This is the method channel used to communicate with
  // `_backgroundCallbackDispatcher` defined in the Dart portion of our plugin.
  // Note: we don't add a MethodCallDelegate for this channel now since our
  // BinaryMessenger needs to be initialized first, which is done in
  // `startHeadlessService` below.
  _callbackChannel = [FlutterMethodChannel
      methodChannelWithName:
          @"plugins.flutter.io/ios_background_location_callback"
            binaryMessenger:_headlessRunner];

  return self;
}

// Initializes and starts the background isolate which will process location
// events. `entrypoint` is the name of the callback to be invoked and `uri` is
// the URI of the library which contains the callback.
- (void)startHeadlessService:(int64_t)handle {
  FlutterCallbackInformation* info = [FlutterCallbackCache lookupCallbackInformation:handle];
  NSAssert(info != nil, @"failed to find callback");
  NSString* entrypoint = info.callbackName;
  NSString* uri = info.callbackLibraryPath;
  [_headlessRunner
      runWithEntrypointAndCallback:entrypoint
                        libraryUri:uri
                        completion:^(BOOL success) {
                          NSAssert(success,
                                   @"Unable to start background service");
                        }];
  // The headless runner needs to be initialized before we can register it as a
  // MethodCallDelegate or else we get an illegal memory access. If we don't
  // want to make calls from `_backgroundCallDispatcher` back to native code,
  // we don't need to add a MethodCallDelegate for this channel.
  [_registrar addMethodCallDelegate:self channel:_callbackChannel];
}

// Start receiving location updates.
- (void)monitorLocationChanges:(NSArray*)arguments {
  _onLocationUpdateHandle = [arguments[0] longValue];
  _locationManager.pausesLocationUpdatesAutomatically = arguments[1];
  _locationManager.showsBackgroundLocationIndicator = arguments[2];
  _locationManager.distanceFilter = [arguments[3] integerValue];
  _locationManager.desiredAccuracy = [arguments[4] integerValue];
  _locationManager.activityType = [arguments[5] integerValue];
  [self->_locationManager startUpdatingLocation];
}

// Stop the location updates.
- (void)stopUpdatingLocation {
  [self->_locationManager stopUpdatingLocation];
}

// Sends location events to our `_backgroundCallDispatcher` in Dart code via
// the MethodChannel we established earlier.
- (void)onLocationEvent:(CLLocation *)location {
  [_callbackChannel
      invokeMethod:@"onLocationEvent"
         arguments:@[
           @(_onLocationUpdateHandle),
           @(location.timestamp.timeIntervalSince1970),
           @(location.coordinate.latitude), @(location.coordinate.longitude),
           @(location.horizontalAccuracy), @(location.speed)
         ]
  ];
}

@end
