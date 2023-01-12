// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTGoogleMapHeatmapController.h"
#import "FLTGoogleMapJSONConversions.h"
@import GoogleMapsUtils;

@interface FLTGoogleMapHeatmapController ()

@property(nonatomic, strong) GMUHeatmapTileLayer *heatmapTileLayer;
@property(nonatomic, weak) GMSMapView *mapView;

@end

@implementation FLTGoogleMapHeatmapController
- (instancetype)initWithHeatmapTileLayer:(GMUHeatmapTileLayer *)heatmapTileLayer
                                 mapView:(GMSMapView *)mapView
                                 options:(NSDictionary *)options {
  self = [super init];
  if (self) {
    _heatmapTileLayer = heatmapTileLayer;
    _mapView = mapView;
    [self interpretHeatmapOptions:options];
  }
  return self;
}

- (void)removeHeatmap {
  _heatmapTileLayer.map = nil;
}

- (void)clearTileCache {
  [_heatmapTileLayer clearTileCache];
}

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
- (void)interpretHeatmapOptions:(NSDictionary *)data {
  NSArray *weightedData = data[@"data"];
  if (weightedData != nil && weightedData != (id)[NSNull null]) {
    [self setWeightedData:[FLTGoogleMapJSONConversions weightedDataFromArray:weightedData]];
  }

  NSDictionary *gradient = data[@"gradient"];
  if (gradient != nil && gradient != (id)[NSNull null]) {
    [self setGradient:[FLTGoogleMapJSONConversions gradientFromDictionary:gradient]];
  }

  NSNumber *opacity = data[@"opacity"];
  if (opacity != nil && opacity != (id)[NSNull null]) {
    [self setOpacity:[opacity doubleValue]];
  }

  NSNumber *radius = data[@"radius"];
  if (radius != nil && radius != (id)[NSNull null]) {
    [self setRadius:[radius intValue]];
  }

  NSNumber *minimumZoomIntensity = data[@"minimumZoomIntensity"];
  if (minimumZoomIntensity != nil && minimumZoomIntensity != (id)[NSNull null]) {
    [self setMinimumZoomIntensity:[minimumZoomIntensity intValue]];
  }

  NSNumber *maximumZoomIntensity = data[@"maximumZoomIntensity"];
  if (maximumZoomIntensity != nil && maximumZoomIntensity != (id)[NSNull null]) {
    [self setMaximumZoomIntensity:[maximumZoomIntensity intValue]];
  }

  // The map must be set each time for options to update
  [self setMap];
}
- (NSDictionary *)getHeatmapInfo {
  NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
  options[@"data"] =
      [FLTGoogleMapJSONConversions arrayFromWeightedData:_heatmapTileLayer.weightedData];
  options[@"gradient"] =
      [FLTGoogleMapJSONConversions dictionaryFromGradient:_heatmapTileLayer.gradient];
  options[@"opacity"] = @(_heatmapTileLayer.opacity);
  options[@"radius"] = @(_heatmapTileLayer.radius);
  options[@"minimumZoomIntensity"] = @(_heatmapTileLayer.minimumZoomIntensity);
  options[@"maximumZoomIntensity"] = @(_heatmapTileLayer.maximumZoomIntensity);
  return options;
}
@end

@interface FLTHeatmapsController ()

@property(nonatomic, strong) NSMutableDictionary *heatmapIdToController;
@property(nonatomic, weak) GMSMapView *mapView;

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
- (void)addHeatmaps:(NSArray *)heatmapsToAdd {
  for (NSDictionary *heatmap in heatmapsToAdd) {
    NSString *heatmapId = [FLTHeatmapsController getHeatmapIdentifier:heatmap];
    GMUHeatmapTileLayer *heatmapTileLayer = [[GMUHeatmapTileLayer alloc] init];
    FLTGoogleMapHeatmapController *controller =
        [[FLTGoogleMapHeatmapController alloc] initWithHeatmapTileLayer:heatmapTileLayer
                                                                mapView:_mapView
                                                                options:heatmap];
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
    [controller interpretHeatmapOptions:heatmap];

    [controller clearTileCache];
  }
}
- (void)removeHeatmapsWithIdentifiers:(NSArray *)identifiers {
  for (NSString *heatmapId in identifiers) {
    FLTGoogleMapHeatmapController *controller = _heatmapIdToController[heatmapId];
    if (!controller) {
      continue;
    }
    [controller removeHeatmap];
    [_heatmapIdToController removeObjectForKey:heatmapId];
  }
}
- (bool)hasHeatmapWithIdentifier:(NSString *)identifier {
  if (!identifier) {
    return NO;
  }
  return _heatmapIdToController[identifier] != nil;
}
- (nullable NSDictionary *)heatmapInfoWithIdentifier:(NSString *)identifier {
  if (self.heatmapIdToController[identifier] == nil) {
    return nil;
  }
  return [self.heatmapIdToController[identifier] getHeatmapInfo];
}
+ (NSString *)getHeatmapIdentifier:(NSDictionary *)heatmap {
  return heatmap[@"heatmapId"];
}
@end
