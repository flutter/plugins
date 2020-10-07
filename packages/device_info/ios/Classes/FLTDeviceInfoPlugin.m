// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTDeviceInfoPlugin.h"
#import <sys/utsname.h>

@implementation FLTDeviceInfoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/device_info"
                                  binaryMessenger:[registrar messenger]];
  FLTDeviceInfoPlugin* instance = [[FLTDeviceInfoPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getIosDeviceInfo" isEqualToString:call.method]) {
    UIDevice* device = [UIDevice currentDevice];
    struct utsname un;
    uname(&un);

    result(@{
      @"name" : [device name],
      @"systemName" : [device systemName],
      @"systemVersion" : [device systemVersion],
      @"model" : [device model],
      @"localizedModel" : [device localizedModel],
      @"identifierForVendor" : [[device identifierForVendor] UUIDString],
      @"isPhysicalDevice" : [self isDevicePhysical],
      @"utsname" : @{
        @"sysname" : @(un.sysname),
        @"nodename" : @(un.nodename),
        @"release" : @(un.release),
        @"version" : @(un.version),
        @"machine" : @(un.machine),
      },
      @"screenWidthPixel" : [self getScreenWidth],
      @"screenHeightPixel" : [self getScreenHeight],
      @"language" : [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode],
      @"country" : [self getCountryCode]
    });
  } else {
    result(FlutterMethodNotImplemented);
  }
}

// return value is false if code is run on a simulator
- (NSString*)isDevicePhysical {
#if TARGET_OS_SIMULATOR
  NSString* isPhysicalDevice = @"false";
#else
  NSString* isPhysicalDevice = @"true";
#endif

  return isPhysicalDevice;
}

// The country code of the device Locale
- (NSString*)getCountryCode {
  NSString* country = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
  if (country != nil) {
    return country;
  } else {
    return @"";
  }
}

// The absolute width of the available display size in pixels.
- (NSNumber*)getScreenWidth {
  CGRect screenBounds = [[UIScreen mainScreen] bounds];
  CGFloat screenScale = [[UIScreen mainScreen] scale];
  CGFloat width = screenBounds.size.width * screenScale;
  return [NSNumber numberWithInt:(NSInteger)width];
}

// The absolute height of the available display size in pixels.
- (NSNumber*)getScreenHeight {
  CGRect screenBounds = [[UIScreen mainScreen] bounds];
  CGFloat screenScale = [[UIScreen mainScreen] scale];
  CGFloat height = screenBounds.size.height * screenScale;
  return [NSNumber numberWithInt:(NSInteger)height];
}


@end
