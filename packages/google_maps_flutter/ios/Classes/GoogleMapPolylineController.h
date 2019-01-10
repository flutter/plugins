

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>

// Defines marker UI options writable from Flutter.
@protocol FLTGoogleMapPolylineOptionsSink
- (void)setConsumeTapEvents:(BOOL)consume;
- (void)setVisible:(BOOL)visible;
- (void)setColor:(UIColor*)color;
- (void)setStrokeWidth:(CGFloat)width;
- (void)setPoints:(NSMutableArray*)points;
- (void)setZIndex:(int)zIndex;
@end

// Defines marker controllable by Flutter.
@interface FLTGoogleMapPolylineController : NSObject <FLTGoogleMapPolylineOptionsSink>
@property(atomic, readonly) NSString* polylineId;
- (instancetype)init:(GMSMapView*)mapView;
@end
