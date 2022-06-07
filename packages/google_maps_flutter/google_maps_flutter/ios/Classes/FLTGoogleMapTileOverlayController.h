// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLTGoogleMapTileOverlayController : NSObject
- (instancetype)initWithTileLayer:(GMSTileLayer *)tileLayer
                          mapView:(GMSMapView *)mapView
                          options:(NSDictionary *)optionsData;
- (void)removeTileOverlay;
- (void)clearTileCache;
- (NSDictionary *)getTileOverlayInfo;
@end

@interface FLTTileProviderController : GMSTileLayer
@property(copy, nonatomic, readonly) NSString *tileOverlayIdentifier;
- (instancetype)init:(FlutterMethodChannel *)methodChannel
    withTileOverlayIdentifier:(NSString *)identifier;
@end

@interface FLTTileOverlaysController : NSObject
- (instancetype)init:(FlutterMethodChannel *)methodChannel
             mapView:(GMSMapView *)mapView
           registrar:(NSObject<FlutterPluginRegistrar> *)registrar;
- (void)addTileOverlays:(NSArray *)tileOverlaysToAdd;
- (void)changeTileOverlays:(NSArray *)tileOverlaysToChange;
- (void)removeTileOverlayWithIdentifiers:(NSArray *)identifiers;
- (void)clearTileCacheWithIdentifier:(NSString *)identifier;
- (nullable NSDictionary *)tileOverlayInfoWithIdentifier:(NSString *)identifier;
@end

NS_ASSUME_NONNULL_END
