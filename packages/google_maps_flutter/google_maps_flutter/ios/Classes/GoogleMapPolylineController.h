// Copyright 2018 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>

// Defines polyline UI options writable from Flutter.
@protocol FLTGoogleMapPolylineOptionsSink
- (void)setConsumeTapEvents:(BOOL)consume;
- (void)setVisible:(BOOL)visible;
- (void)setColor:(UIColor*)color;
- (void)setStrokeWidth:(CGFloat)width;
- (void)setPoints:(NSArray<CLLocation*>*)points;
- (void)setZIndex:(int)zIndex;
- (void)setGeodesic:(BOOL)isGeodesic;
@end

// Defines polyline controllable by Flutter.
@interface FLTGoogleMapPolylineController : NSObject <FLTGoogleMapPolylineOptionsSink>
@property(atomic, readonly) NSString* polylineId;
- (instancetype)initPolylineWithPath:(GMSMutablePath*)path
                          polylineId:(NSString*)polylineId
                             mapView:(GMSMapView*)mapView;
- (void)removePolyline;
@end

@interface FLTPolylinesController : NSObject
- (instancetype)init:(FlutterMethodChannel*)methodChannel
             mapView:(GMSMapView*)mapView
           registrar:(NSObject<FlutterPluginRegistrar>*)registrar;
- (void)addPolylines:(NSArray*)polylinesToAdd;
- (void)changePolylines:(NSArray*)polylinesToChange;
- (void)removePolylineIds:(NSArray*)polylineIdsToRemove;
- (void)onPolylineTap:(NSString*)polylineId;
- (bool)hasPolylineWithId:(NSString*)polylineId;
@end
