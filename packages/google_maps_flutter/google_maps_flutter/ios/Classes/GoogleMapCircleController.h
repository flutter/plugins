// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>

// Defines circle UI options writable from Flutter.
@protocol FLTGoogleMapCircleOptionsSink
- (void)setConsumeTapEvents:(BOOL)consume;
- (void)setVisible:(BOOL)visible;
- (void)setStrokeColor:(UIColor *)color;
- (void)setStrokeWidth:(CGFloat)width;
- (void)setFillColor:(UIColor *)color;
- (void)setCenter:(CLLocationCoordinate2D)center;
- (void)setRadius:(CLLocationDistance)radius;
- (void)setZIndex:(int)zIndex;
@end

// Defines circle controllable by Flutter.
@interface FLTGoogleMapCircleController : NSObject <FLTGoogleMapCircleOptionsSink>
- (instancetype)initCircleWithPosition:(CLLocationCoordinate2D)position
                                radius:(CLLocationDistance)radius
                              circleId:(NSString *)circleIdentifier
                               mapView:(GMSMapView *)mapView;
- (void)removeCircle;
@end

@interface FLTCirclesController : NSObject
- (instancetype)init:(FlutterMethodChannel *)methodChannel
             mapView:(GMSMapView *)mapView
           registrar:(NSObject<FlutterPluginRegistrar> *)registrar;
- (void)addCircles:(NSArray *)circlesToAdd;
- (void)changeCircles:(NSArray *)circlesToChange;
- (void)removeCircleWithIdentifiers:(NSArray *)identifiers;
- (void)didTapCircleWithIdentifier:(NSString *)identifier;
- (bool)hasCircleWithIdentifier:(NSString *)identifier;
@end
