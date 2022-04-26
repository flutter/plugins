// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>

// Defines polygon UI options writable from Flutter.
@protocol FLTGoogleMapPolygonOptionsSink
- (void)setConsumeTapEvents:(BOOL)consume;
- (void)setVisible:(BOOL)visible;
- (void)setFillColor:(UIColor *)color;
- (void)setStrokeColor:(UIColor *)color;
- (void)setStrokeWidth:(CGFloat)width;
- (void)setPoints:(NSArray<CLLocation *> *)points;
- (void)setHoles:(NSArray<NSArray<CLLocation *> *> *)holes;
- (void)setZIndex:(int)zIndex;
@end

// Defines polygon controllable by Flutter.
@interface FLTGoogleMapPolygonController : NSObject <FLTGoogleMapPolygonOptionsSink>
- (instancetype)initPolygonWithPath:(GMSMutablePath *)path
                         identifier:(NSString *)identifier
                            mapView:(GMSMapView *)mapView;
- (void)removePolygon;
@end

@interface FLTPolygonsController : NSObject
- (instancetype)init:(FlutterMethodChannel *)methodChannel
             mapView:(GMSMapView *)mapView
           registrar:(NSObject<FlutterPluginRegistrar> *)registrar;
- (void)addPolygons:(NSArray *)polygonsToAdd;
- (void)changePolygons:(NSArray *)polygonsToChange;
- (void)removePolygonWithIdentifiers:(NSArray *)identifiers;
- (void)didTapPolygonWithIdentifier:(NSString *)identifier;
- (bool)hasPolygonWithIdentifier:(NSString *)identifier;
@end
