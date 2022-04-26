// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapPolygonController.h"
#import "JsonConversions.h"

@interface FLTGoogleMapPolygonController ()

@property(strong, nonatomic) GMSPolygon *polygon;
@property(weak, nonatomic) GMSMapView *mapView;

@end

@implementation FLTGoogleMapPolygonController

- (instancetype)initPolygonWithPath:(GMSMutablePath *)path
                         identifier:(NSString *)identifier
                            mapView:(GMSMapView *)mapView {
  self = [super init];
  if (self) {
    _polygon = [GMSPolygon polygonWithPath:path];
    _mapView = mapView;
    _polygon.userData = @[ identifier ];
  }
  return self;
}

- (void)removePolygon {
  self.polygon.map = nil;
}

#pragma mark - FLTGoogleMapPolygonOptionsSink methods

- (void)setConsumeTapEvents:(BOOL)consumes {
  self.polygon.tappable = consumes;
}
- (void)setVisible:(BOOL)visible {
  self.polygon.map = visible ? self.mapView : nil;
}
- (void)setZIndex:(int)zIndex {
  self.polygon.zIndex = zIndex;
}
- (void)setPoints:(NSArray<CLLocation *> *)points {
  GMSMutablePath *path = [GMSMutablePath path];

  for (CLLocation *location in points) {
    [path addCoordinate:location.coordinate];
  }
  self.polygon.path = path;
}
- (void)setHoles:(NSArray<NSArray<CLLocation *> *> *)rawHoles {
  NSMutableArray<GMSMutablePath *> *holes = [[NSMutableArray<GMSMutablePath *> alloc] init];

  for (NSArray<CLLocation *> *points in rawHoles) {
    GMSMutablePath *path = [GMSMutablePath path];
    for (CLLocation *location in points) {
      [path addCoordinate:location.coordinate];
    }
    [holes addObject:path];
  }

  self.polygon.holes = holes;
}

- (void)setFillColor:(UIColor *)color {
  self.polygon.fillColor = color;
}
- (void)setStrokeColor:(UIColor *)color {
  self.polygon.strokeColor = color;
}
- (void)setStrokeWidth:(CGFloat)width {
  self.polygon.strokeWidth = width;
}
@end

@interface FLTPolygonsController ()

@property(strong, nonatomic) NSMutableDictionary *polygonIdentifierToController;
@property(weak, nonatomic) FlutterMethodChannel *methodChannel;
@property(weak, nonatomic) NSObject<FlutterPluginRegistrar> *registrar;
@property(weak, nonatomic) GMSMapView *mapView;

@end

@implementation FLTPolygonsController

- (instancetype)init:(FlutterMethodChannel *)methodChannel
             mapView:(GMSMapView *)mapView
           registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _methodChannel = methodChannel;
    _mapView = mapView;
    _polygonIdentifierToController = [NSMutableDictionary dictionaryWithCapacity:1];
    _registrar = registrar;
  }
  return self;
}

- (void)addPolygons:(NSArray *)polygonsToAdd {
  for (NSDictionary *polygon in polygonsToAdd) {
    GMSMutablePath *path = [FLTPolygonsController getPath:polygon];
    NSString *identifier = [FLTPolygonsController getPolygonId:polygon];
    FLTGoogleMapPolygonController *controller =
        [[FLTGoogleMapPolygonController alloc] initPolygonWithPath:path
                                                        identifier:identifier
                                                           mapView:self.mapView];
    [FLTPolygonsController interpretPolygonOptions:polygon
                                              sink:controller
                                         registrar:self.registrar];
    self.polygonIdentifierToController[identifier] = controller;
  }
}

- (void)changePolygons:(NSArray *)polygonsToChange {
  for (NSDictionary *polygon in polygonsToChange) {
    NSString *identifier = [FLTPolygonsController getPolygonId:polygon];
    FLTGoogleMapPolygonController *controller = self.polygonIdentifierToController[identifier];
    if (!controller) {
      continue;
    }
    [FLTPolygonsController interpretPolygonOptions:polygon
                                              sink:controller
                                         registrar:self.registrar];
  }
}

- (void)removePolygonWithIdentifiers:(NSArray *)identifiers {
  for (NSString *identifier in identifiers) {
    FLTGoogleMapPolygonController *controller = self.polygonIdentifierToController[identifier];
    if (!controller) {
      continue;
    }
    [controller removePolygon];
    [self.polygonIdentifierToController removeObjectForKey:identifier];
  }
}

- (void)didTapPolygonWithIdentifier:(NSString *)identifier {
  if (!identifier) {
    return;
  }
  FLTGoogleMapPolygonController *controller = self.polygonIdentifierToController[identifier];
  if (!controller) {
    return;
  }
  [self.methodChannel invokeMethod:@"polygon#onTap" arguments:@{@"polygonId" : identifier}];
}

- (bool)hasPolygonWithIdentifier:(NSString *)identifier {
  if (!identifier) {
    return false;
  }
  return self.polygonIdentifierToController[identifier] != nil;
}

+ (GMSMutablePath *)getPath:(NSDictionary *)polygon {
  NSArray *pointArray = polygon[@"points"];
  NSArray<CLLocation *> *points = [FLTGoogleMapJSONConversions pointsFromLatlongs:pointArray];
  GMSMutablePath *path = [GMSMutablePath path];
  for (CLLocation *location in points) {
    [path addCoordinate:location.coordinate];
  }
  return path;
}

+ (NSString *)getPolygonId:(NSDictionary *)polygon {
  return polygon[@"polygonId"];
}

+ (void)interpretPolygonOptions:(NSDictionary *)data
                           sink:(id<FLTGoogleMapPolygonOptionsSink>)sink
                      registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  NSNumber *consumeTapEvents = data[@"consumeTapEvents"];
  if (consumeTapEvents && consumeTapEvents != (id)[NSNull null]) {
    [sink setConsumeTapEvents:[consumeTapEvents boolValue]];
  }

  NSNumber *visible = data[@"visible"];
  if (visible && visible != (id)[NSNull null]) {
    [sink setVisible:[visible boolValue]];
  }

  NSNumber *zIndex = data[@"zIndex"];
  if (zIndex && zIndex != (id)[NSNull null]) {
    [sink setZIndex:[zIndex intValue]];
  }

  NSArray *points = data[@"points"];
  if (points && points != (id)[NSNull null]) {
    [sink setPoints:[FLTGoogleMapJSONConversions pointsFromLatlongs:points]];
  }

  NSArray *holes = data[@"holes"];
  if (holes && holes != (id)[NSNull null]) {
    [sink setHoles:[FLTGoogleMapJSONConversions holesFromPointsArray:holes]];
  }

  NSNumber *fillColor = data[@"fillColor"];
  if (fillColor && fillColor != (id)[NSNull null]) {
    [sink setFillColor:[FLTGoogleMapJSONConversions colorFromRGBA:fillColor]];
  }

  NSNumber *strokeColor = data[@"strokeColor"];
  if (strokeColor && strokeColor != (id)[NSNull null]) {
    [sink setStrokeColor:[FLTGoogleMapJSONConversions colorFromRGBA:strokeColor]];
  }

  NSNumber *strokeWidth = data[@"strokeWidth"];
  if (strokeWidth && strokeWidth != (id)[NSNull null]) {
    [sink setStrokeWidth:[strokeWidth intValue]];
  }
}
@end
