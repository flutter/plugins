// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTGoogleMapTileOverlayController.h"
#import "FLTGoogleMapJSONConversions.h"

@interface FLTGoogleMapTileOverlayController ()

@property(strong, nonatomic) GMSTileLayer *layer;
@property(weak, nonatomic) GMSMapView *mapView;

@end

@implementation FLTGoogleMapTileOverlayController

- (instancetype)initWithTileLayer:(GMSTileLayer *)tileLayer
                          mapView:(GMSMapView *)mapView
                          options:(NSDictionary *)optionsData {
  self = [super init];
  if (self) {
    _layer = tileLayer;
    _mapView = mapView;
    [self interpretTileOverlayOptions:optionsData];
  }
  return self;
}

- (void)removeTileOverlay {
  self.layer.map = nil;
}

- (void)clearTileCache {
  [self.layer clearTileCache];
}

- (NSDictionary *)getTileOverlayInfo {
  NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
  BOOL visible = self.layer.map != nil;
  info[@"visible"] = @(visible);
  info[@"fadeIn"] = @(self.layer.fadeIn);
  float transparency = 1.0 - self.layer.opacity;
  info[@"transparency"] = @(transparency);
  info[@"zIndex"] = @(self.layer.zIndex);
  return info;
}

- (void)setFadeIn:(BOOL)fadeIn {
  self.layer.fadeIn = fadeIn;
}

- (void)setTransparency:(float)transparency {
  float opacity = 1.0 - transparency;
  self.layer.opacity = opacity;
}

- (void)setVisible:(BOOL)visible {
  self.layer.map = visible ? self.mapView : nil;
}

- (void)setZIndex:(int)zIndex {
  self.layer.zIndex = zIndex;
}

- (void)setTileSize:(NSInteger)tileSize {
  self.layer.tileSize = tileSize;
}

- (void)interpretTileOverlayOptions:(NSDictionary *)data {
  if (!data) {
    return;
  }
  NSNumber *visible = data[@"visible"];
  if (visible != nil && visible != (id)[NSNull null]) {
    [self setVisible:visible.boolValue];
  }

  NSNumber *transparency = data[@"transparency"];
  if (transparency != nil && transparency != (id)[NSNull null]) {
    [self setTransparency:transparency.floatValue];
  }

  NSNumber *zIndex = data[@"zIndex"];
  if (zIndex != nil && zIndex != (id)[NSNull null]) {
    [self setZIndex:zIndex.intValue];
  }

  NSNumber *fadeIn = data[@"fadeIn"];
  if (fadeIn != nil && fadeIn != (id)[NSNull null]) {
    [self setFadeIn:fadeIn.boolValue];
  }

  NSNumber *tileSize = data[@"tileSize"];
  if (tileSize != nil && tileSize != (id)[NSNull null]) {
    [self setTileSize:tileSize.integerValue];
  }
}

@end

@interface FLTTileProviderController ()

@property(strong, nonatomic) FlutterMethodChannel *methodChannel;

@end

@implementation FLTTileProviderController

- (instancetype)init:(FlutterMethodChannel *)methodChannel
    withTileOverlayIdentifier:(NSString *)identifier {
  self = [super init];
  if (self) {
    _methodChannel = methodChannel;
    _tileOverlayIdentifier = identifier;
  }
  return self;
}

#pragma mark - GMSTileLayer method

- (void)requestTileForX:(NSUInteger)x
                      y:(NSUInteger)y
                   zoom:(NSUInteger)zoom
               receiver:(id<GMSTileReceiver>)receiver {
  [self.methodChannel
      invokeMethod:@"tileOverlay#getTile"
         arguments:@{
           @"tileOverlayId" : self.tileOverlayIdentifier,
           @"x" : @(x),
           @"y" : @(y),
           @"zoom" : @(zoom)
         }
            result:^(id _Nullable result) {
              UIImage *tileImage;
              if ([result isKindOfClass:[NSDictionary class]]) {
                FlutterStandardTypedData *typedData = (FlutterStandardTypedData *)result[@"data"];
                if (typedData == nil) {
                  tileImage = kGMSTileLayerNoTile;
                } else {
                  tileImage = [UIImage imageWithData:typedData.data];
                }
              } else {
                if ([result isKindOfClass:[FlutterError class]]) {
                  FlutterError *error = (FlutterError *)result;
                  NSLog(@"Can't get tile: errorCode = %@, errorMessage = %@, details = %@",
                        [error code], [error message], [error details]);
                }
                if ([result isKindOfClass:[FlutterMethodNotImplemented class]]) {
                  NSLog(@"Can't get tile: notImplemented");
                }
                tileImage = kGMSTileLayerNoTile;
              }

              [receiver receiveTileWithX:x y:y zoom:zoom image:tileImage];
            }];
}

@end

@interface FLTTileOverlaysController ()

@property(strong, nonatomic) NSMutableDictionary *tileOverlayIdentifierToController;
@property(strong, nonatomic) FlutterMethodChannel *methodChannel;
@property(weak, nonatomic) GMSMapView *mapView;

@end

@implementation FLTTileOverlaysController

- (instancetype)init:(FlutterMethodChannel *)methodChannel
             mapView:(GMSMapView *)mapView
           registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _methodChannel = methodChannel;
    _mapView = mapView;
    _tileOverlayIdentifierToController = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)addTileOverlays:(NSArray *)tileOverlaysToAdd {
  for (NSDictionary *tileOverlay in tileOverlaysToAdd) {
    NSString *identifier = [FLTTileOverlaysController identifierForTileOverlay:tileOverlay];
    FLTTileProviderController *tileProvider =
        [[FLTTileProviderController alloc] init:self.methodChannel
                      withTileOverlayIdentifier:identifier];
    FLTGoogleMapTileOverlayController *controller =
        [[FLTGoogleMapTileOverlayController alloc] initWithTileLayer:tileProvider
                                                             mapView:self.mapView
                                                             options:tileOverlay];
    self.tileOverlayIdentifierToController[identifier] = controller;
  }
}

- (void)changeTileOverlays:(NSArray *)tileOverlaysToChange {
  for (NSDictionary *tileOverlay in tileOverlaysToChange) {
    NSString *identifier = [FLTTileOverlaysController identifierForTileOverlay:tileOverlay];
    FLTGoogleMapTileOverlayController *controller =
        self.tileOverlayIdentifierToController[identifier];
    if (!controller) {
      continue;
    }
    [controller interpretTileOverlayOptions:tileOverlay];
  }
}
- (void)removeTileOverlayWithIdentifiers:(NSArray *)identifiers {
  for (NSString *identifier in identifiers) {
    FLTGoogleMapTileOverlayController *controller =
        self.tileOverlayIdentifierToController[identifier];
    if (!controller) {
      continue;
    }
    [controller removeTileOverlay];
    [self.tileOverlayIdentifierToController removeObjectForKey:identifier];
  }
}

- (void)clearTileCacheWithIdentifier:(NSString *)identifier {
  FLTGoogleMapTileOverlayController *controller =
      self.tileOverlayIdentifierToController[identifier];
  if (!controller) {
    return;
  }
  [controller clearTileCache];
}

- (nullable NSDictionary *)tileOverlayInfoWithIdentifier:(NSString *)identifier {
  if (self.tileOverlayIdentifierToController[identifier] == nil) {
    return nil;
  }
  return [self.tileOverlayIdentifierToController[identifier] getTileOverlayInfo];
}

+ (NSString *)identifierForTileOverlay:(NSDictionary *)tileOverlay {
  return tileOverlay[@"tileOverlayId"];
}

@end
