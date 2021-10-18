// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This header is available in the Test module. Import via "@import camera.Test;"

#import <camera/CameraPlugin.h>
#import <camera/FLTThreadSafeFlutterResult.h>

/// Methods exposed for unit testing.
@interface CameraPlugin ()

/// Inject @p FlutterTextureRegistry and @p FlutterBinaryMessenger for unit testing.
- (instancetype)initWithRegistry:(NSObject<FlutterTextureRegistry> *)registry
                       messenger:(NSObject<FlutterBinaryMessenger> *)messenger
    NS_DESIGNATED_INITIALIZER;

/// Hide the default public constructor.
- (instancetype)init NS_UNAVAILABLE;

/// Exposes the [CameraPlugin handleMethodCallAsync:result:] method for unit testing.
///
/// This method should always be dispatched on a background queue to prevent deadlocks.
 
- (void)handleMethodCallAsync:(FlutterMethodCall *)call result:(FLTThreadSafeFlutterResult *)result;

/// Exposes the [CameraPlugin orientationChanged:] method for unit testing.
- (void)orientationChanged:(NSNotification *)notification;

@end
