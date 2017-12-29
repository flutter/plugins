// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>

@interface SensorsPlugin : NSObject<FlutterPlugin>
@end

@interface AccelerometerStreamHandler : NSObject<FlutterStreamHandler>
@end

@interface GyroscopeStreamHandler : NSObject<FlutterStreamHandler>
@end
