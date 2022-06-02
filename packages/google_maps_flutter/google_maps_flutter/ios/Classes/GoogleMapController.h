// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GoogleMapCircleController.h"
#import "GoogleMapMarkerController.h"
#import "GoogleMapPolygonController.h"
#import "GoogleMapPolylineController.h"

NS_ASSUME_NONNULL_BEGIN

// Defines map overlay controllable from Flutter.
@interface FLTGoogleMapController : NSObject <GMSMapViewDelegate, FlutterPlatformView>
- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(nullable id)args
                    registrar:(NSObject<FlutterPluginRegistrar> *)registrar;
- (void)showAtOrigin:(CGPoint)origin;
- (void)hide;
- (void)animateWithCameraUpdate:(GMSCameraUpdate *)cameraUpdate;
- (void)moveWithCameraUpdate:(GMSCameraUpdate *)cameraUpdate;
- (nullable GMSCameraPosition *)cameraPosition;
@end

// Allows the engine to create new Google Map instances.
@interface FLTGoogleMapFactory : NSObject <FlutterPlatformViewFactory>
- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar;
@end

NS_ASSUME_NONNULL_END
