// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GoogleMapCircleController.h"
#import "GoogleMapMarkerController.h"
<<<<<<< HEAD

// Defines events to be sent to Flutter.
@protocol FLTGoogleMapDelegate
- (void)onCameraMoveStartedOnMap:(id)mapId gesture:(BOOL)gesture;
- (void)onCameraMoveOnMap:(id)mapId cameraPosition:(GMSCameraPosition*)cameraPosition;
- (void)onCameraIdleOnMap:(id)mapId;
- (void)onMarkerTappedOnMap:(id)mapId marker:(NSString*)markerId;
- (void)onInfoWindowTappedOnMap:(id)mapId marker:(NSString*)markerId;
@end
=======
#import "GoogleMapPolygonController.h"
#import "GoogleMapPolylineController.h"
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a

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
<<<<<<< HEAD
=======
- (void)setMyLocationEnabled:(BOOL)enabled;
- (void)setMyLocationButtonEnabled:(BOOL)enabled;
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
@end

// Defines map overlay controllable from Flutter.
@interface FLTGoogleMapController : NSObject<GMSMapViewDelegate, FLTGoogleMapOptionsSink>
@property(atomic) id<FLTGoogleMapDelegate> delegate;
@property(atomic, readonly) id mapId;
+ (instancetype)controllerWithWidth:(CGFloat)width
                             height:(CGFloat)height
                             camera:(GMSCameraPosition*)camera;
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
