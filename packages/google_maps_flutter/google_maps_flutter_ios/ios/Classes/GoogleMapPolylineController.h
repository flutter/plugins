// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>

// Defines polyline controllable by Flutter.
@interface FLTGoogleMapPolylineController : NSObject
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
