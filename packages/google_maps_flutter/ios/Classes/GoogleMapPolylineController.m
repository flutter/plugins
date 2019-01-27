// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapPolylineController.h"

static uint64_t _nextPolylineId = 0;

@implementation FLTGoogleMapPolylineController {
  GMSPolyline* _polyline;
  GMSMapView* _mapView;
}
- (instancetype)initWithPath:(GMSPath*)path mapView:(GMSMapView*)mapView {
  self = [super init];
  if (self) {
    _polyline = [GMSPolyline polylineWithPath:path];
    _mapView = mapView;
    _polylineId = [NSString stringWithFormat:@"%lld", _nextPolylineId++];
    _polyline.userData = @[ _polylineId, @(NO) ];
  }
  return self;
}

#pragma mark - FLTGoogleMapPolylineOptionsSink methods

- (void)setConsumeTapEvents:(BOOL)consumes {
  _polyline.userData[1] = @(consumes);
}
- (void)setPoints:(GMSPath*)points {
  _polyline.path = points;
}
- (void)setClickable:(BOOL)clickable {
  _polyline.tappable = clickable;
}
- (void)setColor:(UIColor*)color {
  _polyline.strokeColor = color;
}
- (void)setGeodesic:(BOOL)geodesic {
  _polyline.geodesic = geodesic;
}
- (void)setPattern:(NSArray<GMSStyleSpan*>*)pattern {
  _polyline.spans = pattern;
}
- (void)setWidth:(CGFloat)width {
  _polyline.strokeWidth = width;
}
- (void)setVisible:(BOOL)visible {
  _polyline.map = visible ? _mapView : nil;
}
- (void)setZIndex:(int)zIndex {
  _polyline.zIndex = zIndex;
}
@end
