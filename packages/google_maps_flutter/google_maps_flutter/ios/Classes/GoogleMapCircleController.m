// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapCircleController.h"
#import "FLTGoogleMapJSONConversions.h"

@interface FLTGoogleMapCircleController ()

@property(nonatomic, strong) GMSCircle *circle;
@property(nonatomic, weak) GMSMapView *mapView;

@end

@implementation FLTGoogleMapCircleController

- (instancetype)initCircleWithPosition:(CLLocationCoordinate2D)position
                                radius:(CLLocationDistance)radius
                              circleId:(NSString *)circleIdentifier
                               mapView:(GMSMapView *)mapView
                               options:(NSDictionary *)options {
  self = [super init];
  if (self) {
    _circle = [GMSCircle circleWithPosition:position radius:radius];
    _mapView = mapView;
    _circle.userData = @[ circleIdentifier ];
    [self interpretCircleOptions:options];
  }
  return self;
}

- (void)removeCircle {
  self.circle.map = nil;
}

- (void)setConsumeTapEvents:(BOOL)consumes {
  self.circle.tappable = consumes;
}
- (void)setVisible:(BOOL)visible {
  self.circle.map = visible ? self.mapView : nil;
}
- (void)setZIndex:(int)zIndex {
  self.circle.zIndex = zIndex;
}
- (void)setCenter:(CLLocationCoordinate2D)center {
  self.circle.position = center;
}
- (void)setRadius:(CLLocationDistance)radius {
  self.circle.radius = radius;
}

- (void)setStrokeColor:(UIColor *)color {
  self.circle.strokeColor = color;
}
- (void)setStrokeWidth:(CGFloat)width {
  self.circle.strokeWidth = width;
}
- (void)setFillColor:(UIColor *)color {
  self.circle.fillColor = color;
}

- (void)interpretCircleOptions:(NSDictionary *)data {
  NSNumber *consumeTapEvents = data[@"consumeTapEvents"];
  if (consumeTapEvents && consumeTapEvents != (id)[NSNull null]) {
    [self setConsumeTapEvents:consumeTapEvents.boolValue];
  }

  NSNumber *visible = data[@"visible"];
  if (visible && visible != (id)[NSNull null]) {
    [self setVisible:[visible boolValue]];
  }

  NSNumber *zIndex = data[@"zIndex"];
  if (zIndex && zIndex != (id)[NSNull null]) {
    [self setZIndex:[zIndex intValue]];
  }

  NSArray *center = data[@"center"];
  if (center && center != (id)[NSNull null]) {
    [self setCenter:[FLTGoogleMapJSONConversions locationFromLatLong:center]];
  }

  NSNumber *radius = data[@"radius"];
  if (radius && radius != (id)[NSNull null]) {
    [self setRadius:[radius floatValue]];
  }

  NSNumber *strokeColor = data[@"strokeColor"];
  if (strokeColor && strokeColor != (id)[NSNull null]) {
    [self setStrokeColor:[FLTGoogleMapJSONConversions colorFromRGBA:strokeColor]];
  }

  NSNumber *strokeWidth = data[@"strokeWidth"];
  if (strokeWidth && strokeWidth != (id)[NSNull null]) {
    [self setStrokeWidth:[strokeWidth intValue]];
  }

  NSNumber *fillColor = data[@"fillColor"];
  if (fillColor && fillColor != (id)[NSNull null]) {
    [self setFillColor:[FLTGoogleMapJSONConversions colorFromRGBA:fillColor]];
  }
}

@end

@interface FLTCirclesController ()

@property(strong, nonatomic) FlutterMethodChannel *methodChannel;
@property(weak, nonatomic) GMSMapView *mapView;
@property(strong, nonatomic) NSMutableDictionary *circleIdToController;

@end

@implementation FLTCirclesController

- (instancetype)init:(FlutterMethodChannel *)methodChannel
             mapView:(GMSMapView *)mapView
           registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _methodChannel = methodChannel;
    _mapView = mapView;
    _circleIdToController = [NSMutableDictionary dictionaryWithCapacity:1];
  }
  return self;
}

- (void)addCircles:(NSArray *)circlesToAdd {
  for (NSDictionary *circle in circlesToAdd) {
    CLLocationCoordinate2D position = [FLTCirclesController getPosition:circle];
    CLLocationDistance radius = [FLTCirclesController getRadius:circle];
    NSString *circleId = [FLTCirclesController getCircleId:circle];
    FLTGoogleMapCircleController *controller =
        [[FLTGoogleMapCircleController alloc] initCircleWithPosition:position
                                                              radius:radius
                                                            circleId:circleId
                                                             mapView:self.mapView
                                                             options:circle];
    self.circleIdToController[circleId] = controller;
  }
}

- (void)changeCircles:(NSArray *)circlesToChange {
  for (NSDictionary *circle in circlesToChange) {
    NSString *circleId = [FLTCirclesController getCircleId:circle];
    FLTGoogleMapCircleController *controller = self.circleIdToController[circleId];
    if (!controller) {
      continue;
    }
    [controller interpretCircleOptions:circle];
  }
}

- (void)removeCircleWithIdentifiers:(NSArray *)identifiers {
  for (NSString *identifier in identifiers) {
    FLTGoogleMapCircleController *controller = self.circleIdToController[identifier];
    if (!controller) {
      continue;
    }
    [controller removeCircle];
    [self.circleIdToController removeObjectForKey:identifier];
  }
}

- (bool)hasCircleWithIdentifier:(NSString *)identifier {
  if (!identifier) {
    return false;
  }
  return self.circleIdToController[identifier] != nil;
}

- (void)didTapCircleWithIdentifier:(NSString *)identifier {
  if (!identifier) {
    return;
  }
  FLTGoogleMapCircleController *controller = self.circleIdToController[identifier];
  if (!controller) {
    return;
  }
  [self.methodChannel invokeMethod:@"circle#onTap" arguments:@{@"circleId" : identifier}];
}

+ (CLLocationCoordinate2D)getPosition:(NSDictionary *)circle {
  NSArray *center = circle[@"center"];
  return [FLTGoogleMapJSONConversions locationFromLatLong:center];
}

+ (CLLocationDistance)getRadius:(NSDictionary *)circle {
  NSNumber *radius = circle[@"radius"];
  return [radius floatValue];
}

+ (NSString *)getCircleId:(NSDictionary *)circle {
  return circle[@"circleId"];
}

@end
