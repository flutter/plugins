// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>

// Defines polyline UI options writable from Flutter.
@protocol FLTGoogleMapPolylineOptionsSink
- (void)setConsumeTapEvents:(BOOL)consume;
- (void)setVisible:(BOOL)visible;
- (void)setColor:(UIColor *)color;
- (void)setStrokeWidth:(CGFloat)width;
- (void)setPoints:(NSArray<CLLocation *> *)points;
- (void)setZIndex:(int)zIndex;
- (void)setGeodesic:(BOOL)isGeodesic;
@end

// Defines polyline controllable by Flutter.
@interface FLTGoogleMapPolylineController : NSObject <FLTGoogleMapPolylineOptionsSink>
- (instancetype)initPolylineWithPath:(GMSMutablePath *)path
                          identifier:(NSString *)identifier
                             mapView:(GMSMapView *)mapView;
- (void)removePolyline;
@end

@interface FLTPolylinesController : NSObject
- (instancetype)init:(FlutterMethodChannel *)methodChannel
             mapView:(GMSMapView *)mapView
           registrar:(NSObject<FlutterPluginRegistrar> *)registrar;
- (void)addPolylines:(NSArray *)polylinesToAdd;
- (void)changePolylines:(NSArray *)polylinesToChange;
- (void)removePolylineWithIdentifiers:(NSArray *)identifiers;
- (void)didTapPolylineWithIdentifier:(NSString *)identifier;
- (bool)hasPolylineWithIdentifier:(NSString *)identifier;
@end
