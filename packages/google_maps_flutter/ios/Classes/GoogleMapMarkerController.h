// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GoogleMapController.h"

NS_ASSUME_NONNULL_BEGIN

// Defines marker UI options writable from Flutter.
@protocol FLTGoogleMapMarkerOptionsSink
- (void)setAlpha:(float)alpha;
- (void)setAnchor:(CGPoint)anchor;
- (void)setConsumeTapEvents:(BOOL)consume;
- (void)setDraggable:(BOOL)draggable;
- (void)setFlat:(BOOL)flat;
- (void)setIcon:(UIImage*)icon;
- (void)setInfoWindowAnchor:(CGPoint)anchor;
- (void)setInfoWindowTitle:(NSString*)title snippet:(NSString*)snippet;
- (void)setPosition:(CLLocationCoordinate2D)position;
- (void)setRotation:(CLLocationDegrees)rotation;
- (void)setVisible:(BOOL)visible;
- (void)setZIndex:(int)zIndex;
@end

// Defines marker controllable by Flutter.
@interface FLTGoogleMapMarkerController : NSObject <FLTGoogleMapMarkerOptionsSink>
@property(atomic, readonly) NSString* markerId;
- (instancetype)initMarkerWithPosition:(CLLocationCoordinate2D)position
                              markerId:(NSString*)markerId
                               mapView:(GMSMapView*)mapView;
- (BOOL)consumeTapEvents;
- (void)removeMarker;
@end

@interface FLTMarkersController : NSObject
- (instancetype)init:(FlutterMethodChannel*)methodChannel
             mapView:(GMSMapView*)mapView
           registrar:(NSObject<FlutterPluginRegistrar>*)registrar;
- (void)addMarkers:(NSArray*)markersToAdd;
- (void)changeMarkers:(NSArray*)markersToChange;
- (void)removeMarkerIds:(NSArray*)markerIdsToRemove;
- (BOOL)onMarkerTap:(NSString*)markerId;
- (void)onMarkerDragEnd:(NSString*)markerId coordinate:(CLLocationCoordinate2D)coordinate;
- (void)onInfoWindowTap:(NSString*)markerId;
@end

NS_ASSUME_NONNULL_END