// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ConnectivityPlugin.h"

#import "Reachability/Reachability.h"

#import "SystemConfiguration/CaptiveNetwork.h"
#import <CoreLocation/CoreLocation.h>


#include <ifaddrs.h>

#include <arpa/inet.h>

@interface FLTConnectivityPlugin () <FlutterStreamHandler, CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager* locationManager;
@property (copy, nonatomic) FlutterResult result;
@property (strong, nonatomic) NSString *key;
@end

@implementation FLTConnectivityPlugin {
  FlutterEventSink _eventSink;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FLTConnectivityPlugin* instance = [[FLTConnectivityPlugin alloc] init];

  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/connectivity"
                                  binaryMessenger:[registrar messenger]];
  [registrar addMethodCallDelegate:instance channel:channel];

  FlutterEventChannel* streamChannel =
      [FlutterEventChannel eventChannelWithName:@"plugins.flutter.io/connectivity_status"
                                binaryMessenger:[registrar messenger]];
  [streamChannel setStreamHandler:instance];
}

- (NSString*)findNetworkInfo:(NSString*)key {
  NSString* info = nil;
  NSArray* interfaceNames = (__bridge_transfer id)CNCopySupportedInterfaces();
  for (NSString* interfaceName in interfaceNames) {
    NSDictionary* networkInfo =
        (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName);
    if (networkInfo[key]) {
      info = networkInfo[key];
    }
  }
  return info;
}

- (void)requetNetworkInfo:(NSString *)key result:(FlutterResult)result {

  CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
  switch (status) {
    case kCLAuthorizationStatusNotDetermined: {
      self.key = key;
      self.result = result;
      [self.locationManager requestAlwaysAuthorization];
      return;
    }
    default: {
      result([self findNetworkInfo:key]);
      break;
    }
  }
}

- (void)getWifiNameWithResult:(FlutterResult)result {
  [self requetNetworkInfo:@"SSID" result:result];
}

- (void)getBSSIDWithResult:(FlutterResult)result {
  [self requetNetworkInfo:@"BSSID" result:result];
}

- (NSString*)getWifiIP {
  NSString* address = @"error";
  struct ifaddrs* interfaces = NULL;
  struct ifaddrs* temp_addr = NULL;
  int success = 0;

  // retrieve the current interfaces - returns 0 on success
  success = getifaddrs(&interfaces);
  if (success == 0) {
    // Loop through linked list of interfaces
    temp_addr = interfaces;
    while (temp_addr != NULL) {
      if (temp_addr->ifa_addr->sa_family == AF_INET) {
        // Check if interface is en0 which is the wifi connection on the iPhone
        if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
          // Get NSString from C String
          address = [NSString
              stringWithUTF8String:inet_ntoa(((struct sockaddr_in*)temp_addr->ifa_addr)->sin_addr)];
        }
      }

      temp_addr = temp_addr->ifa_next;
    }
  }

  // Free memory
  freeifaddrs(interfaces);

  return address;
}

- (NSString*)statusFromReachability:(Reachability*)reachability {
  NetworkStatus status = [reachability currentReachabilityStatus];
  switch (status) {
    case NotReachable:
      return @"none";
    case ReachableViaWiFi:
      return @"wifi";
    case ReachableViaWWAN:
      return @"mobile";
  }
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([call.method isEqualToString:@"check"]) {
    // This is supposed to be quick. Another way of doing this would be to
    // signup for network
    // connectivity changes. However that depends on the app being in background
    // and the code
    // gets more involved. So for now, this will do.
    result([self statusFromReachability:[Reachability reachabilityForInternetConnection]]);
  } else if ([call.method isEqualToString:@"wifiName"]) {
    [self getWifiNameWithResult:result];
  } else if ([call.method isEqualToString:@"wifiBSSID"]) {
    [self getBSSIDWithResult:result];
  } else if ([call.method isEqualToString:@"wifiIPAddress"]) {
    result([self getWifiIP]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)onReachabilityDidChange:(NSNotification*)notification {
  Reachability* curReach = [notification object];
  _eventSink([self statusFromReachability:curReach]);
}

#pragma mark FlutterStreamHandler impl

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
  _eventSink = eventSink;
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(onReachabilityDidChange:)
                                               name:kReachabilityChangedNotification
                                             object:nil];
  [[Reachability reachabilityForInternetConnection] startNotifier];
  return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
  [[Reachability reachabilityForInternetConnection] stopNotifier];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  _eventSink = nil;
  return nil;
}

#pragma mark - CLLocationManagerDelegate

- (CLLocationManager *)locationManager {
 if (!_locationManager) {
   _locationManager = [CLLocationManager new];
   _locationManager.delegate = self;
 }
 return _locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  self.result([self findNetworkInfo:self.key]);
}

@end
