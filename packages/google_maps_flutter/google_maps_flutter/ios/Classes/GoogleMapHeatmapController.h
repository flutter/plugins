// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>
@import GoogleMapsUtils;

// Defines heatmap UI options writable from Flutter.
@protocol FLTGoogleMapHeatmapOptionsSink
- (void)setWeightedData:(NSArray<GMUWeightedLatLng *> *)weightedData;
- (void)setGradient:(GMUGradient *)gradient;
- (void)setOpacity:(double)opacity;
- (void)setRadius:(int)radius;
- (void)setMap;
@end

// Defines heatmap controllable by Flutter.
@interface FLTGoogleMapHeatmapController : NSObject <FLTGoogleMapHeatmapOptionsSink>
@property(atomic, readonly) NSString *heatmapId;
- (instancetype)initWithHeatmapTileLayer:(GMUHeatmapTileLayer *)heatmap
                                 mapView:(GMSMapView *)mapView;
- (void)removeHeatmap;
- (void)clearTileCache;
@end

@interface FLTHeatmapsController : NSObject
- (instancetype)init:(GMSMapView *)mapView;
- (void)addHeatmaps:(NSArray *)heatmapsToAdd;
- (void)changeHeatmaps:(NSArray *)heatmapsToChange;
- (void)removeHeatmapIds:(NSArray *)heatmapIdsToRemove;
- (bool)hasHeatmapWithId:(NSString *)heatmapId;
@end
