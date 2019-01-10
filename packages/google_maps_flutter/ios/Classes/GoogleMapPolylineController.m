// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapPolylineController.h"

static uint64_t _nextPolylineId = 0;

@implementation FLTGoogleMapPolylineController {
  GMSPolyline *_polyline;
  GMSMapView *_mapView;
}
- (instancetype)init:(GMSMapView *)mapView {
  self = [super init];
  if (self) {
    GMSMutablePath *path = [GMSMutablePath path];
    _polyline = [GMSPolyline polylineWithPath:path];
    _polyline.tappable = true;
    _polyline.map = mapView;
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
- (void)setVisible:(BOOL)visible {
  _polyline.map = visible ? _mapView : nil;
}
- (void)setZIndex:(int)zIndex {
  _polyline.zIndex = zIndex;
}
- (void)setPoints:(NSMutableArray *)points {
  GMSMutablePath *path = [GMSMutablePath path];

  for (NSObject *point in points) {
    CLLocation *location = (CLLocation *)point;
    [path addCoordinate:location.coordinate];
  }
  _polyline.path = path;
}

- (void)setColor:(UIColor *)color {
  _polyline.strokeColor = color;
}
- (void)setStrokeWidth:(CGFloat)width {
  _polyline.strokeWidth = width;
}
@end