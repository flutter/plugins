// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapHeatmapController.h"
#import "FLTGoogleMapJSONConversions.h"
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
    [sink setWeightedData:[FLTGoogleMapJSONConversions weightedDataFromArray:weightedData]];
  }

  NSDictionary *gradient = data[@"gradient"];
  if (gradient != nil) {
    [sink setGradient:[FLTGoogleMapJSONConversions gradientFromDictionary:gradient]];
  }

  NSNumber *opacity = data[@"opacity"];
  if (opacity != nil) {
    [sink setOpacity:[opacity doubleValue]];
  }

  NSNumber *radius = data[@"radius"];
  if (radius != nil) {
    [sink setRadius:[radius intValue]];
  }

  NSNumber *minimumZoomIntensity = data[@"minimumZoomIntensity"];
  if (minimumZoomIntensity != nil) {
    [sink setMinimumZoomIntensity:[minimumZoomIntensity intValue]];
  }

  NSNumber *maximumZoomIntensity = data[@"maximumZoomIntensity"];
  if (maximumZoomIntensity != nil) {
    [sink setMaximumZoomIntensity:[maximumZoomIntensity intValue]];
  }

  // The map must be set each time for options to update
  [sink setMap];
}
- (void)addHeatmaps:(NSArray *)heatmapsToAdd {
  for (NSDictionary *heatmap in heatmapsToAdd) {
    NSString *heatmapId = [FLTHeatmapsController getHeatmapIdentifier:heatmap];
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
    NSString *heatmapId = [FLTHeatmapsController getHeatmapIdentifier:heatmap];
    FLTGoogleMapHeatmapController *controller = _heatmapIdToController[heatmapId];
    if (!controller) {
      continue;
    }
    [self interpretOptions:heatmap sink:controller];

    [controller clearTileCache];
  }
}
- (void)removeHeatmapsWithIdentifiers:(NSArray *)heatmapIdsToRemove {
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
- (bool)hasHeatmapWithIdentifier:(NSString *)heatmapId {
  if (!heatmapId) {
    return NO;
  }
  return _heatmapIdToController[heatmapId] != nil;
}
+ (NSString *)getHeatmapIdentifier:(NSDictionary *)heatmap {
  return heatmap[@"heatmapId"];
}
@end
