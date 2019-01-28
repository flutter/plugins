// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>

// Defines circle UI options writable from Flutter.
@protocol FLTGoogleMapCircleOptionsSink
- (void)setConsumeTapEvents:(BOOL)consume;
- (void)setRadius:(int)radius;
- (void)setStrokeWidth:(int)strokeWidth;
- (void)setFillColor:(UIColor*)fillColor;
- (void)setStrokeColor:(UIColor*)strokeColor;
- (void)setCenter:(CLLocationCoordinate2D)center;
- (void)setVisible:(BOOL)visible;
- (void)setZIndex:(int)zIndex;
@end

// Defines circle controllable by Flutter.
@interface FLTGoogleMapCircleController : NSObject <FLTGoogleMapCircleOptionsSink>
@property(atomic, readonly) NSString* circleId;
- (instancetype)initWithCenter:(CLLocationCoordinate2D)center radius:(int)radius mapView:(GMSMapView*)mapView;
@end
