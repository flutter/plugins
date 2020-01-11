// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <Google-Maps-iOS-Utils/GMUHeatmapTileLayer.h>
#import <GoogleMaps/GoogleMaps.h>

// Defines heatmap UI options writable from Flutter.
@protocol FLTGoogleMapHeatmapOptionsSink
- (void)setPoints:(NSArray<GMUWeightedLatLng*>*)points;
- (void)setGradient:(GMUGradient*)gradient;
- (void)setRadius:(NSUInteger)radius;
- (void)setVisible:(BOOL)visible;
- (void)setOpacity:(double)opacity;
@end

// Defines heatmap controllable by Flutter.
@interface FLTGoogleMapHeatmapController : NSObject <FLTGoogleMapHeatmapOptionsSink>
@property(atomic, readonly) NSString* heatmapId;
- (instancetype)initHeatmapWithHeatmapId:(NSString*)heatmapId mapView:(GMSMapView*)mapView;
- (void)removeHeatmap;
@end

@interface FLTHeatmapsController : NSObject
- (instancetype)init:(FlutterMethodChannel*)methodChannel
             mapView:(GMSMapView*)mapView
           registrar:(NSObject<FlutterPluginRegistrar>*)registrar;
- (void)addHeatmaps:(NSArray*)heatmapsToAdd;
- (void)changeHeatmaps:(NSArray*)heatmapsToChange;
- (void)removeHeatmapIds:(NSArray*)heatmapIdsToRemove;
- (bool)hasHeatmapWithId:(NSString*)heatmapId;
@end
