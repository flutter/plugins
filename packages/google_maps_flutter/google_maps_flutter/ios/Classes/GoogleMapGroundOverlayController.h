// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>

// Defines circle UI options writable from Flutter.
@protocol FLTGoogleMapGroundOverlayOptionsSink
- (void)setConsumeTapEvents:(BOOL)consume;
- (void)setVisible:(BOOL)visible;
- (void)setZIndex:(int)zIndex;
- (void)setLocation:(CLLocationCoordinate2D)location width:(CGFloat)width height:(CGFloat)height bounds:(GMSCoordinateBounds*)bounds;
- (void)setBitmapDescriptor:(UIImage*)bd;
- (void)setBearing:(CLLocationDirection)bearing;
- (void)setTransparency:(float)transparency;
@end

// Defines circle controllable by Flutter.
@interface FLTGoogleMapGroundOverlayController : NSObject <FLTGoogleMapGroundOverlayOptionsSink>
@property(atomic, readonly) NSString* groundOverlayId;
- (instancetype)initGroundOverlayWithPosition:(CLLocationCoordinate2D)position
                              icon:(UIImage*)icon
                              zoomLevel:(CGFloat)zoomLevel
                              groundOverlayId:(NSString*)groundOverlayId
                               mapView:(GMSMapView*)mapView;
- (instancetype)initGroundOverlayWithBounds:(GMSCoordinateBounds*)bounds
                              icon:(UIImage*)icon
                              groundOverlayId:(NSString*)groundOverlayId
                               mapView:(GMSMapView*)mapView;
- (BOOL)consumeTapEvents;
- (void)removeGroundOverlay;
@end

@interface FLTGroundOverlaysController : NSObject
- (instancetype)init:(FlutterMethodChannel*)methodChannel
             mapView:(GMSMapView*)mapView
           registrar:(NSObject<FlutterPluginRegistrar>*)registrar;
- (void)addGroundOverlays:(NSArray*)groundOverlaysToAdd;
- (void)changeGroundOverlays:(NSArray*)groundOverlaysToChange;
- (void)removeGroundOverlayIds:(NSArray*)groundOverlayIdsToRemove;
- (void)onGroundOverlayTap:(NSString*)groundOverlayId;
- (bool)hasGroundOverlayWithId:(NSString*)groundOverlayId;
@end
