// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "SensorsPlugin.h"
#import <CoreMotion/CoreMotion.h>

@implementation SensorsPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  AccelerometerStreamHandler* accelerometerStreamHandler =
      [[AccelerometerStreamHandler alloc] init];
  FlutterEventChannel* accelerometerChannel =
      [FlutterEventChannel eventChannelWithName:@"plugins.flutter.io/accelerometer"
                                binaryMessenger:[registrar messenger]];
  [accelerometerChannel setStreamHandler:accelerometerStreamHandler];

  GyroscopeStreamHandler* gyroscopeStreamHandler = [[GyroscopeStreamHandler alloc] init];
  FlutterEventChannel* gyroscopeChannel =
      [FlutterEventChannel eventChannelWithName:@"plugins.flutter.io/gyroscope"
                                binaryMessenger:[registrar messenger]];
  [gyroscopeChannel setStreamHandler:gyroscopeStreamHandler];
}

@end

const double GRAVITY = 9.8;
CMMotionManager* _motionManager;

void _initMotionManager() {
  if (!_motionManager) {
    _motionManager = [[CMMotionManager alloc] init];
  }
}

@implementation AccelerometerStreamHandler

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
  _initMotionManager();
  [_motionManager
      startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
                           withHandler:^(CMAccelerometerData* accelerometerData, NSError* error) {
                             CMAcceleration acceleration = accelerometerData.acceleration;
                             // Multiply by gravity, and adjust sign values to
                             // align with Android.
                             NSArray* accelerationValues = @[
                               @(-acceleration.x * GRAVITY), @(-acceleration.y * GRAVITY),
                               @(-acceleration.z * GRAVITY)
                             ];
                             eventSink(accelerationValues);
                           }];
  return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
  [_motionManager stopAccelerometerUpdates];
  return nil;
}

@end

@implementation GyroscopeStreamHandler

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
  _initMotionManager();
  [_motionManager startGyroUpdatesToQueue:[[NSOperationQueue alloc] init]
                              withHandler:^(CMGyroData* gyroData, NSError* error) {
                                CMRotationRate rotationRate = gyroData.rotationRate;
                                NSArray* gyroscopeValues =
                                    @[ @(rotationRate.x), @(rotationRate.y), @(rotationRate.z) ];
                                eventSink(gyroscopeValues);
                              }];
  return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
  [_motionManager stopGyroUpdates];
  return nil;
}

@end
