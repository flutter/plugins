// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapPolylineController.h"
#import "JsonConversions.h"

static uint64_t _nextPolylineId = 0;

@implementation FLTGoogleMapPolylineController {
  GMSPolyline *_polyline;
  GMSMapView *_mapView;
  BOOL _consumeTapEvents;
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

- (BOOL)consumeTapEvents {
    return _consumeTapEvents;
}
- (void)removePolyline {
    _polyline.map = nil;
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

static double ToDouble(NSNumber* data) { return [FLTGoogleMapJsonConversions toDouble:data]; }

static float ToFloat(NSNumber* data) { return [FLTGoogleMapJsonConversions toFloat:data]; }

static CLLocationCoordinate2D ToLocation(NSArray* data) {
    return [FLTGoogleMapJsonConversions toLocation:data];
}

static int ToInt(NSNumber* data) { return [FLTGoogleMapJsonConversions toInt:data]; }

static BOOL ToBool(NSNumber* data) { return [FLTGoogleMapJsonConversions toBool:data]; }

static CGPoint ToPoint(NSArray* data) { return [FLTGoogleMapJsonConversions toPoint:data]; }

static NSMutableArray* ToPoints(NSArray* data) { return [FLTGoogleMapJsonConversions toPoints:data]; }

static UIColor* ToColor(NSArray* data) { return [FLTGoogleMapJsonConversions toColor:data]; }

static void InterpretPolylineOptions(NSDictionary* data, id<FLTGoogleMapPolylineOptionsSink> sink,
                                   NSObject<FlutterPluginRegistrar>* registrar) {
    
    NSNumber* consumeTapEvents = data[@"consumeTapEvents"];
    if (consumeTapEvents) {
        [sink setConsumeTapEvents:ToBool(consumeTapEvents)];
    }
    
    NSNumber* visible = data[@"visible"];
    if (visible) {
        [sink setVisible:ToBool(visible)];
    }
    
    NSNumber* zIndex = data[@"zIndex"];
    if (zIndex) {
        [sink setZIndex:ToInt(zIndex)];
    }
    
    id points = data[@"points"];
    if (points) {
        [sink setPoints:ToPoints(points)];
    }
    
    id strokeColor = data[@"strokeColor"];
    if (strokeColor) {
        [sink setColor:ToPoints(strokeColor)];
    }

    id strokeWidth = data[@"strokeWidth"];
    if (strokeWidth) {
        [sink setStrokeWidth:ToFloat(strokeWidth)];
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
        //todo fetch every parameter and map it
        NSString* polylineId = [FLTPolylinesController getPolylineId:polyline];
        FLTGoogleMapPolylineController* controller =
        [[FLTGoogleMapPolylineController alloc] init:_mapView];
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

+ (NSString*)getPolylineId:(NSDictionary*)polyline {
    return polyline[@"polylineId"];
}
@end

