// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapPolylineController.h"
#import "JsonConversions.h"

@implementation FLTGoogleMapPolylineController {
  GMSPolyline* _polyline;
  GMSMapView* _mapView;
}
- (instancetype)initPolylineWithPath:(GMSMutablePath*)path
                          polylineId:(NSString*)polylineId
                             mapView:(GMSMapView*)mapView {
  self = [super init];
  if (self) {
    _polyline = [GMSPolyline polylineWithPath:path];
    _mapView = mapView;
    _polylineId = polylineId;
    _polyline.userData = @[ polylineId ];
  }
  return self;
}

- (void)removePolyline {
  _polyline.map = nil;
}

#pragma mark - FLTGoogleMapPolylineOptionsSink methods

- (void)setConsumeTapEvents:(BOOL)consumes {
  _polyline.tappable = consumes;
}
- (void)setVisible:(BOOL)visible {
  _polyline.map = visible ? _mapView : nil;
}
- (void)setZIndex:(int)zIndex {
  _polyline.zIndex = zIndex;
}
- (void)setPoints:(NSArray<CLLocation*>*)points {
  GMSMutablePath* path = [GMSMutablePath path];

  for (CLLocation* location in points) {
    [path addCoordinate:location.coordinate];
  }
  _polyline.path = path;
}

- (void)setColor:(UIColor*)color {
  _polyline.strokeColor = color;
}
- (void)setStrokeWidth:(CGFloat)width {
  _polyline.strokeWidth = width;
}

- (void)setGeodesic:(BOOL)isGeodesic {
  _polyline.geodesic = isGeodesic;
}
@end

static int ToInt(NSNumber* data) { return [FLTGoogleMapJsonConversions toInt:data]; }

static BOOL ToBool(NSNumber* data) { return [FLTGoogleMapJsonConversions toBool:data]; }

static NSArray<CLLocation*>* ToPoints(NSArray* data) {
  return [FLTGoogleMapJsonConversions toPoints:data];
}

static UIColor* ToColor(NSNumber* data) { return [FLTGoogleMapJsonConversions toColor:data]; }

static void InterpretPolylineOptions(NSDictionary* data, id<FLTGoogleMapPolylineOptionsSink> sink,
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

  NSNumber* strokeColor = data[@"color"];
  if (strokeColor != nil) {
    [sink setColor:ToColor(strokeColor)];
  }

  NSNumber* strokeWidth = data[@"width"];
  if (strokeWidth != nil) {
    [sink setStrokeWidth:ToInt(strokeWidth)];
  }

  NSNumber* geodesic = data[@"geodesic"];
  if (geodesic != nil) {
    [sink setGeodesic:geodesic.boolValue];
  }
}

@implementation FLTPolylinesController {
  NSMutableDictionary* _polylineIdToController;
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
    _polylineIdToController = [NSMutableDictionary dictionaryWithCapacity:1];
    _registrar = registrar;
  }
  return self;
}
- (void)addPolylines:(NSArray*)polylinesToAdd {
  for (NSDictionary* polyline in polylinesToAdd) {
    GMSMutablePath* path = [FLTPolylinesController getPath:polyline];
    NSString* polylineId = [FLTPolylinesController getPolylineId:polyline];
    FLTGoogleMapPolylineController* controller =
        [[FLTGoogleMapPolylineController alloc] initPolylineWithPath:path
                                                          polylineId:polylineId
                                                             mapView:_mapView];
    InterpretPolylineOptions(polyline, controller, _registrar);
    _polylineIdToController[polylineId] = controller;
  }
}
- (void)changePolylines:(NSArray*)polylinesToChange {
  for (NSDictionary* polyline in polylinesToChange) {
    NSString* polylineId = [FLTPolylinesController getPolylineId:polyline];
    FLTGoogleMapPolylineController* controller = _polylineIdToController[polylineId];
    if (!controller) {
      continue;
    }
    InterpretPolylineOptions(polyline, controller, _registrar);
  }
}
- (void)removePolylineIds:(NSArray*)polylineIdsToRemove {
  for (NSString* polylineId in polylineIdsToRemove) {
    if (!polylineId) {
      continue;
    }
    FLTGoogleMapPolylineController* controller = _polylineIdToController[polylineId];
    if (!controller) {
      continue;
    }
    [controller removePolyline];
    [_polylineIdToController removeObjectForKey:polylineId];
  }
}
- (void)onPolylineTap:(NSString*)polylineId {
  if (!polylineId) {
    return;
  }
  FLTGoogleMapPolylineController* controller = _polylineIdToController[polylineId];
  if (!controller) {
    return;
  }
  [_methodChannel invokeMethod:@"polyline#onTap" arguments:@{@"polylineId" : polylineId}];
}
- (bool)hasPolylineWithId:(NSString*)polylineId {
  if (!polylineId) {
    return false;
  }
  return _polylineIdToController[polylineId] != nil;
}
+ (GMSMutablePath*)getPath:(NSDictionary*)polyline {
  NSArray* pointArray = polyline[@"points"];
  NSArray<CLLocation*>* points = ToPoints(pointArray);
  GMSMutablePath* path = [GMSMutablePath path];
  for (CLLocation* location in points) {
    [path addCoordinate:location.coordinate];
  }
  return path;
}
+ (NSString*)getPolylineId:(NSDictionary*)polyline {
  return polyline[@"polylineId"];
}
@end
