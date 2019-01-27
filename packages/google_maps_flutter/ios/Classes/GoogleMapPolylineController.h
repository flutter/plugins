// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>

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
- (instancetype)initWithPath:(GMSPath*)path mapView:(GMSMapView*)mapView;
@end
