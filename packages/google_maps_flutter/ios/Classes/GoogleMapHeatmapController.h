// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>

// Defines heatmap UI options writable from Flutter.
@protocol FLTGoogleMapHeatmapOptionsSink
- (void)setPoints:(NSArray<CLLocation*>*)points;
- (void)setGradient:(GMUGradient)gradient;
- (void)setOpacity:(double)opacity;
- (void)setRadius:(NSUInteger)radius;
- (void)setFadeIn:(BOOL)fadeIn;
- (void)setTransparency:(CGFloat)transparency;
- (void)setVisible:(BOOL)visible;
- (void)setZIndex:(NSUInteger)zIndex;
@end

// Defines heatmap controllable by Flutter.
@interface FLTGoogleMapHeatmapController : NSObject <FLTGoogleMapHeatmapOptionsSink>
@property(atomic, readonly) NSString* heatmapId;
- (instancetype)initHeatmapWithPath:(GMSMutablePath*)path
                          heatmapId:(NSString*)heatmapId
                             mapView:(GMSMapView*)mapView;
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
