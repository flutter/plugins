// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file

#import "GeofencingPlugin.h"

#import <CoreLocation/CoreLocation.h>

@implementation GeofencingPlugin {
  CLLocationManager *_locationManager;
  FlutterHeadlessDartRunner *_headlessRunner;
  FlutterMethodChannel *_callbackChannel;
  FlutterMethodChannel *_mainChannel;
  NSObject<FlutterPluginRegistrar> *_registrar;
  NSUserDefaults *_persistentState;
  int64_t _onLocationUpdateHandle;
}

static const int kEnterEvent = 1;
static const int kExitEvent = 2;
static const NSString *kCallbackMapping = @"geofence_region_callback_mapping";
static GeofencingPlugin *instance = nil;

#pragma mark FlutterPlugin Methods

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  @synchronized(self) {
    if (instance == nil) {
      NSLog(@"Registering with registrar");
      instance = [[GeofencingPlugin alloc] init:registrar];
      [registrar addApplicationDelegate:instance];
    }
  }
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSArray *arguments = call.arguments;
  if ([@"GeofencingPlugin.initializeService" isEqualToString:call.method]) {
    NSAssert(arguments.count == 1,
             @"Invalid argument count for 'GeofencingPlugin.initializeService'");
    [self startGeofencingService:[arguments[0] longValue]];
    result(@(YES));
  } else if ([@"GeofencingService.initialized" isEqualToString:call.method]) {
    // Ignored on iOS.
    result(nil);
  } else if ([@"GeofencingPlugin.registerGeofence" isEqualToString:call.method]) {
    [self registerGeofence:arguments];
    result(@(YES));
  } else if ([@"GeofencingPlugin.removeGeofence" isEqualToString:call.method]) {
    result(@([self removeGeofence:arguments]));
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Check to see if we're being launched due to a location event.
  if (launchOptions[UIApplicationLaunchOptionsLocationKey] != nil) {
    // Restart the headless service.
    [self startGeofencingService:[self getCallbackDispatcherHandle]];
  }

  // Note: if we return NO, this vetos the launch of the application.
  return YES;
}

#pragma mark LocationManagerDelegate Methods
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
  NSLog(@"Entered Location");
  [self sendLocationEvent:region eventType:kEnterEvent];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
  NSLog(@"Exited location");
  [self sendLocationEvent:region eventType:kExitEvent];
}

- (void)locationManager:(CLLocationManager *)manager
    monitoringDidFailForRegion:(CLRegion *)region
                     withError:(NSError *)error {
  NSLog(@"Monitoring error %@: %@", error.code, error.localizedDescription);
}

#pragma mark GeofencingPlugin Methods

- (void)sendLocationEvent:(CLRegion *)region eventType:(int)event {
  NSAssert([region isKindOfClass:[CLCircularRegion class]], @"region must be CLCircularRegion");
  CLLocationCoordinate2D center = region.center;
  int64_t handle = [self getCallbackHandleForRegionId:region.identifier];
  [_callbackChannel
      invokeMethod:@""
         arguments:@[
           @(handle), @[ region.identifier ], @[ @(center.latitude), @(center.longitude) ], @(event)
         ]];
}

- (instancetype)init:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  _persistentState = [NSUserDefaults standardUserDefaults];
  _locationManager = [[CLLocationManager alloc] init];
  [_locationManager setDelegate:self];
  [_locationManager requestAlwaysAuthorization];
  _locationManager.allowsBackgroundLocationUpdates = YES;

  _headlessRunner = [[FlutterHeadlessDartRunner alloc] init];
  _registrar = registrar;

  _mainChannel = [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/geofencing_plugin"
                                             binaryMessenger:[registrar messenger]];
  [registrar addMethodCallDelegate:self channel:_mainChannel];

  _callbackChannel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/geofencing_plugin_background"
                                  binaryMessenger:_headlessRunner];
  return self;
}

- (void)startGeofencingService:(int64_t)handle {
  NSLog(@"Initializing GeofencingService");
  [self setCallbackDispatcherHandle:handle];
  FlutterCallbackInformation *info = [FlutterCallbackCache lookupCallbackInformation:handle];
  NSAssert(info != nil, @"failed to find callback");
  NSString *entrypoint = info.callbackName;
  NSString *uri = info.callbackLibraryPath;
  [_headlessRunner runWithEntrypointAndLibraryUri:entrypoint libraryUri:uri];
  [_registrar addMethodCallDelegate:self channel:_callbackChannel];
}

- (void)registerGeofence:(NSArray *)arguments {
  NSLog(@"RegisterGeofence: %@", arguments);
  int64_t callbackHandle = [arguments[0] longLongValue];
  NSString *identifier = arguments[1];
  double latitude = [arguments[2] doubleValue];
  double longitude = [arguments[3] doubleValue];
  double radius = [arguments[4] doubleValue];
  CLCircularRegion *region =
      [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(latitude, longitude)
                                        radius:radius
                                    identifier:identifier];
  region.notifyOnEntry = YES;
  region.notifyOnExit = YES;
  [self setCallbackHandleForRegionId:callbackHandle regionId:identifier];
  [self->_locationManager startMonitoringForRegion:region];
}

- (BOOL)removeGeofence:(NSArray *)arguments {
  NSLog(@"RemoveGeofence: %@", arguments);
  NSString *identifier = arguments[0];
  for (CLRegion *region in [self->_locationManager monitoredRegions]) {
    if ([region.identifier isEqual:identifier]) {
      [self->_locationManager stopMonitoringForRegion:region];
      [self removeCallbackHandleForRegionId:identifier];
      return YES;
    }
  }
  return NO;
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

- (NSMutableDictionary *)getRegionCallbackMapping {
  const NSString *key = kCallbackMapping;
  NSMutableDictionary *callbackDict = [_persistentState dictionaryForKey:key];
  if (callbackDict == nil) {
    callbackDict = @{};
    [_persistentState setObject:callbackDict forKey:key];
  }
  return [callbackDict mutableCopy];
}

- (void)setRegionCallbackMapping:(NSMutableDictionary *)mapping {
  const NSString *key = kCallbackMapping;
  NSAssert(mapping != nil, @"mapping cannot be nil");
  [_persistentState setObject:mapping forKey:key];
}

- (int64_t)getCallbackHandleForRegionId:(NSString *)identifier {
  NSMutableDictionary *mapping = [self getRegionCallbackMapping];
  id handle = [mapping objectForKey:identifier];
  if (handle == nil) {
    return 0;
  }
  return [handle longLongValue];
}

- (void)setCallbackHandleForRegionId:(int64_t)handle regionId:(NSString *)identifier {
  NSMutableDictionary *mapping = [self getRegionCallbackMapping];
  [mapping setObject:[NSNumber numberWithLongLong:handle] forKey:identifier];
  [self setRegionCallbackMapping:mapping];
}

- (void)removeCallbackHandleForRegionId:(NSString *)identifier {
  NSMutableDictionary *mapping = [self getRegionCallbackMapping];
  [mapping removeObjectForKey:identifier];
  [self setRegionCallbackMapping:mapping];
}

@end
