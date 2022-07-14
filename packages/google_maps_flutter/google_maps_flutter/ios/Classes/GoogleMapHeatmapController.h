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
- (void)setMinimumZoomIntensity:(int)intensity;
- (void)setMaximumZoomIntensity:(int)intensity;
- (void)setMap;
@end

// Defines heatmap controllable by Flutter.
@interface FLTGoogleMapHeatmapController : NSObject <FLTGoogleMapHeatmapOptionsSink>
@property(nonatomic, readonly) NSString *heatmapId;
@property(nonatomic, strong) GMUHeatmapTileLayer *heatmapTileLayer;
@property(nonatomic, strong) GMSMapView *mapView;
- (instancetype)initWithHeatmapTileLayer:(GMUHeatmapTileLayer *)heatmapTileLayer
                                 mapView:(GMSMapView *)mapView;
- (void)removeHeatmap;
- (void)clearTileCache;
@end

@interface FLTHeatmapsController : NSObject
@property(nonatomic, strong) NSMutableDictionary *heatmapIdToController;
@property(nonatomic, strong) GMSMapView *mapView;
- (instancetype)init:(GMSMapView *)mapView;
- (void)interpretOptions:(NSDictionary *)data sink:(id<FLTGoogleMapHeatmapOptionsSink>)sink;
- (void)addHeatmaps:(NSArray *)heatmapsToAdd;
- (void)changeHeatmaps:(NSArray *)heatmapsToChange;
- (void)removeHeatmapsWithIdentifiers:(NSArray *)heatmapIdsToRemove;
- (bool)hasHeatmapWithIdentifier:(NSString *)heatmapId;
@end
