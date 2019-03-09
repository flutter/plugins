// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "LocationBackgroundPlugin.h"

#import <CoreLocation/CoreLocation.h>

@implementation LocationBackgroundPlugin {
  CLLocationManager *_locationManager;
  FlutterEngine *_headlessEngine;
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

// When iOS relaunches us due to a significant location change, we need to
// reinitialize our plugin state. This includes relaunching the headless
// service, retrieving our cached callback handles and location manager
// settings, and restarting the location manager to actually receive the
// location event.
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Check to see if we're being launched due to a location event.
  if (launchOptions[UIApplicationLaunchOptionsLocationKey] != nil) {
    // Restart the headless service.
    [self startHeadlessService:[self getCallbackDispatcherHandle]];
    // Grab our callback handles and location manager state.
    _onLocationUpdateHandle = [self getLocationCallbackHandle];
    _locationManager.pausesLocationUpdatesAutomatically =
        [self getPausesLocationUpdatesAutomatically];
    if (@available(iOS 11.0, *)) {
      _locationManager.showsBackgroundLocationIndicator =
          [self getShowsBackgroundLocationIndicator];
    }
    if (@available(iOS 9.0, *)) {
      _locationManager.allowsBackgroundLocationUpdates = YES;
    }
    // Finally, restart monitoring for location changes to get our location.
    [self->_locationManager startMonitoringSignificantLocationChanges];
  }

  // Note: if we return NO, this vetos the launch of the application.
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

  _headlessEngine = [[FlutterEngine alloc] initWithName:@"io.flutter.plugins.location_background"
                                                project:nil];
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
            binaryMessenger:_headlessEngine];
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
// events. `handle` is the handle to the callback dispatcher which we specified
// in the Dart portion of the plugin.
- (void)startHeadlessService:(int64_t)handle {
  [self setCallbackDispatcherHandle:handle];

  // Lookup the information for our callback dispatcher from the callback cache.
  // This cache is populated when `PluginUtilities.getCallbackHandle` is called
  // and the resulting handle maps to a `FlutterCallbackInformation` object.
  // This object contains information needed by the engine to start a headless
  // runner, which includes the callback name as well as the path to the file
  // containing the callback.
  FlutterCallbackInformation *info = [FlutterCallbackCache lookupCallbackInformation:handle];
  NSAssert(info != nil, @"failed to find callback");
  NSString *entrypoint = info.callbackName;
  NSString *uri = info.callbackLibraryPath;

  // Here we actually launch the background isolate to start executing our
  // callback dispatcher, `_backgroundCallbackDispatcher`, in Dart.
  [_headlessEngine runWithEntrypoint:entrypoint libraryURI:uri];

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
    [self setShowsBackgroundLocationIndicator:_locationManager.showsBackgroundLocationIndicator];
  }
  _locationManager.activityType = [arguments[3] integerValue];
  if (@available(iOS 9.0, *)) {
    _locationManager.allowsBackgroundLocationUpdates = YES;
  }

  [self setPausesLocationUpdatesAutomatically:_locationManager.pausesLocationUpdatesAutomatically];
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
