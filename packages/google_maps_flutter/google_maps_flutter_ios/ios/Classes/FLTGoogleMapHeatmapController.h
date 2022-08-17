// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>
@import GoogleMapsUtils;

// Defines heatmap controllable by Flutter.
@interface FLTGoogleMapHeatmapController : NSObject
- (instancetype)initWithHeatmapTileLayer:(GMUHeatmapTileLayer *)heatmapTileLayer
                                 mapView:(GMSMapView *)mapView
                                 options:(NSDictionary *)options;
- (void)removeHeatmap;
- (void)clearTileCache;
@end

@interface FLTHeatmapsController : NSObject
- (instancetype)init:(GMSMapView *)mapView;
- (void)addHeatmaps:(NSArray *)heatmapsToAdd;
- (void)changeHeatmaps:(NSArray *)heatmapsToChange;
- (void)removeHeatmapsWithIdentifiers:(NSArray *)identifiers;
- (bool)hasHeatmapWithIdentifier:(NSString *)identifier;
@end
