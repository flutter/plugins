// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapPolylineController.h"
#import "FLTGoogleMapJSONConversions.h"

@interface FLTGoogleMapPolylineController ()

@property(strong, nonatomic) GMSPolyline *polyline;
@property(weak, nonatomic) GMSMapView *mapView;

@end

@implementation FLTGoogleMapPolylineController

- (instancetype)initPolylineWithPath:(GMSMutablePath *)path
                          identifier:(NSString *)identifier
                             mapView:(GMSMapView *)mapView {
  self = [super init];
  if (self) {
    _polyline = [GMSPolyline polylineWithPath:path];
    _mapView = mapView;
    _polyline.userData = @[ identifier ];
  }
  return self;
}

- (void)removePolyline {
  self.polyline.map = nil;
}

- (void)setConsumeTapEvents:(BOOL)consumes {
  self.polyline.tappable = consumes;
}
- (void)setVisible:(BOOL)visible {
  self.polyline.map = visible ? self.mapView : nil;
}
- (void)setZIndex:(int)zIndex {
  self.polyline.zIndex = zIndex;
}
- (void)setPoints:(NSArray<CLLocation *> *)points {
  GMSMutablePath *path = [GMSMutablePath path];

  for (CLLocation *location in points) {
    [path addCoordinate:location.coordinate];
  }
  self.polyline.path = path;
}

- (void)setColor:(UIColor *)color {
  self.polyline.strokeColor = color;
}
- (void)setStrokeWidth:(CGFloat)width {
  self.polyline.strokeWidth = width;
}

- (void)setGeodesic:(BOOL)isGeodesic {
  self.polyline.geodesic = isGeodesic;
}

- (void)interpretPolylineOptions:(NSDictionary *)data
                       registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  NSNumber *consumeTapEvents = data[@"consumeTapEvents"];
  if (consumeTapEvents && consumeTapEvents != (id)[NSNull null]) {
    [self setConsumeTapEvents:[consumeTapEvents boolValue]];
  }

  NSNumber *visible = data[@"visible"];
  if (visible && visible != (id)[NSNull null]) {
    [self setVisible:[visible boolValue]];
  }

  NSNumber *zIndex = data[@"zIndex"];
  if (zIndex && zIndex != (id)[NSNull null]) {
    [self setZIndex:[zIndex intValue]];
  }

  NSArray *points = data[@"points"];
  if (points && points != (id)[NSNull null]) {
    [self setPoints:[FLTGoogleMapJSONConversions pointsFromLatLongs:points]];
  }

  NSNumber *strokeColor = data[@"color"];
  if (strokeColor && strokeColor != (id)[NSNull null]) {
    [self setColor:[FLTGoogleMapJSONConversions colorFromRGBA:strokeColor]];
  }

  NSNumber *strokeWidth = data[@"width"];
  if (strokeWidth && strokeWidth != (id)[NSNull null]) {
    [self setStrokeWidth:[strokeWidth intValue]];
  }

  NSNumber *geodesic = data[@"geodesic"];
  if (geodesic && geodesic != (id)[NSNull null]) {
    [self setGeodesic:geodesic.boolValue];
  }
}

@end

@interface FLTPolylinesController ()

@property(strong, nonatomic) NSMutableDictionary *polylineIdentifierToController;
@property(strong, nonatomic) FlutterMethodChannel *methodChannel;
@property(weak, nonatomic) NSObject<FlutterPluginRegistrar> *registrar;
@property(weak, nonatomic) GMSMapView *mapView;

@end
;

@implementation FLTPolylinesController

- (instancetype)init:(FlutterMethodChannel *)methodChannel
             mapView:(GMSMapView *)mapView
           registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _methodChannel = methodChannel;
    _mapView = mapView;
    _polylineIdentifierToController = [NSMutableDictionary dictionaryWithCapacity:1];
    _registrar = registrar;
  }
  return self;
}
- (void)addPolylines:(NSArray *)polylinesToAdd {
  for (NSDictionary *polyline in polylinesToAdd) {
    GMSMutablePath *path = [FLTPolylinesController getPath:polyline];
    NSString *identifier = polyline[@"polylineId"];
    FLTGoogleMapPolylineController *controller =
        [[FLTGoogleMapPolylineController alloc] initPolylineWithPath:path
                                                          identifier:identifier
                                                             mapView:self.mapView];
    [controller interpretPolylineOptions:polyline registrar:self.registrar];
    self.polylineIdentifierToController[identifier] = controller;
  }
}
- (void)changePolylines:(NSArray *)polylinesToChange {
  for (NSDictionary *polyline in polylinesToChange) {
    NSString *identifier = polyline[@"polylineId"];
    FLTGoogleMapPolylineController *controller = self.polylineIdentifierToController[identifier];
    if (!controller) {
      continue;
    }
    [controller interpretPolylineOptions:polyline registrar:self.registrar];
  }
}
- (void)removePolylineWithIdentifiers:(NSArray *)identifiers {
  for (NSString *identifier in identifiers) {
    FLTGoogleMapPolylineController *controller = self.polylineIdentifierToController[identifier];
    if (!controller) {
      continue;
    }
    [controller removePolyline];
    [self.polylineIdentifierToController removeObjectForKey:identifier];
  }
}
- (void)didTapPolylineWithIdentifier:(NSString *)identifier {
  if (!identifier) {
    return;
  }
  FLTGoogleMapPolylineController *controller = self.polylineIdentifierToController[identifier];
  if (!controller) {
    return;
  }
  [self.methodChannel invokeMethod:@"polyline#onTap" arguments:@{@"polylineId" : identifier}];
}
- (bool)hasPolylineWithIdentifier:(NSString *)identifier {
  if (!identifier) {
    return false;
  }
  return self.polylineIdentifierToController[identifier] != nil;
}
+ (GMSMutablePath *)getPath:(NSDictionary *)polyline {
  NSArray *pointArray = polyline[@"points"];
  NSArray<CLLocation *> *points = [FLTGoogleMapJSONConversions pointsFromLatLongs:pointArray];
  GMSMutablePath *path = [GMSMutablePath path];
  for (CLLocation *location in points) {
    [path addCoordinate:location.coordinate];
  }
  return path;
}

@end
