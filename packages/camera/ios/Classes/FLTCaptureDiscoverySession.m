// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "CameraPlugin+Internal.h"

@implementation FLTCaptureDiscoverySession
+ (NSArray<NSDictionary *> *)devices:(FlutterMethodCall *)call {
  [FLTCaptureDiscoverySession validateVersion];

  if (@available(iOS 10.0, *)) {
    NSArray<NSString *> *deviceTypeStrs = call.arguments[@"deviceTypes"];

    NSMutableArray<AVCaptureDeviceType> *types = [NSMutableArray new];
    for (NSString *str in deviceTypeStrs) {
      if ([@"CaptureDeviceType.builtInWideAngleCamera" isEqualToString:str]) {
        [types addObject:AVCaptureDeviceTypeBuiltInWideAngleCamera];
      }
    }

    NSString *postionStr = call.arguments[@"position"];

    AVCaptureDevicePosition position = -1;
    if ([@"CaptureDevicePosition.front" isEqualToString:postionStr]) {
      position = AVCaptureDevicePositionFront;
    } else if ([@"CaptureDevicePosition.back" isEqualToString:postionStr]) {
      position = AVCaptureDevicePositionBack;
    } else if ([@"CaptureDevicePosition.unspecified" isEqualToString:postionStr]) {
      position = AVCaptureDevicePositionUnspecified;
    }

    NSString *mediaTypeStr = call.arguments[@"mediaType"];

    AVMediaType mediaType = nil;
    if ([@"MediaType.video" isEqualToString:mediaTypeStr]) {
      mediaType = AVMediaTypeVideo;
    }

    AVCaptureDeviceDiscoverySession *session = [AVCaptureDeviceDiscoverySession
                    discoverySessionWithDeviceTypes:types
                                          mediaType:mediaType
                                           position:position];

    NSArray<AVCaptureDevice *> *devices = session.devices;

    NSMutableArray<NSDictionary<NSString *, NSObject *> *> *deviceData =
                          [[NSMutableArray alloc] initWithCapacity:devices.count];

    for (AVCaptureDevice *device in devices) {
      [deviceData addObject:[FLTCaptureDevice serialize:device]];
    }

    return deviceData;
  }

  return nil;
}

+ (void) validateVersion {
  if (@available(iOS 10.0, *)) {
    return;
  } else {
    NSString *reason = @"Method not available on iOS version < 10.0.";
    @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
  }
}
@end
