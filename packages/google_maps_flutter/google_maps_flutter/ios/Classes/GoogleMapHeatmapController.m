// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapHeatmapController.h"
#import "JsonConversions.h"
@import GoogleMapsUtils;

@implementation FLTGoogleMapHeatmapController
- (instancetype)initWithHeatmapTileLayer:(GMUHeatmapTileLayer *)heatmapTileLayer
                                 mapView:(GMSMapView *)mapView {
  self = [super init];
  if (self) {
    _heatmapTileLayer = heatmapTileLayer;
    _mapView = mapView;
  }
  return self;
}

- (void)removeHeatmap {
  _heatmapTileLayer.map = nil;
}

- (void)clearTileCache {
  [_heatmapTileLayer clearTileCache];
}

#pragma mark - FLTGoogleMapHeatmapOptionsSink methods

- (void)setWeightedData:(NSArray<GMUWeightedLatLng *> *)weightedData {
  _heatmapTileLayer.weightedData = weightedData;
}

- (void)setGradient:(GMUGradient *)gradient {
  _heatmapTileLayer.gradient = gradient;
}

- (void)setOpacity:(double)opacity {
  _heatmapTileLayer.opacity = opacity;
}

- (void)setRadius:(int)radius {
  _heatmapTileLayer.radius = radius;
}

- (void)setMinimumZoomIntensity:(int)intensity {
  _heatmapTileLayer.minimumZoomIntensity = intensity;
}

- (void)setMaximumZoomIntensity:(int)intensity {
  _heatmapTileLayer.maximumZoomIntensity = intensity;
}

- (void)setMap {
  _heatmapTileLayer.map = _mapView;
}
@end

@implementation FLTHeatmapsController
- (instancetype)init:(GMSMapView *)mapView {
  self = [super init];
  if (self) {
    _mapView = mapView;
    _heatmapIdToController = [[NSMutableDictionary alloc] init];
  }
  return self;
}
- (void)interpretOptions:(NSDictionary *)data sink:(id<FLTGoogleMapHeatmapOptionsSink>)sink {
  NSArray *weightedData = data[@"data"];
  if (weightedData != nil) {
    [sink setWeightedData:[FLTGoogleMapJsonConversions toWeightedData:weightedData]];
  }

  NSArray *gradient = data[@"gradient"];
  if (gradient != nil) {
    [sink setGradient:[FLTGoogleMapJsonConversions toGradient:gradient]];
  }

  NSNumber *opacity = data[@"opacity"];
  if (opacity != nil) {
    [sink setOpacity:[FLTGoogleMapJsonConversions toDouble:opacity]];
  }

  NSNumber *radius = data[@"radius"];
  if (radius != nil) {
    [sink setRadius:[FLTGoogleMapJsonConversions toInt:radius]];
  }

  NSNumber *minimumZoomIntensity = data[@"minimumZoomIntensity"];
  if (minimumZoomIntensity != nil) {
    [sink setMinimumZoomIntensity:[FLTGoogleMapJsonConversions toInt:minimumZoomIntensity]];
  }

  NSNumber *maximumZoomIntensity = data[@"maximumZoomIntensity"];
  if (maximumZoomIntensity != nil) {
    [sink setMaximumZoomIntensity:[FLTGoogleMapJsonConversions toInt:maximumZoomIntensity]];
  }

  // The map must be set each time for options to update
  [sink setMap];
}
- (void)addHeatmaps:(NSArray *)heatmapsToAdd {
  for (NSDictionary *heatmap in heatmapsToAdd) {
    NSString *heatmapId = [FLTHeatmapsController getHeatmapId:heatmap];
    GMUHeatmapTileLayer *heatmapTileLayer = [[GMUHeatmapTileLayer alloc] init];
    FLTGoogleMapHeatmapController *controller =
        [[FLTGoogleMapHeatmapController alloc] initWithHeatmapTileLayer:heatmapTileLayer
                                                                mapView:_mapView];
    [self interpretOptions:heatmap sink:controller];
    _heatmapIdToController[heatmapId] = controller;
  }
}
- (void)changeHeatmaps:(NSArray *)heatmapsToChange {
  for (NSDictionary *heatmap in heatmapsToChange) {
    NSString *heatmapId = [FLTHeatmapsController getHeatmapId:heatmap];
    FLTGoogleMapHeatmapController *controller = _heatmapIdToController[heatmapId];
    if (!controller) {
      continue;
    }
    [self interpretOptions:heatmap sink:controller];

    [controller clearTileCache];
  }
}
- (void)removeHeatmapsWithIds:(NSArray *)heatmapIdsToRemove {
  for (NSString *heatmapId in heatmapIdsToRemove) {
    if (!heatmapId) {
      continue;
    }
    FLTGoogleMapHeatmapController *controller = _heatmapIdToController[heatmapId];
    if (!controller) {
      continue;
    }
    [controller removeHeatmap];
    [_heatmapIdToController removeObjectForKey:heatmapId];
  }
}
- (bool)hasHeatmapWithId:(NSString *)heatmapId {
  if (!heatmapId) {
    return NO;
  }
  return _heatmapIdToController[heatmapId] != nil;
}
+ (NSString *)getHeatmapId:(NSDictionary *)heatmap {
  return heatmap[@"heatmapId"];
}
@end
