// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>

@interface FLTSensorsPlugin : NSObject <FlutterPlugin>
@end

@interface FLTUserAccelStreamHandler : NSObject <FlutterStreamHandler>
@end

@interface FLTAccelerometerStreamHandler : NSObject <FlutterStreamHandler>
@end

@interface FLTGyroscopeStreamHandler : NSObject <FlutterStreamHandler>
@end
