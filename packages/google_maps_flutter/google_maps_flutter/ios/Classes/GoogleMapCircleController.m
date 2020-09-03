// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapCircleController.h"
#import "JsonConversions.h"

@implementation FLTGoogleMapCircleController {
  GMSCircle* _circle;
  GMSMapView* _mapView;
}
- (instancetype)initCircleWithPosition:(CLLocationCoordinate2D)position
                                radius:(CLLocationDistance)radius
                              circleId:(NSString*)circleId
                               mapView:(GMSMapView*)mapView {
  self = [super init];
  if (self) {
    _circle = [GMSCircle circleWithPosition:position radius:radius];
    _mapView = mapView;
    _circleId = circleId;
    _circle.userData = @[ circleId ];
  }
  return self;
}

- (void)removeCircle {
  _circle.map = nil;
}

#pragma mark - FLTGoogleMapCircleOptionsSink methods

- (void)setConsumeTapEvents:(BOOL)consumes {
  _circle.tappable = consumes;
}
- (void)setVisible:(BOOL)visible {
  _circle.map = visible ? _mapView : nil;
}
- (void)setZIndex:(int)zIndex {
  _circle.zIndex = zIndex;
}
- (void)setCenter:(CLLocationCoordinate2D)center {
  _circle.position = center;
}
- (void)setRadius:(CLLocationDistance)radius {
  _circle.radius = radius;
}

- (void)setStrokeColor:(UIColor*)color {
  _circle.strokeColor = color;
}
- (void)setStrokeWidth:(CGFloat)width {
  _circle.strokeWidth = width;
}
- (void)setFillColor:(UIColor*)color {
  _circle.fillColor = color;
}
@end

static int ToInt(NSNumber* data) { return [FLTGoogleMapJsonConversions toInt:data]; }

static BOOL ToBool(NSNumber* data) { return [FLTGoogleMapJsonConversions toBool:data]; }

static CLLocationCoordinate2D ToLocation(NSArray* data) {
  return [FLTGoogleMapJsonConversions toLocation:data];
}

static CLLocationDistance ToDistance(NSNumber* data) {
  return [FLTGoogleMapJsonConversions toFloat:data];
}

static UIColor* ToColor(NSNumber* data) { return [FLTGoogleMapJsonConversions toColor:data]; }

static void InterpretCircleOptions(NSDictionary* data, id<FLTGoogleMapCircleOptionsSink> sink,
                                   NSObject<FlutterPluginRegistrar>* registrar) {
  NSNumber* consumeTapEvents = data[@"consumeTapEvents"];
  if (consumeTapEvents != nil) {
    [sink setConsumeTapEvents:ToBool(consumeTapEvents)];
  }

  NSNumber* visible = data[@"visible"];
  if (visible != nil) {
    [sink setVisible:ToBool(visible)];
  }

  NSNumber* zIndex = data[@"zIndex"];
  if (zIndex != nil) {
    [sink setZIndex:ToInt(zIndex)];
  }

  NSArray* center = data[@"center"];
  if (center) {
    [sink setCenter:ToLocation(center)];
  }

  NSNumber* radius = data[@"radius"];
  if (radius != nil) {
    [sink setRadius:ToDistance(radius)];
  }

  NSNumber* strokeColor = data[@"strokeColor"];
  if (strokeColor != nil) {
    [sink setStrokeColor:ToColor(strokeColor)];
  }

  NSNumber* strokeWidth = data[@"strokeWidth"];
  if (strokeWidth != nil) {
    [sink setStrokeWidth:ToInt(strokeWidth)];
  }

  NSNumber* fillColor = data[@"fillColor"];
  if (fillColor != nil) {
    [sink setFillColor:ToColor(fillColor)];
  }
}

@implementation FLTCirclesController {
  NSMutableDictionary* _circleIdToController;
  FlutterMethodChannel* _methodChannel;
  NSObject<FlutterPluginRegistrar>* _registrar;
  GMSMapView* _mapView;
}
- (instancetype)init:(FlutterMethodChannel*)methodChannel
             mapView:(GMSMapView*)mapView
           registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  self = [super init];
  if (self) {
    _methodChannel = methodChannel;
    _mapView = mapView;
    _circleIdToController = [NSMutableDictionary dictionaryWithCapacity:1];
    _registrar = registrar;
  }
  return self;
}
- (void)addCircles:(NSArray*)circlesToAdd {
  for (NSDictionary* circle in circlesToAdd) {
    CLLocationCoordinate2D position = [FLTCirclesController getPosition:circle];
    CLLocationDistance radius = [FLTCirclesController getRadius:circle];
    NSString* circleId = [FLTCirclesController getCircleId:circle];
    FLTGoogleMapCircleController* controller =
        [[FLTGoogleMapCircleController alloc] initCircleWithPosition:position
                                                              radius:radius
                                                            circleId:circleId
                                                             mapView:_mapView];
    InterpretCircleOptions(circle, controller, _registrar);
    _circleIdToController[circleId] = controller;
  }
}
- (void)changeCircles:(NSArray*)circlesToChange {
  for (NSDictionary* circle in circlesToChange) {
    NSString* circleId = [FLTCirclesController getCircleId:circle];
    FLTGoogleMapCircleController* controller = _circleIdToController[circleId];
    if (!controller) {
      continue;
    }
    InterpretCircleOptions(circle, controller, _registrar);
  }
}
- (void)removeCircleIds:(NSArray*)circleIdsToRemove {
  for (NSString* circleId in circleIdsToRemove) {
    if (!circleId) {
      continue;
    }
    FLTGoogleMapCircleController* controller = _circleIdToController[circleId];
    if (!controller) {
      continue;
    }
    [controller removeCircle];
    [_circleIdToController removeObjectForKey:circleId];
  }
}
- (bool)hasCircleWithId:(NSString*)circleId {
  if (!circleId) {
    return false;
  }
  return _circleIdToController[circleId] != nil;
}
- (void)onCircleTap:(NSString*)circleId {
  if (!circleId) {
    return;
  }
  FLTGoogleMapCircleController* controller = _circleIdToController[circleId];
  if (!controller) {
    return;
  }
  [_methodChannel invokeMethod:@"circle#onTap" arguments:@{@"circleId" : circleId}];
}
+ (CLLocationCoordinate2D)getPosition:(NSDictionary*)circle {
  NSArray* center = circle[@"center"];
  return ToLocation(center);
}
+ (CLLocationDistance)getRadius:(NSDictionary*)circle {
  NSNumber* radius = circle[@"radius"];
  return ToDistance(radius);
}
+ (NSString*)getCircleId:(NSDictionary*)circle {
  return circle[@"circleId"];
}
@end
