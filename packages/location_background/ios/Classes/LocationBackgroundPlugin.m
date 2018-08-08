// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "LocationBackgroundPlugin.h"

#import <CoreLocation/CoreLocation.h>

@implementation LocationBackgroundPlugin {
  CLLocationManager *_locationManager;
  FlutterHeadlessDartRunner *_headlessRunner;
  FlutterMethodChannel *_callbackChannel;
  FlutterMethodChannel *_mainChannel;
  NSObject<FlutterPluginRegistrar> *_registrar;
  NSUserDefaults *_persistentState;
  int64_t _onLocationUpdateHandle;
}

static LocationBackgroundPlugin *instance = nil;

#pragma mark FlutterPlugin Methods

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  @synchronized(self) {
    if (instance == nil) {
      instance = [[LocationBackgroundPlugin alloc] init:registrar];
      [registrar addApplicationDelegate:instance];
    }
  }
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  if (launchOptions[UIApplicationLaunchOptionsLocationKey] != nil) {
    [self startHeadlessService:[self getCallbackDispatcherHandle]];
    _onLocationUpdateHandle = [self getLocationCallbackHandle];
    _locationManager.pausesLocationUpdatesAutomatically =
        [self getPausesLocationUpdatesAutomatically];
    if (@available(iOS 11.0, *)) {
      _locationManager.showsBackgroundLocationIndicator =
          [self getShowsBackgroundLocationIndicator];
    }
    _locationManager.allowsBackgroundLocationUpdates = YES;
    [self->_locationManager startMonitoringSignificantLocationChanges];
    return YES;
  }
  return YES;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSArray *arguments = call.arguments;
  if ([@"monitorLocationChanges" isEqualToString:call.method]) {
    NSAssert(arguments.count == 4, @"Invalid argument count for 'monitorLocationChanges'");
    [self monitorLocationChanges:arguments];
    result(@(YES));
  } else if ([@"startHeadlessService" isEqualToString:call.method]) {
    NSAssert(arguments.count == 1, @"Invalid argument count for 'startHeadlessService'");
    [self startHeadlessService:[arguments[0] longValue]];
  } else if ([@"cancelLocationUpdates" isEqualToString:call.method]) {
    NSAssert(arguments.count == 0, @"Invalid argument count for 'cancelLocationUpdates'");
    [self stopUpdatingLocation];
    result(nil);
  } else {
    NSLog(@"Unknown method: %@\n", call.method);
    result(FlutterMethodNotImplemented);
  }
}

#pragma mark LocationManagerDelegate Methods

// Location events come in here from our LocationManager and are forwarded to
// onLocationEvent.
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
  for (CLLocation *location in locations) {
    [self onLocationEvent:location];
  }
}

#pragma mark LocationBackgroundPlugin Methods

- (instancetype)init:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  _persistentState = [NSUserDefaults standardUserDefaults];
  _locationManager = [[CLLocationManager alloc] init];
  [_locationManager setDelegate:self];
  [_locationManager requestAlwaysAuthorization];

  _headlessRunner = [[FlutterHeadlessDartRunner alloc] init];
  _registrar = registrar;

  // This is the method channel used to communicate with the UI Isolate.
  _mainChannel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/ios_background_location"
                                  binaryMessenger:[registrar messenger]];
  [registrar addMethodCallDelegate:self channel:_mainChannel];

  // This is the method channel used to communicate with
  // `_backgroundCallbackDispatcher` defined in the Dart portion of our plugin.
  // Note: we don't add a MethodCallDelegate for this channel now since our
  // BinaryMessenger needs to be initialized first, which is done in
  // `startHeadlessService` below.
  _callbackChannel = [FlutterMethodChannel
      methodChannelWithName:@"plugins.flutter.io/ios_background_location_callback"
            binaryMessenger:_headlessRunner];

  return self;
}

- (int64_t)getCallbackDispatcherHandle {
  id handle = [_persistentState objectForKey:@"callback_dispatcher_handle"];
  if (handle == nil) {
    return 0;
  }
  return [handle longLongValue];
}

- (void)setCallbackDispatcherHandle:(int64_t)handle {
  [_persistentState setObject:[NSNumber numberWithLongLong:handle]
                       forKey:@"callback_dispatcher_handle"];
}

- (int64_t)getLocationCallbackHandle {
  id handle = [_persistentState objectForKey:@"location_callback_handle"];
  if (handle == nil) {
    return 0;
  }
  return [handle longLongValue];
}

- (void)setLocationCallbackHandle:(int64_t)handle {
  [_persistentState setObject:[NSNumber numberWithLongLong:handle]
                       forKey:@"location_callback_handle"];
}

- (BOOL)getPausesLocationUpdatesAutomatically {
  return [_persistentState boolForKey:@"pauses_location_updates_automatically"];
}

- (void)setPausesLocationUpdatesAutomatically:(BOOL)pause {
  [_persistentState setBool:pause forKey:@"pauses_location_updates_automatically"];
}

- (BOOL)getShowsBackgroundLocationIndicator {
  return [_persistentState boolForKey:@"shows_background_location_indicator"];
}

- (void)setShowsBackgroundLocationIndicator:(BOOL)pause {
  [_persistentState setBool:pause forKey:@"shows_background_location_indicator"];
}

// Initializes and starts the background isolate which will process location
// events. `entrypoint` is the name of the callback to be invoked and `uri` is
// the URI of the library which contains the callback.
- (void)startHeadlessService:(int64_t)handle {
  [self setCallbackDispatcherHandle:handle];
  FlutterCallbackInformation *info = [FlutterCallbackCache lookupCallbackInformation:handle];
  NSAssert(info != nil, @"failed to find callback");
  NSString *entrypoint = info.callbackName;
  NSString *uri = info.callbackLibraryPath;
  [_headlessRunner runWithEntrypointAndCallback:entrypoint
                                     libraryUri:uri
                                     completion:^(BOOL success) {
                                       NSAssert(success, @"Unable to start background service");
                                     }];
  // The headless runner needs to be initialized before we can register it as a
  // MethodCallDelegate or else we get an illegal memory access. If we don't
  // want to make calls from `_backgroundCallDispatcher` back to native code,
  // we don't need to add a MethodCallDelegate for this channel.
  [_registrar addMethodCallDelegate:self channel:_callbackChannel];
}

// Start receiving location updates.
- (void)monitorLocationChanges:(NSArray *)arguments {
  _onLocationUpdateHandle = [arguments[0] longLongValue];
  [self setLocationCallbackHandle:_onLocationUpdateHandle];
  _locationManager.pausesLocationUpdatesAutomatically = arguments[1];
  if (@available(iOS 11.0, *)) {
    _locationManager.showsBackgroundLocationIndicator = arguments[2];
  }
  _locationManager.activityType = [arguments[3] integerValue];
  _locationManager.allowsBackgroundLocationUpdates = YES;

  [self setPausesLocationUpdatesAutomatically:_locationManager.pausesLocationUpdatesAutomatically];
  [self setShowsBackgroundLocationIndicator:_locationManager.showsBackgroundLocationIndicator];
  [self->_locationManager startMonitoringSignificantLocationChanges];
}

// Stop the location updates.
- (void)stopUpdatingLocation {
  [self->_locationManager stopUpdatingLocation];
}

// Sends location events to our `_backgroundCallDispatcher` in Dart code via
// the MethodChannel we established earlier.
- (void)onLocationEvent:(CLLocation *)location {
  [_callbackChannel invokeMethod:@"onLocationEvent"
                       arguments:@[
                         @(_onLocationUpdateHandle), @(location.timestamp.timeIntervalSince1970),
                         @(location.coordinate.latitude), @(location.coordinate.longitude),
                         @(location.horizontalAccuracy), @(location.speed)
                       ]];
}

@end
