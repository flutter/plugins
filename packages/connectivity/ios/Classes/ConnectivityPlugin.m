// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ConnectivityPlugin.h"

#import "Reachability/Reachability.h"

#import <CoreLocation/CoreLocation.h>
#import "FLTConnectivityLocationHandler.h"
#import "SystemConfiguration/CaptiveNetwork.h"

#include <ifaddrs.h>

#include <arpa/inet.h>

<<<<<<< HEAD
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@interface FLTConnectivityPlugin () <FlutterStreamHandler>
=======
@interface FLTConnectivityPlugin () <FlutterStreamHandler, CLLocationManagerDelegate>

@property(strong, nonatomic) FLTConnectivityLocationHandler* locationHandler;

>>>>>>> 0a7535d1cd7119767d8d2506b2c9e3742f585fa8
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

- (NSString*)getConnectionSubtype:(Reachability*)reachability {
  if ([reachability currentReachabilityStatus] == NotReachable) {
    return @"none";
  }

  CTTelephonyNetworkInfo* netinfo = [[CTTelephonyNetworkInfo alloc] init];
  NSString* carrierType = netinfo.currentRadioAccessTechnology;

  if ([carrierType isEqualToString:CTRadioAccessTechnologyGPRS]) {
    return @"gprs";
  } else if ([carrierType isEqualToString:CTRadioAccessTechnologyEdge]) {
    return @"edge";
  } else if ([carrierType isEqualToString:CTRadioAccessTechnologyWCDMA]) {
    return @"cdma";
  } else if ([carrierType isEqualToString:CTRadioAccessTechnologyHSDPA]) {
    return @"hsdpa";
  } else if ([carrierType isEqualToString:CTRadioAccessTechnologyHSUPA]) {
    return @"hsupa";
  } else if ([carrierType isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
    return @"cdma";
  } else if ([carrierType isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]) {
    return @"evdo_0";
  } else if ([carrierType isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]) {
    return @"evdo_a";
  } else if ([carrierType isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]) {
    return @"evdo_b";
  } else if ([carrierType isEqualToString:CTRadioAccessTechnologyeHRPD]) {
    return @"ehrpd";
  } else if ([carrierType isEqualToString:CTRadioAccessTechnologyLTE]) {
    return @"lte";
  }
  return @"unknown";
}

- (NSString*)statusFromReachability:(Reachability*)reachability {
  NetworkStatus status = [reachability currentReachabilityStatus];
  NSString* subtype = [self getConnectionSubtype:[Reachability reachabilityForInternetConnection]];
  switch (status) {
    case NotReachable:
      return [NSString stringWithFormat:@"%@,%@", @"none", subtype];
    case ReachableViaWiFi:
      return [NSString stringWithFormat:@"%@,%@", @"wifi", subtype];
    case ReachableViaWWAN:
      return [NSString stringWithFormat:@"%@,%@", @"mobile", subtype];
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
    result([self getWifiName]);
  } else if ([call.method isEqualToString:@"wifiBSSID"]) {
    result([self getBSSID]);
  } else if ([call.method isEqualToString:@"wifiIPAddress"]) {
    result([self getWifiIP]);
<<<<<<< HEAD
  } else if ([call.method isEqualToString:@"subtype"]) {
    result([self getConnectionSubtype:[Reachability reachabilityForInternetConnection]]);

=======
  } else if ([call.method isEqualToString:@"getLocationServiceAuthorization"]) {
    result([self convertCLAuthorizationStatusToString:[FLTConnectivityLocationHandler
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
>>>>>>> 0a7535d1cd7119767d8d2506b2c9e3742f585fa8
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)onReachabilityDidChange:(NSNotification*)notification {
  Reachability* curReach = [notification object];
  _eventSink([self statusFromReachability:curReach]);
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
    default: { return @"unknown"; }
  }
}

- (FLTConnectivityLocationHandler*)locationHandler {
  if (!_locationHandler) {
    _locationHandler = [FLTConnectivityLocationHandler new];
  }
  return _locationHandler;
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

@end
