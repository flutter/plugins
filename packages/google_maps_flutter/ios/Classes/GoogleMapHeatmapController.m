// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapHeatmapController.h"
#import "JsonConversions.h"

@implementation FLTGoogleMapHeatmapController {
  GMUHeatmapTileLayer* _heatmapLayer;
  GMSMapView* _mapView;
}
- (instancetype)initHeatmapWithHeatmapId:(NSString*)heatmapId mapView:(GMSMapView*)mapView {
  self = [super init];
  if (self) {
    _heatmapLayer = [[GMUHeatmapTileLayer alloc] init];
    _heatmapLayer.map = mapView;
    _mapView = mapView;
    _heatmapId = heatmapId;
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
  [_heatmapLayer setRadius:radius];
  [_heatmapLayer clearTileCache];
}
- (void)setGradient:(GMUGradient*)gradient {
  [_heatmapLayer setGradient:gradient];
  [_heatmapLayer clearTileCache];
}
- (void)setPoints:(NSArray<GMUWeightedLatLng*>*)points {
  [_heatmapLayer setWeightedData:points];
  [_heatmapLayer clearTileCache];
}
- (void)setOpacity:(double)opacity {
  _heatmapLayer.opacity = opacity;
  [_heatmapLayer clearTileCache];
}

@end

static int ToInt(NSNumber* data) { return [FLTGoogleMapJsonConversions toInt:data]; }

static double ToDouble(NSNumber* data) { return [FLTGoogleMapJsonConversions toDouble:data]; }

static BOOL ToBool(NSNumber* data) { return [FLTGoogleMapJsonConversions toBool:data]; }

static NSArray<GMUWeightedLatLng*>* ToPoints(NSArray* data) {
  NSMutableArray* points = [[NSMutableArray alloc] init];
  for (unsigned i = 0; i < [data count]; i++) {
    NSNumber* latitude = data[i][0][0];
    NSNumber* longitude = data[i][0][1];
    NSNumber* intensity = data[i][1];
    GMUWeightedLatLng* weightedPoint = [[GMUWeightedLatLng alloc]
        initWithCoordinate:CLLocationCoordinate2DMake(
                               [FLTGoogleMapJsonConversions toDouble:latitude],
                               [FLTGoogleMapJsonConversions toDouble:longitude])
                 intensity:[FLTGoogleMapJsonConversions toFloat:intensity]];
    [points addObject:weightedPoint];
  }

  return points;
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
    NSNumber* startPoint = data[i];
    [startPoints addObject:startPoint];
  }

  return startPoints;
}

static GMUGradient* ToGradient(NSArray* data) {
  GMUGradient* gradient = [[GMUGradient alloc] initWithColors:ToColors(data[0])
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

  NSArray* gradient = data[@"gradient"];
  if (gradient != nil) {
    [sink setGradient:ToGradient(gradient)];
  }

  NSArray* points = data[@"points"];
  if (points) {
    [sink setPoints:ToPoints(points)];
  }

  NSNumber* opacity = data[@"opacity"];
  if (opacity) {
    [sink setOpacity:ToDouble(opacity)];
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
    NSString* heatmapId = [FLTHeatmapsController getHeatmapId:heatmap];
    FLTGoogleMapHeatmapController* controller =
        [[FLTGoogleMapHeatmapController alloc] initHeatmapWithHeatmapId:heatmapId mapView:_mapView];
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
+ (NSString*)getHeatmapId:(NSDictionary*)heatmap {
  return heatmap[@"heatmapId"];
}
@end
