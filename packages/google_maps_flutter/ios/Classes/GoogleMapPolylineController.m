// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapPolylineController.h"
#import "JsonConversions.h"

#define UIColorFromRGB(rgbValue)                                       \
  [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
                  green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0    \
                   blue:((float)(rgbValue & 0xFF)) / 255.0             \
                  alpha:1.0]

static uint64_t _nextPolylineId = 0;

@implementation FLTGoogleMapPolylineController {
  GMSPolyline* _polyline;
  GMSMapView* _mapView;
  BOOL _consumeTapEvents;
}
- (instancetype)initWithPath:(GMSPath*)path
                  polylineId:(NSString*)polylineId
                     mapView:(GMSMapView*)mapView {
  self = [super init];
  if (self) {
    _polyline = [GMSPolyline polylineWithPath:path];
    _mapView = mapView;
    _polylineId = polylineId;
    _polyline.userData = @[ _polylineId ];
    _consumeTapEvents = NO;
  }
  return self;
}

- (BOOL)consumeTapEvents {
  return _consumeTapEvents;
}
- (void)removePolyline {
  _polyline.map = nil;
}

#pragma mark - FLTGoogleMapPolylineOptionsSink methods

- (void)setConsumeTapEvents:(BOOL)consumes {
  _consumeTapEvents = consumes;
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

static double ToDouble(NSNumber* data) { return [FLTGoogleMapJsonConversions toDouble:data]; }

static float ToFloat(NSNumber* data) { return [FLTGoogleMapJsonConversions toFloat:data]; }

static CLLocationCoordinate2D ToLocation(NSArray* data) {
  return [FLTGoogleMapJsonConversions toLocation:data];
}

static int ToInt(NSNumber* data) { return [FLTGoogleMapJsonConversions toInt:data]; }

static BOOL ToBool(NSNumber* data) { return [FLTGoogleMapJsonConversions toBool:data]; }

static CGPoint ToPoint(NSArray* data) { return [FLTGoogleMapJsonConversions toPoint:data]; }

static GMSPath* ToPath(NSArray* data) { return [FLTGoogleMapJsonConversions toPath:data]; }

static void InterpretPolylineOptions(NSDictionary* data, id<FLTGoogleMapPolylineOptionsSink> sink,
                                     NSObject<FlutterPluginRegistrar>* registrar) {
  NSArray* points = data[@"points"];
  if (points) {
    [sink setPoints:ToPath(points)];
  }
  NSNumber* clickable = data[@"clickable"];
  if (clickable) {
    [sink setClickable:ToBool(clickable)];
  }
  NSNumber* color = data[@"color"];
  if (color) {
    [sink setColor:UIColorFromRGB(ToInt(color))];
  }
  NSNumber* geodesic = data[@"geodesic"];
  if (geodesic) {
    [sink setGeodesic:ToBool(geodesic)];
  }
  NSNumber* width = data[@"width"];
  if (width) {
    [sink setWidth:(CGFloat)ToFloat(width)];
  }
  NSNumber* visible = data[@"visible"];
  if (visible) {
    [sink setVisible:ToBool(visible)];
  }
  NSNumber* zIndex = data[@"zIndex"];
  if (zIndex) {
    [sink setZIndex:ToInt(zIndex)];
  }

  NSNumber* consumeTapEvents = data[@"consumeTapEvents"];
  if (consumeTapEvents) {
    [sink setConsumeTapEvents:ToBool(consumeTapEvents)];
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
    GMSPath* path = [FLTPolylinesController getPath:polyline];
    NSString* polylineId = [FLTPolylinesController getPolylineId:polyline];
    FLTGoogleMapPolylineController* controller =
        [[FLTGoogleMapPolylineController alloc] initWithPath:path
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
- (BOOL)onPolylineTap:(NSString*)polylineId {
  if (!polylineId) {
    return NO;
  }
  FLTGoogleMapPolylineController* controller = _polylineIdToController[polylineId];
  if (!controller) {
    return NO;
  }
  [_methodChannel invokeMethod:@"polyline#onTap" arguments:@{@"polylineId" : polylineId}];
  return controller.consumeTapEvents;
}

+ (GMSPath*)getPath:(NSDictionary*)polyline {
  NSArray* points = polyline[@"points"];
  return ToPath(points);
}
+ (NSString*)getPolylineId:(NSDictionary*)polyline {
  return polyline[@"polylineId"];
}
@end
