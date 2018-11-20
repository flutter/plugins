// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GoogleMapMarkerController.h"

// Defines events to be sent to Flutter.
@protocol FLTGoogleMapDelegate
- (void)onCameraMoveStartedOnMap:(id)mapId gesture:(BOOL)gesture;
- (void)onCameraMoveOnMap:(id)mapId cameraPosition:(GMSCameraPosition*)cameraPosition;
- (void)onCameraIdleOnMap:(id)mapId;
- (void)onMarkerTappedOnMap:(id)mapId marker:(NSString*)markerId;
- (void)onInfoWindowTappedOnMap:(id)mapId marker:(NSString*)markerId;
@end

// Defines map UI options writable from Flutter.
@protocol FLTGoogleMapOptionsSink
- (void)setCamera:(GMSCameraPosition*)camera;
- (void)setCameraTargetBounds:(GMSCoordinateBounds*)bounds;
- (void)setCompassEnabled:(BOOL)enabled;
- (void)setMapType:(GMSMapViewType)type;
- (void)setMinZoom:(float)minZoom maxZoom:(float)maxZoom;
- (void)setRotateGesturesEnabled:(BOOL)enabled;
- (void)setScrollGesturesEnabled:(BOOL)enabled;
- (void)setTiltGesturesEnabled:(BOOL)enabled;
- (void)setTrackCameraPosition:(BOOL)enabled;
- (void)setZoomGesturesEnabled:(BOOL)enabled;
@end

// Defines map overlay controllable from Flutter.
@interface FLTGoogleMapController
    : NSObject <GMSMapViewDelegate, FLTGoogleMapOptionsSink, FlutterPlatformView>
@property(atomic) id<FLTGoogleMapDelegate> delegate;
@property(atomic, readonly) id mapId;
- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
                    registrar:(NSObject<FlutterPluginRegistrar>*)registrar;
- (void)addToView:(UIView*)view;
- (void)removeFromView;
- (void)showAtX:(CGFloat)x Y:(CGFloat)y;
- (void)hide;
- (void)animateWithCameraUpdate:(GMSCameraUpdate*)cameraUpdate;
- (void)moveWithCameraUpdate:(GMSCameraUpdate*)cameraUpdate;
- (GMSCameraPosition*)cameraPosition;
- (NSString*)addMarkerWithPosition:(CLLocationCoordinate2D)position;
- (FLTGoogleMapMarkerController*)markerWithId:(NSString*)markerId;
- (void)removeMarkerWithId:(NSString*)markerId;
@end

// Allows the engine to create new Google Map instances.
@interface FLTGoogleMapFactory : NSObject <FlutterPlatformViewFactory>
- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;
@end
