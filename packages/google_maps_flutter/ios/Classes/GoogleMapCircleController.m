// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapCircleController.h"

static uint64_t _nextCircleId = 0;

@implementation FLTGoogleMapCircleController {
    GMSCircle* _circle;
    GMSMapView* _mapView;
}
- (instancetype)initWithCenter:(CLLocationCoordinate2D)center radius:(int)radius mapView:(GMSMapView*)mapView {
    self = [super init];
    if (self) {
        _circle = [GMSCircle circleWithPosition:center radius:radius];
        _circle.tappable = true;
        _mapView = mapView;
        _circleId = [NSString stringWithFormat:@"%lld", _nextCircleId++];
        _circle.userData = @[ _circleId, @(NO) ];
    }
    return self;
}

#pragma mark - FLTGoogleMapCircleOptionsSink methods

- (void)setConsumeTapEvents:(BOOL)consumes {
    _circle.userData[1] = @(consumes);
}
- (void)setCenter:(CLLocationCoordinate2D)center {
    _circle.position = center;
}
- (void)setVisible:(BOOL)visible {
    _circle.map = visible ? _mapView : nil;
}
- (void)setZIndex:(int)zIndex {
    _circle.zIndex = zIndex;
}
- (void)setFillColor:(UIColor *)fillColor {
    _circle.fillColor = fillColor;
}
- (void)setRadius:(int)radius {
    _circle.radius = radius;
}
- (void)setStrokeColor:(UIColor *)strokeColor {
    _circle.strokeColor  = strokeColor;
}
- (void)setStrokeWidth:(int)strokeWidth {
    _circle.strokeWidth = strokeWidth;
}

@end
