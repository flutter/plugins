// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GoogleMapController.h"

// Defines ground overlay UI options writable from Flutter.
@protocol FLTGoogleMapGroundOverlayOptionsSink
- (void)setBearing:(CLLocationDirection)bearing;
- (void)setBitmapDescriptor:(UIImage*)bd;
- (void)setBounds:(GMSCoordinateBounds*)bounds;
- (void)setConsumeTapEvents:(BOOL)consume;
- (void)setLocation:(CLLocationCoordinate2D)location width:(CGFloat)width height:(CGFloat)height;
- (void)setOpacity:(float)opacity;
- (void)setVisible:(BOOL)visible;
- (void)setZIndex:(int)zIndex;
@end

// Defines ground overlay controllable by Flutter.
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
