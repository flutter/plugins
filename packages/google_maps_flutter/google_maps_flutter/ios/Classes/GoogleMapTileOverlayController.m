// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapTileOverlayController.h"
#import "JsonConversions.h"

@implementation FLTGoogleMapTileOverlayController {
  GMSTileLayer* _layer;
  GMSMapView* _mapView;
}

- (instancetype)initWithTileLayer:(GMSTileLayer*)tileLayer mapView:(GMSMapView*)mapView {
  self = [super init];
  if (self) {
    _layer = tileLayer;
    _mapView = mapView;
  }
  return self;
}

- (void)removeTileOverlay {
  _layer.map = nil;
}

- (void)clearTileCache {
  [_layer clearTileCache];
}

#pragma mark - FLTGoogleMapTileOverlayOptionsSink methods

- (void)setFadeIn:(BOOL)fadeIn {
  _layer.fadeIn = fadeIn;
}

- (void)setTransparency:(float)transparency {
  float opacity = 1.0 - transparency;
  _layer.opacity = opacity;
}

- (void)setVisible:(BOOL)visible {
  _layer.map = visible ? _mapView : nil;
}

- (void)setZIndex:(int)zIndex {
  _layer.zIndex = zIndex;
}

- (void)setTileSize:(NSInteger)tileSize {
  _layer.tileSize = tileSize;
}
@end

@implementation FLTTileProviderController {
  FlutterMethodChannel* _methodChannel;
  NSString* _tileOverlayId;
}
- (instancetype)init:(FlutterMethodChannel*)methodChannel tileOverlayId:(NSString*)tileOverlayId {
  self = [super init];
  if (self) {
    _methodChannel = methodChannel;
    _tileOverlayId = tileOverlayId;
  }
  return self;
}

- (void)requestTileForX:(NSUInteger)x
                      y:(NSUInteger)y
                   zoom:(NSUInteger)zoom
               receiver:(id<GMSTileReceiver>)receiver {
  NSNumber* xn = [NSNumber numberWithUnsignedInteger:x];
  NSNumber* yn = [NSNumber numberWithUnsignedInteger:y];
  NSNumber* zoomn = [NSNumber numberWithUnsignedInteger:zoom];

  [_methodChannel
      invokeMethod:@"tileOverlay#getTile"
         arguments:@{@"tileOverlayId" : _tileOverlayId, @"x" : xn, @"y" : yn, @"zoom" : zoomn}
            result:^(id _Nullable result) {
              UIImage* tileImage;
              if ([result isKindOfClass:[NSDictionary class]]) {
                FlutterStandardTypedData* typedData = (FlutterStandardTypedData*)result[@"data"];
                tileImage = [UIImage imageWithData:typedData.data];
              } else {
                if ([result isKindOfClass:[FlutterError class]]) {
                  FlutterError* error = (FlutterError*)result;
                  NSLog(@"Can't get tile: errorCode = %@, errorMessage = %@, date = %@",
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

static BOOL ToBool(NSNumber* data) { return [FLTGoogleMapJsonConversions toBool:data]; }

static float ToFloat(NSNumber* data) { return [FLTGoogleMapJsonConversions toFloat:data]; }

static int ToInt(NSNumber* data) { return [FLTGoogleMapJsonConversions toInt:data]; }

static void InterpretTileOverlayOptions(NSDictionary* data,
                                        id<FLTGoogleMapTileOverlayOptionsSink> sink,
                                        NSObject<FlutterPluginRegistrar>* registrar) {
  NSNumber* visible = data[@"visible"];
  if (visible != nil) {
    [sink setVisible:ToBool(visible)];
  }

  NSNumber* transparency = data[@"transparency"];
  if (transparency != nil) {
    [sink setTransparency:ToFloat(transparency)];
  }

  NSNumber* zIndex = data[@"zIndex"];
  if (zIndex != nil) {
    [sink setZIndex:ToInt(zIndex)];
  }

  NSNumber* fadeIn = data[@"fadeIn"];
  if (fadeIn != nil) {
    [sink setFadeIn:ToBool(fadeIn)];
  }

  NSNumber* tileSize = data[@"tileSize"];
  if (tileSize != nil) {
    [sink setTileSize:[tileSize integerValue]];
  }
}

@implementation FLTTileOverlaysController {
  NSMutableDictionary* _tileOverlayIdToController;
  FlutterMethodChannel* _methodChannel;
  NSObject<FlutterPluginRegistrar>* _registrar;
  GMSMapView* _mapView;
}
- (instancetype)init:(FlutterMethodChannel*)methodChannel
             mapView:(GMSMapView*)mapView
           registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  self = [super init];
  if (self) {
    _methodChannel = methodChannel;
    _mapView = mapView;
    _tileOverlayIdToController = [NSMutableDictionary dictionaryWithCapacity:1];
    _registrar = registrar;
  }
  return self;
}

- (void)addTileOverlays:(NSArray*)tileOverlaysToAdd {
  for (NSDictionary* tileOverlay in tileOverlaysToAdd) {
    NSString* tileOverlayId = [FLTTileOverlaysController getTileOverlayId:tileOverlay];
    FLTTileProviderController* tileProvider =
        [[FLTTileProviderController alloc] init:_methodChannel tileOverlayId:tileOverlayId];
    FLTGoogleMapTileOverlayController* controller =
        [[FLTGoogleMapTileOverlayController alloc] initWithTileLayer:tileProvider mapView:_mapView];
    InterpretTileOverlayOptions(tileOverlay, controller, _registrar);
    _tileOverlayIdToController[tileOverlayId] = controller;
  }
}

- (void)changeTileOverlays:(NSArray*)tileOverlaysToChange {
  for (NSDictionary* tileOverlay in tileOverlaysToChange) {
    NSString* tileOverlayId = [FLTTileOverlaysController getTileOverlayId:tileOverlay];
    FLTGoogleMapTileOverlayController* controller = _tileOverlayIdToController[tileOverlayId];
    if (!controller) {
      continue;
    }
    InterpretTileOverlayOptions(tileOverlay, controller, _registrar);
  }
}
- (void)removeTileOverlayIds:(NSArray*)tileOverlayIdsToRemove {
  for (NSString* tileOverlayId in tileOverlayIdsToRemove) {
    FLTGoogleMapTileOverlayController* controller = _tileOverlayIdToController[tileOverlayId];
    if (!controller) {
      continue;
    }
    [controller removeTileOverlay];
    [_tileOverlayIdToController removeObjectForKey:tileOverlayId];
  }
}

- (void)clearTileCache:(NSString*)tileOverlayId {
  FLTGoogleMapTileOverlayController* controller = _tileOverlayIdToController[tileOverlayId];
  if (!controller) {
    return;
  }
  [controller clearTileCache];
}

+ (NSString*)getTileOverlayId:(NSDictionary*)tileOverlay {
  return tileOverlay[@"tileOverlayId"];
}
@end
