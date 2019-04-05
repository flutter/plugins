// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GoogleMapController.h"

// Defines polyline UI options writable from Flutter.
@protocol FLTGoogleMapPolylineOptionsSink
- (void)setConsumeTapEvents:(BOOL)consume;
- (void)setPoints:(GMSPath*)points;
- (void)setClickable:(BOOL)clickable;
- (void)setColor:(UIColor*)color;
- (void)setGeodesic:(BOOL)geodesic;
- (void)setPattern:(NSArray<GMSStyleSpan*>*)pattern;
- (void)setVisible:(BOOL)visible;
- (void)setWidth:(CGFloat)width;
- (void)setZIndex:(int)zIndex;
@end

// Defines polyline controllable by Flutter.
@interface FLTGoogleMapPolylineController : NSObject <FLTGoogleMapPolylineOptionsSink>
@property(atomic, readonly) NSString* polylineId;
- (instancetype)initWithPath:(GMSPath*)path
                  polylineId:(NSString*)polylineId
                     mapView:(GMSMapView*)mapView;
- (BOOL)consumeTapEvents;
- (void)removePolyline;
@end

@interface FLTPolylinesController : NSObject
- (instancetype)init:(FlutterMethodChannel*)methodChannel
             mapView:(GMSMapView*)mapView
           registrar:(NSObject<FlutterPluginRegistrar>*)registrar;
- (void)addPolylines:(NSArray*)polylinesToAdd;
- (void)changePolylines:(NSArray*)polylinesToChange;
- (void)removePolylineIds:(NSArray*)polylineIdsToRemove;
- (BOOL)onPolylineTap:(NSString*)polylineId;
@end
