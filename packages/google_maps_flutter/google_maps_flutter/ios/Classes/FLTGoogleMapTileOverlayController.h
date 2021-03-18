// Copyright 2018 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>

NS_ASSUME_NONNULL_BEGIN

// Defines map UI options writable from Flutter.
@protocol FLTGoogleMapTileOverlayOptionsSink
- (void)setFadeIn:(BOOL)fadeIn;
- (void)setTransparency:(float)transparency;
- (void)setZIndex:(int)zIndex;
- (void)setVisible:(BOOL)visible;
- (void)setTileSize:(NSInteger)tileSize;
@end

@interface FLTGoogleMapTileOverlayController : NSObject <FLTGoogleMapTileOverlayOptionsSink>
- (instancetype)initWithTileLayer:(GMSTileLayer *)tileLayer mapView:(GMSMapView *)mapView;
- (void)removeTileOverlay;
- (void)clearTileCache;
- (NSDictionary *)getTileOverlayInfo;
@end

@interface FLTTileProviderController : GMSTileLayer
@property(copy, nonatomic, readonly) NSString *tileOverlayId;
- (instancetype)init:(FlutterMethodChannel *)methodChannel tileOverlayId:(NSString *)tileOverlayId;
@end

@interface FLTTileOverlaysController : NSObject
- (instancetype)init:(FlutterMethodChannel *)methodChannel
             mapView:(GMSMapView *)mapView
           registrar:(NSObject<FlutterPluginRegistrar> *)registrar;
- (void)addTileOverlays:(NSArray *)tileOverlaysToAdd;
- (void)changeTileOverlays:(NSArray *)tileOverlaysToChange;
- (void)removeTileOverlayIds:(NSArray *)tileOverlayIdsToRemove;
- (void)clearTileCache:(NSString *)tileOverlayId;
- (nullable NSDictionary *)getTileOverlayInfo:(NSString *)tileverlayId;
@end

NS_ASSUME_NONNULL_END
