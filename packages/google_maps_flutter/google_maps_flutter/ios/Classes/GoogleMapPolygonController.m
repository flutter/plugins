// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapPolygonController.h"
#import "JsonConversions.h"

@implementation FLTGoogleMapPolygonController {
  GMSPolygon* _polygon;
  GMSMapView* _mapView;
}
- (instancetype)initPolygonWithPath:(GMSMutablePath*)path
                          polygonId:(NSString*)polygonId
                            mapView:(GMSMapView*)mapView {
  self = [super init];
  if (self) {
    _polygon = [GMSPolygon polygonWithPath:path];
    _mapView = mapView;
    _polygonId = polygonId;
    _polygon.userData = @[ polygonId ];
  }
  return self;
}

- (void)removePolygon {
  _polygon.map = nil;
}

#pragma mark - FLTGoogleMapPolygonOptionsSink methods

- (void)setConsumeTapEvents:(BOOL)consumes {
  _polygon.tappable = consumes;
}
- (void)setVisible:(BOOL)visible {
  _polygon.map = visible ? _mapView : nil;
}
- (void)setZIndex:(int)zIndex {
  _polygon.zIndex = zIndex;
}
- (void)setPoints:(NSArray<CLLocation*>*)points {
  GMSMutablePath* path = [GMSMutablePath path];

  for (CLLocation* location in points) {
    [path addCoordinate:location.coordinate];
  }
  _polygon.path = path;
}

- (void)setFillColor:(UIColor*)color {
  _polygon.fillColor = color;
}
- (void)setStrokeColor:(UIColor*)color {
  _polygon.strokeColor = color;
}
- (void)setStrokeWidth:(CGFloat)width {
  _polygon.strokeWidth = width;
}
@end

static int ToInt(NSNumber* data) { return [FLTGoogleMapJsonConversions toInt:data]; }

static BOOL ToBool(NSNumber* data) { return [FLTGoogleMapJsonConversions toBool:data]; }

static NSArray<CLLocation*>* ToPoints(NSArray* data) {
  return [FLTGoogleMapJsonConversions toPoints:data];
}

static UIColor* ToColor(NSNumber* data) { return [FLTGoogleMapJsonConversions toColor:data]; }

static void InterpretPolygonOptions(NSDictionary* data, id<FLTGoogleMapPolygonOptionsSink> sink,
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

  NSArray* points = data[@"points"];
  if (points) {
    [sink setPoints:ToPoints(points)];
  }

  NSNumber* fillColor = data[@"fillColor"];
  if (fillColor != nil) {
    [sink setFillColor:ToColor(fillColor)];
  }

  NSNumber* strokeColor = data[@"strokeColor"];
  if (strokeColor != nil) {
    [sink setStrokeColor:ToColor(strokeColor)];
  }

  NSNumber* strokeWidth = data[@"strokeWidth"];
  if (strokeWidth != nil) {
    [sink setStrokeWidth:ToInt(strokeWidth)];
  }
}

@implementation FLTPolygonsController {
  NSMutableDictionary* _polygonIdToController;
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
    _polygonIdToController = [NSMutableDictionary dictionaryWithCapacity:1];
    _registrar = registrar;
  }
  return self;
}
- (void)addPolygons:(NSArray*)polygonsToAdd {
  for (NSDictionary* polygon in polygonsToAdd) {
    GMSMutablePath* path = [FLTPolygonsController getPath:polygon];
    NSString* polygonId = [FLTPolygonsController getPolygonId:polygon];
    FLTGoogleMapPolygonController* controller =
        [[FLTGoogleMapPolygonController alloc] initPolygonWithPath:path
                                                         polygonId:polygonId
                                                           mapView:_mapView];
    InterpretPolygonOptions(polygon, controller, _registrar);
    _polygonIdToController[polygonId] = controller;
  }
}
- (void)changePolygons:(NSArray*)polygonsToChange {
  for (NSDictionary* polygon in polygonsToChange) {
    NSString* polygonId = [FLTPolygonsController getPolygonId:polygon];
    FLTGoogleMapPolygonController* controller = _polygonIdToController[polygonId];
    if (!controller) {
      continue;
    }
    InterpretPolygonOptions(polygon, controller, _registrar);
  }
}
- (void)removePolygonIds:(NSArray*)polygonIdsToRemove {
  for (NSString* polygonId in polygonIdsToRemove) {
    if (!polygonId) {
      continue;
    }
    FLTGoogleMapPolygonController* controller = _polygonIdToController[polygonId];
    if (!controller) {
      continue;
    }
    [controller removePolygon];
    [_polygonIdToController removeObjectForKey:polygonId];
  }
}
- (void)onPolygonTap:(NSString*)polygonId {
  if (!polygonId) {
    return;
  }
  FLTGoogleMapPolygonController* controller = _polygonIdToController[polygonId];
  if (!controller) {
    return;
  }
  [_methodChannel invokeMethod:@"polygon#onTap" arguments:@{@"polygonId" : polygonId}];
}
- (bool)hasPolygonWithId:(NSString*)polygonId {
  if (!polygonId) {
    return false;
  }
  return _polygonIdToController[polygonId] != nil;
}
+ (GMSMutablePath*)getPath:(NSDictionary*)polygon {
  NSArray* pointArray = polygon[@"points"];
  NSArray<CLLocation*>* points = ToPoints(pointArray);
  GMSMutablePath* path = [GMSMutablePath path];
  for (CLLocation* location in points) {
    [path addCoordinate:location.coordinate];
  }
  return path;
}
+ (NSString*)getPolygonId:(NSDictionary*)polygon {
  return polygon[@"polygonId"];
}
@end
