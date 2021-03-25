// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "WifiInfoFlutterPlugin.h"

#import <CoreLocation/CoreLocation.h>
#import "FLTWifiInfoLocationHandler.h"
#import "SystemConfiguration/CaptiveNetwork.h"

#include <ifaddrs.h>

#include <arpa/inet.h>

@interface WifiInfoFlutterPlugin () <CLLocationManagerDelegate>
@property(strong, nonatomic) FLTWifiInfoLocationHandler* locationHandler;
@end

@implementation WifiInfoFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  WifiInfoFlutterPlugin* instance = [[WifiInfoFlutterPlugin alloc] init];

  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/wifi_info_flutter"
                                  binaryMessenger:[registrar messenger]];
  [registrar addMethodCallDelegate:instance channel:channel];
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

- (NSString*)getWifiName {
  return [self findNetworkInfo:@"SSID"];
}

- (NSString*)getBSSID {
  return [self findNetworkInfo:@"BSSID"];
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

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([call.method isEqualToString:@"wifiName"]) {
    result([self getWifiName]);
  } else if ([call.method isEqualToString:@"wifiBSSID"]) {
    result([self getBSSID]);
  } else if ([call.method isEqualToString:@"wifiIPAddress"]) {
    result([self getWifiIP]);
  } else if ([call.method isEqualToString:@"getLocationServiceAuthorization"]) {
    result([self convertCLAuthorizationStatusToString:[FLTWifiInfoLocationHandler
                                                          locationAuthorizationStatus]]);
  } else if ([call.method isEqualToString:@"requestLocationServiceAuthorization"]) {
    NSArray* arguments = call.arguments;
    BOOL always = [arguments.firstObject boolValue];
    __weak typeof(self) weakSelf = self;
    [self.locationHandler
        requestLocationAuthorization:always
                          completion:^(CLAuthorizationStatus status) {
                            result([weakSelf convertCLAuthorizationStatusToString:status]);
                          }];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (NSString*)convertCLAuthorizationStatusToString:(CLAuthorizationStatus)status {
  switch (status) {
    case kCLAuthorizationStatusNotDetermined: {
      return @"notDetermined";
    }
    case kCLAuthorizationStatusRestricted: {
      return @"restricted";
    }
    case kCLAuthorizationStatusDenied: {
      return @"denied";
    }
    case kCLAuthorizationStatusAuthorizedAlways: {
      return @"authorizedAlways";
    }
    case kCLAuthorizationStatusAuthorizedWhenInUse: {
      return @"authorizedWhenInUse";
    }
    default: {
      return @"unknown";
    }
  }
}

- (FLTWifiInfoLocationHandler*)locationHandler {
  if (!_locationHandler) {
    _locationHandler = [FLTWifiInfoLocationHandler new];
  }
  return _locationHandler;
}
@end
