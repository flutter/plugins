// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapHeatmapController.h"
#import "JsonConversions.h"
@import GoogleMapsUtils;

@implementation FLTGoogleMapHeatmapController {
  GMUHeatmapTileLayer *_heatmapTileLayer;
  GMSMapView *_mapView;
}
- (instancetype)initWithHeatmapTileLayer:(GMUHeatmapTileLayer *)heatmapTileLayer
                                 mapView:(GMSMapView *)mapView {
  self = [super init];
  if (self) {
    _heatmapTileLayer = heatmapTileLayer;
    _mapView = mapView;

    // Workaround for weird heatmap rendering compared to other platforms
    // Context:
    // https://github.com/googlemaps/google-maps-ios-utils/issues/143#issuecomment-343850029
    _heatmapTileLayer.minimumZoomIntensity = 0;
    _heatmapTileLayer.maximumZoomIntensity = 21;
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

- (void)setMap {
  _heatmapTileLayer.map = _mapView;
}
@end

static int ToInt(NSNumber *data) { return [FLTGoogleMapJsonConversions toInt:data]; }

static double ToDouble(NSNumber *data) { return [FLTGoogleMapJsonConversions toDouble:data]; }

static NSArray<GMUWeightedLatLng *> *ToWeightedData(NSArray *data) {
  return [FLTGoogleMapJsonConversions toWeightedData:data];
}

static GMUGradient *ToGradient(NSArray *data) {
  return [FLTGoogleMapJsonConversions toGradient:data];
}

static void InterpretHeatmapOptions(NSDictionary *data, id<FLTGoogleMapHeatmapOptionsSink> sink) {
  NSArray *weightedData = data[@"data"];
  if (weightedData != nil) {
    [sink setWeightedData:ToWeightedData(weightedData)];
  }

  NSArray *gradient = data[@"gradient"];
  if (gradient != nil) {
    [sink setGradient:ToGradient(gradient)];
  }

  NSNumber *opacity = data[@"opacity"];
  if (opacity != nil) {
    [sink setOpacity:ToDouble(opacity)];
  }

  NSNumber *radius = data[@"radius"];
  if (radius != nil) {
    [sink setRadius:ToInt(radius)];
  }

  // The map must be set each time for options to update
  [sink setMap];
}

@implementation FLTHeatmapsController {
  NSMutableDictionary *_heatmapIdToController;
  GMSMapView *_mapView;
}
- (instancetype)init:(GMSMapView *)mapView {
  self = [super init];
  if (self) {
    _mapView = mapView;
    _heatmapIdToController = [NSMutableDictionary dictionaryWithCapacity:1];
  }
  return self;
}
- (void)addHeatmaps:(NSArray *)heatmapsToAdd {
  for (NSDictionary *heatmap in heatmapsToAdd) {
    NSString *heatmapId = [FLTHeatmapsController getHeatmapId:heatmap];
    GMUHeatmapTileLayer *heatmapTileLayer = [[GMUHeatmapTileLayer alloc] init];
    FLTGoogleMapHeatmapController *controller =
        [[FLTGoogleMapHeatmapController alloc] initWithHeatmapTileLayer:heatmapTileLayer
                                                                mapView:_mapView];
    InterpretHeatmapOptions(heatmap, controller);
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
    InterpretHeatmapOptions(heatmap, controller);

    [controller clearTileCache];
  }
}
- (void)removeHeatmapIds:(NSArray *)heatmapIdsToRemove {
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
    return false;
  }
  return _heatmapIdToController[heatmapId] != nil;
}
+ (NSString *)getHeatmapId:(NSDictionary *)heatmap {
  return heatmap[@"heatmapId"];
}
@end
