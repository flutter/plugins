// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTGoogleMapTileOverlayController.h"
#import "JsonConversions.h"

static void InterpretTileOverlayOptions(NSDictionary* data,
                                        id<FLTGoogleMapTileOverlayOptionsSink> sink,
                                        NSObject<FlutterPluginRegistrar>* registrar) {
  NSNumber* visible = data[@"visible"];
  if (visible != nil) {
    [sink setVisible:visible.boolValue];
  }

  NSNumber* transparency = data[@"transparency"];
  if (transparency != nil) {
    [sink setTransparency:transparency.floatValue];
  }

  NSNumber* zIndex = data[@"zIndex"];
  if (zIndex != nil) {
    [sink setZIndex:zIndex.intValue];
  }

  NSNumber* fadeIn = data[@"fadeIn"];
  if (fadeIn != nil) {
    [sink setFadeIn:fadeIn.boolValue];
  }

  NSNumber* tileSize = data[@"tileSize"];
  if (tileSize != nil) {
    [sink setTileSize:tileSize.integerValue];
  }
}

@interface FLTGoogleMapTileOverlayController ()

@property(strong, nonatomic) GMSTileLayer* layer;
@property(weak, nonatomic) GMSMapView* mapView;

@end

@implementation FLTGoogleMapTileOverlayController

- (instancetype)initWithTileLayer:(GMSTileLayer*)tileLayer mapView:(GMSMapView*)mapView {
  self = [super init];
  if (self) {
    self.layer = tileLayer;
    self.mapView = mapView;
  }
  return self;
}

- (void)removeTileOverlay {
  self.layer.map = nil;
}

- (void)clearTileCache {
  [self.layer clearTileCache];
}

- (NSDictionary*)getTileOverlayInfo {
  NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
  BOOL visible = self.layer.map != nil;
  info[@"visible"] = @(visible);
  info[@"fadeIn"] = @(self.layer.fadeIn);
  float transparency = 1.0 - self.layer.opacity;
  info[@"transparency"] = @(transparency);
  info[@"zIndex"] = @(self.layer.zIndex);
  return info;
}

#pragma mark - FLTGoogleMapTileOverlayOptionsSink methods

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
@end

@interface FLTTileProviderController ()

@property(weak, nonatomic) FlutterMethodChannel* methodChannel;
@property(copy, nonatomic, readwrite) NSString* tileOverlayId;

@end

@implementation FLTTileProviderController

- (instancetype)init:(FlutterMethodChannel*)methodChannel tileOverlayId:(NSString*)tileOverlayId {
  self = [super init];
  if (self) {
    self.methodChannel = methodChannel;
    self.tileOverlayId = tileOverlayId;
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
           @"tileOverlayId" : self.tileOverlayId,
           @"x" : @(x),
           @"y" : @(y),
           @"zoom" : @(zoom)
         }
            result:^(id _Nullable result) {
              UIImage* tileImage;
              if ([result isKindOfClass:[NSDictionary class]]) {
                FlutterStandardTypedData* typedData = (FlutterStandardTypedData*)result[@"data"];
                if (typedData == nil) {
                  tileImage = kGMSTileLayerNoTile;
                } else {
                  tileImage = [UIImage imageWithData:typedData.data];
                }
              } else {
                if ([result isKindOfClass:[FlutterError class]]) {
                  FlutterError* error = (FlutterError*)result;
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

@property(strong, nonatomic) NSMutableDictionary* tileOverlayIdToController;
@property(weak, nonatomic) FlutterMethodChannel* methodChannel;
@property(weak, nonatomic) NSObject<FlutterPluginRegistrar>* registrar;
@property(weak, nonatomic) GMSMapView* mapView;

@end

@implementation FLTTileOverlaysController

- (instancetype)init:(FlutterMethodChannel*)methodChannel
             mapView:(GMSMapView*)mapView
           registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  self = [super init];
  if (self) {
    self.methodChannel = methodChannel;
    self.mapView = mapView;
    self.tileOverlayIdToController = [[NSMutableDictionary alloc] init];
    self.registrar = registrar;
  }
  return self;
}

- (void)addTileOverlays:(NSArray*)tileOverlaysToAdd {
  for (NSDictionary* tileOverlay in tileOverlaysToAdd) {
    NSString* tileOverlayId = [FLTTileOverlaysController getTileOverlayId:tileOverlay];
    FLTTileProviderController* tileProvider =
        [[FLTTileProviderController alloc] init:self.methodChannel tileOverlayId:tileOverlayId];
    FLTGoogleMapTileOverlayController* controller =
        [[FLTGoogleMapTileOverlayController alloc] initWithTileLayer:tileProvider
                                                             mapView:self.mapView];
    InterpretTileOverlayOptions(tileOverlay, controller, self.registrar);
    self.tileOverlayIdToController[tileOverlayId] = controller;
  }
}

- (void)changeTileOverlays:(NSArray*)tileOverlaysToChange {
  for (NSDictionary* tileOverlay in tileOverlaysToChange) {
    NSString* tileOverlayId = [FLTTileOverlaysController getTileOverlayId:tileOverlay];
    FLTGoogleMapTileOverlayController* controller = self.tileOverlayIdToController[tileOverlayId];
    if (!controller) {
      continue;
    }
    InterpretTileOverlayOptions(tileOverlay, controller, self.registrar);
  }
}
- (void)removeTileOverlayIds:(NSArray*)tileOverlayIdsToRemove {
  for (NSString* tileOverlayId in tileOverlayIdsToRemove) {
    FLTGoogleMapTileOverlayController* controller = self.tileOverlayIdToController[tileOverlayId];
    if (!controller) {
      continue;
    }
    [controller removeTileOverlay];
    [self.tileOverlayIdToController removeObjectForKey:tileOverlayId];
  }
}

- (void)clearTileCache:(NSString*)tileOverlayId {
  FLTGoogleMapTileOverlayController* controller = self.tileOverlayIdToController[tileOverlayId];
  if (!controller) {
    return;
  }
  [controller clearTileCache];
}

- (nullable NSDictionary*)getTileOverlayInfo:(NSString*)tileverlayId {
  if (self.tileOverlayIdToController[tileverlayId] == nil) {
    return nil;
  }
  return [self.tileOverlayIdToController[tileverlayId] getTileOverlayInfo];
}

+ (NSString*)getTileOverlayId:(NSDictionary*)tileOverlay {
  return tileOverlay[@"tileOverlayId"];
}

@end
