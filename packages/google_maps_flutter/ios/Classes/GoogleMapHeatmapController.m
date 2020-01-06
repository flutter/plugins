// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapHeatmapController.h"
#import "JsonConversions.h"

@implementation FLTGoogleMapHeatmapController {
  GMUHeatmapTileLayer* _heatmapLayer;
  GMSMapView* _mapView;
}
- (instancetype)initHeatmapWithPath:(GMSMutablePath*)path
                          heatmapId:(NSString*)heatmapId
                             mapView:(GMSMapView*)mapView {
  self = [super init];
  if (self) {
    _heatmapLayer = GMUHeatmapTileLayer();
    _heatmapLayer.map = mapView;
    _mapView = mapView;
    _heatmapId = heatmapId;
    _heatmapLayer.userData = @[ heatmapId ];
  }
  return self;
}

- (void)removeHeatmap {
  _heatmapLayer.map = nil;
}

#pragma mark - FLTGoogleMapHeatmapOptionsSink methods

- (void)setVisible:(BOOL)visible {
  _heatmapLayer.map = visible ? _mapView : nil;
}
- (void)setRadius:(NSUInteger)radius {
  _heatmapLayer.radius(radius);
  clearTileCache();
}
- (void)setGradient:(GMUGradient *)gradient {
  _heatmapLayer.gradient(gradient);
  clearTileCache();
}
- (void)setPoints:(NSArray<GMUWeightedLatLng *>*)points {
  _heatmapLayer.weightedData(points);
  clearTileCache();
}
- (void)clearTileCache:() {
  _heatmapLayer.clearTileCache();
}

@end

static int ToInt(NSNumber* data) { return [FLTGoogleMapJsonConversions toInt:data]; }

static BOOL ToBool(NSNumber* data) { return [FLTGoogleMapJsonConversions toBool:data]; }

static NSArray<CLLocation*>* ToPoints(NSArray* data) {
  return [FLTGoogleMapJsonConversions toPoints:data];
}

static NSArray<UIColor*>* ToColors(NSArray* data) {
  NSMutableArray* colors = [[NSMutableArray alloc] init];
  for (unsigned i = 0; i < [data count]; i++) {
    UIColor* color = data[i];
    [colors addObject:color];
  }

  return colors;
}

static NSArray<NSNumber*>* ToStartsPoints(NSArray* data) {
  NSMutableArray* startPoints = [[NSMutableArray alloc] init];
  for (unsigned i = 0; i < [data count]; i++) {
    NSNumber* startPoints = data[i];
    [startPoints addObject:startPoint];
  }

  return startPoints;
}

static GMUGradient* ToGradient(NSArray* data) {
  GMUGradient* gradient =
        [[GMUGradient alloc] initWithColors:ToColors(data[0])
                                startPoints:ToStartsPoints(data[1])
                               colorMapSize:ToInt(data[2])];
  return gradient;
}

static void InterpretHeatmapOptions(NSDictionary* data, id<FLTGoogleMapHeatmapOptionsSink> sink,
                                     NSObject<FlutterPluginRegistrar>* registrar) {
  NSNumber* visible = data[@"visible"];
  if (visible != nil) {
    [sink setVisible:ToBool(visible)];
  }

  NSNumber* radius = data[@"radius"];
  if (radius != nil) {
    [sink setRadius:ToInt(radius)];
  }

  GMUGradient* gradient = data[@"gradient"];
  if (gradient != nil) {
    [sink setGradient:ToGradient(gradient)];
  }

  NSArray* points = data[@"points"];
  if (points) {
    [sink setPoints:ToPoints(points)];
  }
}

@implementation FLTHeatmapsController {
  NSMutableDictionary* _heatmapIdToController;
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
    _heatmapIdToController = [NSMutableDictionary dictionaryWithCapacity:1];
    _registrar = registrar;
  }
  return self;
}
- (void)addHeatmaps:(NSArray*)heatmapsToAdd {
  for (NSDictionary* heatmap in heatmapsToAdd) {
    GMSMutablePath* path = [FLTHeatmapsController getPath:heatmap];
    NSString* heatmapId = [FLTHeatmapsController getHeatmapId:heatmap];
    FLTGoogleMapHeatmapController* controller =
        [[FLTGoogleMapHeatmapController alloc] initHeatmapWithPath:path
                                                          heatmapId:heatmapId
                                                             mapView:_mapView];
    InterpretHeatmapOptions(heatmap, controller, _registrar);
    _heatmapIdToController[heatmapId] = controller;
  }
}
- (void)changeHeatmaps:(NSArray*)heatmapsToChange {
  for (NSDictionary* heatmap in heatmapsToChange) {
    NSString* heatmapId = [FLTHeatmapsController getHeatmapId:heatmap];
    FLTGoogleMapHeatmapController* controller = _heatmapIdToController[heatmapId];
    if (!controller) {
      continue;
    }
    InterpretHeatmapOptions(heatmap, controller, _registrar);
  }
}
- (void)removeHeatmapIds:(NSArray*)heatmapIdsToRemove {
  for (NSString* heatmapId in heatmapIdsToRemove) {
    if (!heatmapId) {
      continue;
    }
    FLTGoogleMapHeatmapController* controller = _heatmapIdToController[heatmapId];
    if (!controller) {
      continue;
    }
    [controller removeHeatmap];
    [_heatmapIdToController removeObjectForKey:heatmapId];
  }
}
- (bool)hasHeatmapWithId:(NSString*)heatmapId {
  if (!heatmapId) {
    return false;
  }
  return _heatmapIdToController[heatmapId] != nil;
}
+ (GMSMutablePath*)getPath:(NSDictionary*)heatmap {
  NSArray* pointArray = heatmap[@"points"];
  NSArray<CLLocation*>* points = ToPoints(pointArray);
  GMSMutablePath* path = [GMSMutablePath path];
  for (CLLocation* location in points) {
    [path addCoordinate:location.coordinate];
  }
  return path;
}
+ (NSString*)getHeatmapId:(NSDictionary*)heatmap {
  return heatmap[@"heatmapId"];
}
@end
