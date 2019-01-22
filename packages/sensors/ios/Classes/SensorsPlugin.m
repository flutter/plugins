// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "SensorsPlugin.h"
#import <CoreMotion/CoreMotion.h>

@implementation FLTSensorsPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FLTAccelerometerStreamHandler* accelerometerStreamHandler =
    [[FLTAccelerometerStreamHandler alloc] init];
    FlutterEventChannel* accelerometerChannel =
    [FlutterEventChannel eventChannelWithName:@"plugins.flutter.io/sensors/accelerometer"
                              binaryMessenger:[registrar messenger]];
    [accelerometerChannel setStreamHandler:accelerometerStreamHandler];
    
    FLTUserAccelGravityStreamHandler* userAccelerometerGravityStreamHandler =
    [[FLTUserAccelGravityStreamHandler alloc] init];
    FlutterEventChannel* userAccelerometerGravityChannel =
    [FlutterEventChannel eventChannelWithName:@"plugins.flutter.io/sensors/user_accel_gravity"
                              binaryMessenger:[registrar messenger]];
    [userAccelerometerGravityChannel setStreamHandler:userAccelerometerGravityStreamHandler];
    
    FLTGyroscopeStreamHandler* gyroscopeStreamHandler = [[FLTGyroscopeStreamHandler alloc] init];
    FlutterEventChannel* gyroscopeChannel =
    [FlutterEventChannel eventChannelWithName:@"plugins.flutter.io/sensors/gyroscope"
                              binaryMessenger:[registrar messenger]];
    [gyroscopeChannel setStreamHandler:gyroscopeStreamHandler];
}

@end

const double GRAVITY = -9.8;
CMMotionManager* _motionManager;

void _initMotionManager() {
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
    }
}

static void sendData3(Float64 x, Float64 y, Float64 z, FlutterEventSink sink) {
    NSMutableData* event = [NSMutableData dataWithCapacity:3 * sizeof(Float64)];
    [event appendBytes:&x length:sizeof(Float64)];
    [event appendBytes:&y length:sizeof(Float64)];
    [event appendBytes:&z length:sizeof(Float64)];
    sink([FlutterStandardTypedData typedDataWithFloat64:event]);
}

static void sendData6(Float64 x1, Float64 y1, Float64 z1, Float64 x2, Float64 y2, Float64 z2, FlutterEventSink sink) {
    NSMutableData* event = [NSMutableData dataWithCapacity:6 * sizeof(Float64)];
    [event appendBytes:&x1 length:sizeof(Float64)];
    [event appendBytes:&y1 length:sizeof(Float64)];
    [event appendBytes:&z1 length:sizeof(Float64)];
    [event appendBytes:&x2 length:sizeof(Float64)];
    [event appendBytes:&y2 length:sizeof(Float64)];
    [event appendBytes:&z2 length:sizeof(Float64)];
    sink([FlutterStandardTypedData typedDataWithFloat64:event]);
}

@implementation FLTAccelerometerStreamHandler

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    _initMotionManager();
    [_motionManager
     startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
     withHandler:^(CMAccelerometerData* accelerometerData, NSError* error) {
         CMAcceleration acceleration = accelerometerData.acceleration;
         // Multiply by gravity, and adjust sign values to
         // align with Android.
         sendData3(acceleration.x * GRAVITY, acceleration.y * GRAVITY,
                   acceleration.z * GRAVITY, eventSink);
     }];
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    [_motionManager stopAccelerometerUpdates];
    return nil;
}

@end

@implementation FLTUserAccelGravityStreamHandler

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    _initMotionManager();
    [_motionManager
     startDeviceMotionUpdatesToQueue:[[NSOperationQueue alloc] init]
     withHandler:^(CMDeviceMotion* data, NSError* error) {
         CMAcceleration acceleration = data.userAcceleration;
         CMAcceleration gravity = data.gravity;
         // Multiply by gravity, and adjust sign values to align with Android.
         sendData6(acceleration.x * GRAVITY,
                   acceleration.y * GRAVITY,
                   acceleration.z * GRAVITY,
                   gravity.x * GRAVITY,
                   gravity.y * GRAVITY,
                   gravity.z * GRAVITY,
                   eventSink);
     }];
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    [_motionManager stopDeviceMotionUpdates];
    return nil;
}

@end

@implementation FLTGyroscopeStreamHandler

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    _initMotionManager();
    [_motionManager
     startGyroUpdatesToQueue:[[NSOperationQueue alloc] init]
     withHandler:^(CMGyroData* gyroData, NSError* error) {
         CMRotationRate rotationRate = gyroData.rotationRate;
         sendData3(rotationRate.x, rotationRate.y, rotationRate.z, eventSink);
     }];
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    [_motionManager stopGyroUpdates];
    return nil;
}

@end

