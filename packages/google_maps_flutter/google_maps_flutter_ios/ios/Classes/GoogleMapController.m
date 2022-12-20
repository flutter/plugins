// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapController.h"
#import "FLTGoogleMapJSONConversions.h"
#import "FLTGoogleMapTileOverlayController.h"

#pragma mark - Conversion of JSON-like values sent via platform channels. Forward declarations.

@interface FLTGoogleMapFactory ()

@property(weak, nonatomic) NSObject<FlutterPluginRegistrar> *registrar;
@property(strong, nonatomic, readonly) id<NSObject> sharedMapServices;

@end

@implementation FLTGoogleMapFactory

@synthesize sharedMapServices = _sharedMapServices;

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _registrar = registrar;
  }
  return self;
}

- (NSObject<FlutterMessageCodec> *)createArgsCodec {
  return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame
                                    viewIdentifier:(int64_t)viewId
                                         arguments:(id _Nullable)args {
  // Precache shared map services, if needed.
  // Retain the shared map services singleton, don't use the result for anything.
  (void)[self sharedMapServices];

  return [[FLTGoogleMapController alloc] initWithFrame:frame
                                        viewIdentifier:viewId
                                             arguments:args
                                             registrar:self.registrar];
}

- (id<NSObject>)sharedMapServices {
  if (_sharedMapServices == nil) {
    // Calling this prepares GMSServices on a background thread controlled
    // by the GoogleMaps framework.
    // Retain the singleton to cache the initialization work across all map views.
    _sharedMapServices = [GMSServices sharedServices];
  }
  return _sharedMapServices;
}

@end

@interface FLTGoogleMapController ()

@property(nonatomic, strong) GMSMapView *mapView;
@property(nonatomic, strong) FlutterMethodChannel *channel;
@property(nonatomic, assign) BOOL trackCameraPosition;
@property(nonatomic, weak) NSObject<FlutterPluginRegistrar> *registrar;
@property(nonatomic, strong) FLTMarkersController *markersController;
@property(nonatomic, strong) FLTPolygonsController *polygonsController;
@property(nonatomic, strong) FLTPolylinesController *polylinesController;
@property(nonatomic, strong) FLTCirclesController *circlesController;
@property(nonatomic, strong) FLTTileOverlaysController *tileOverlaysController;

@end

@implementation FLTGoogleMapController

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
                    registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  GMSCameraPosition *camera =
      [FLTGoogleMapJSONConversions cameraPostionFromDictionary:args[@"initialCameraPosition"]];
  GMSMapView *mapView = [GMSMapView mapWithFrame:frame camera:camera];
  return [self initWithMapView:mapView viewIdentifier:viewId arguments:args registrar:registrar];
}

- (instancetype)initWithMapView:(GMSMapView *_Nonnull)mapView
                 viewIdentifier:(int64_t)viewId
                      arguments:(id _Nullable)args
                      registrar:(NSObject<FlutterPluginRegistrar> *_Nonnull)registrar {
  if (self = [super init]) {
    _mapView = mapView;

    _mapView.accessibilityElementsHidden = NO;
    // TODO(cyanglaz): avoid sending message to self in the middle of the init method.
    // https://github.com/flutter/flutter/issues/104121
    [self interpretMapOptions:args[@"options"]];
    NSString *channelName =
        [NSString stringWithFormat:@"plugins.flutter.dev/google_maps_ios_%lld", viewId];
    _channel = [FlutterMethodChannel methodChannelWithName:channelName
                                           binaryMessenger:registrar.messenger];
    __weak __typeof__(self) weakSelf = self;
    [_channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
      if (weakSelf) {
        [weakSelf onMethodCall:call result:result];
      }
    }];
    _mapView.delegate = weakSelf;
    _mapView.paddingAdjustmentBehavior = kGMSMapViewPaddingAdjustmentBehaviorNever;
    _registrar = registrar;
    _markersController = [[FLTMarkersController alloc] initWithMethodChannel:_channel
                                                                     mapView:_mapView
                                                                   registrar:registrar];
    _polygonsController = [[FLTPolygonsController alloc] init:_channel
                                                      mapView:_mapView
                                                    registrar:registrar];
    _polylinesController = [[FLTPolylinesController alloc] init:_channel
                                                        mapView:_mapView
                                                      registrar:registrar];
    _circlesController = [[FLTCirclesController alloc] init:_channel
                                                    mapView:_mapView
                                                  registrar:registrar];
    _tileOverlaysController = [[FLTTileOverlaysController alloc] init:_channel
                                                              mapView:_mapView
                                                            registrar:registrar];
    id markersToAdd = args[@"markersToAdd"];
    if ([markersToAdd isKindOfClass:[NSArray class]]) {
      [_markersController addMarkers:markersToAdd];
    }
    id polygonsToAdd = args[@"polygonsToAdd"];
    if ([polygonsToAdd isKindOfClass:[NSArray class]]) {
      [_polygonsController addPolygons:polygonsToAdd];
    }
    id polylinesToAdd = args[@"polylinesToAdd"];
    if ([polylinesToAdd isKindOfClass:[NSArray class]]) {
      [_polylinesController addPolylines:polylinesToAdd];
    }
    id circlesToAdd = args[@"circlesToAdd"];
    if ([circlesToAdd isKindOfClass:[NSArray class]]) {
      [_circlesController addCircles:circlesToAdd];
    }
    id tileOverlaysToAdd = args[@"tileOverlaysToAdd"];
    if ([tileOverlaysToAdd isKindOfClass:[NSArray class]]) {
      [_tileOverlaysController addTileOverlays:tileOverlaysToAdd];
    }

    [_mapView addObserver:self forKeyPath:@"frame" options:0 context:nil];
  }
  return self;
}

- (UIView *)view {
  return self.mapView;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if (object == self.mapView && [keyPath isEqualToString:@"frame"]) {
    CGRect bounds = self.mapView.bounds;
    if (CGRectEqualToRect(bounds, CGRectZero)) {
      // The workaround is to fix an issue that the camera location is not current when
      // the size of the map is zero at initialization.
      // So We only care about the size of the `self.mapView`, ignore the frame changes when the
      // size is zero.
      return;
    }
    // We only observe the frame for initial setup.
    [self.mapView removeObserver:self forKeyPath:@"frame"];
    [self.mapView moveCamera:[GMSCameraUpdate setCamera:self.mapView.camera]];
  } else {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

- (void)onMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([call.method isEqualToString:@"map#show"]) {
    [self showAtOrigin:CGPointMake([call.arguments[@"x"] doubleValue],
                                   [call.arguments[@"y"] doubleValue])];
    result(nil);
  } else if ([call.method isEqualToString:@"map#hide"]) {
    [self hide];
    result(nil);
  } else if ([call.method isEqualToString:@"camera#animate"]) {
    [self
        animateWithCameraUpdate:[FLTGoogleMapJSONConversions
                                    cameraUpdateFromChannelValue:call.arguments[@"cameraUpdate"]]];
    result(nil);
  } else if ([call.method isEqualToString:@"camera#move"]) {
    [self moveWithCameraUpdate:[FLTGoogleMapJSONConversions
                                   cameraUpdateFromChannelValue:call.arguments[@"cameraUpdate"]]];
    result(nil);
  } else if ([call.method isEqualToString:@"map#update"]) {
    [self interpretMapOptions:call.arguments[@"options"]];
    result([FLTGoogleMapJSONConversions dictionaryFromPosition:[self cameraPosition]]);
  } else if ([call.method isEqualToString:@"map#getVisibleRegion"]) {
    if (self.mapView != nil) {
      GMSVisibleRegion visibleRegion = self.mapView.projection.visibleRegion;
      GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithRegion:visibleRegion];
      result([FLTGoogleMapJSONConversions dictionaryFromCoordinateBounds:bounds]);
    } else {
      result([FlutterError errorWithCode:@"GoogleMap uninitialized"
                                 message:@"getVisibleRegion called prior to map initialization"
                                 details:nil]);
    }
  } else if ([call.method isEqualToString:@"map#getScreenCoordinate"]) {
    if (self.mapView != nil) {
      CLLocationCoordinate2D location =
          [FLTGoogleMapJSONConversions locationFromLatLong:call.arguments];
      CGPoint point = [self.mapView.projection pointForCoordinate:location];
      result([FLTGoogleMapJSONConversions dictionaryFromPoint:point]);
    } else {
      result([FlutterError errorWithCode:@"GoogleMap uninitialized"
                                 message:@"getScreenCoordinate called prior to map initialization"
                                 details:nil]);
    }
  } else if ([call.method isEqualToString:@"map#getLatLng"]) {
    if (self.mapView != nil && call.arguments) {
      CGPoint point = [FLTGoogleMapJSONConversions pointFromDictionary:call.arguments];
      CLLocationCoordinate2D latlng = [self.mapView.projection coordinateForPoint:point];
      result([FLTGoogleMapJSONConversions arrayFromLocation:latlng]);
    } else {
      result([FlutterError errorWithCode:@"GoogleMap uninitialized"
                                 message:@"getLatLng called prior to map initialization"
                                 details:nil]);
    }
  } else if ([call.method isEqualToString:@"map#waitForMap"]) {
    result(nil);
  } else if ([call.method isEqualToString:@"map#takeSnapshot"]) {
    if (self.mapView != nil) {
      UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
      format.scale = [[UIScreen mainScreen] scale];
      UIGraphicsImageRenderer *renderer =
          [[UIGraphicsImageRenderer alloc] initWithSize:self.mapView.frame.size format:format];

      UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [self.mapView.layer renderInContext:context.CGContext];
      }];
      result([FlutterStandardTypedData typedDataWithBytes:UIImagePNGRepresentation(image)]);
    } else {
      result([FlutterError errorWithCode:@"GoogleMap uninitialized"
                                 message:@"takeSnapshot called prior to map initialization"
                                 details:nil]);
    }
  } else if ([call.method isEqualToString:@"markers#update"]) {
    id markersToAdd = call.arguments[@"markersToAdd"];
    if ([markersToAdd isKindOfClass:[NSArray class]]) {
      [self.markersController addMarkers:markersToAdd];
    }
    id markersToChange = call.arguments[@"markersToChange"];
    if ([markersToChange isKindOfClass:[NSArray class]]) {
      [self.markersController changeMarkers:markersToChange];
    }
    id markerIdsToRemove = call.arguments[@"markerIdsToRemove"];
    if ([markerIdsToRemove isKindOfClass:[NSArray class]]) {
      [self.markersController removeMarkersWithIdentifiers:markerIdsToRemove];
    }
    result(nil);
  } else if ([call.method isEqualToString:@"markers#showInfoWindow"]) {
    id markerId = call.arguments[@"markerId"];
    if ([markerId isKindOfClass:[NSString class]]) {
      [self.markersController showMarkerInfoWindowWithIdentifier:markerId result:result];
    } else {
      result([FlutterError errorWithCode:@"Invalid markerId"
                                 message:@"showInfoWindow called with invalid markerId"
                                 details:nil]);
    }
  } else if ([call.method isEqualToString:@"markers#hideInfoWindow"]) {
    id markerId = call.arguments[@"markerId"];
    if ([markerId isKindOfClass:[NSString class]]) {
      [self.markersController hideMarkerInfoWindowWithIdentifier:markerId result:result];
    } else {
      result([FlutterError errorWithCode:@"Invalid markerId"
                                 message:@"hideInfoWindow called with invalid markerId"
                                 details:nil]);
    }
  } else if ([call.method isEqualToString:@"markers#isInfoWindowShown"]) {
    id markerId = call.arguments[@"markerId"];
    if ([markerId isKindOfClass:[NSString class]]) {
      [self.markersController isInfoWindowShownForMarkerWithIdentifier:markerId result:result];
    } else {
      result([FlutterError errorWithCode:@"Invalid markerId"
                                 message:@"isInfoWindowShown called with invalid markerId"
                                 details:nil]);
    }
  } else if ([call.method isEqualToString:@"polygons#update"]) {
    id polygonsToAdd = call.arguments[@"polygonsToAdd"];
    if ([polygonsToAdd isKindOfClass:[NSArray class]]) {
      [self.polygonsController addPolygons:polygonsToAdd];
    }
    id polygonsToChange = call.arguments[@"polygonsToChange"];
    if ([polygonsToChange isKindOfClass:[NSArray class]]) {
      [self.polygonsController changePolygons:polygonsToChange];
    }
    id polygonIdsToRemove = call.arguments[@"polygonIdsToRemove"];
    if ([polygonIdsToRemove isKindOfClass:[NSArray class]]) {
      [self.polygonsController removePolygonWithIdentifiers:polygonIdsToRemove];
    }
    result(nil);
  } else if ([call.method isEqualToString:@"polylines#update"]) {
    id polylinesToAdd = call.arguments[@"polylinesToAdd"];
    if ([polylinesToAdd isKindOfClass:[NSArray class]]) {
      [self.polylinesController addPolylines:polylinesToAdd];
    }
    id polylinesToChange = call.arguments[@"polylinesToChange"];
    if ([polylinesToChange isKindOfClass:[NSArray class]]) {
      [self.polylinesController changePolylines:polylinesToChange];
    }
    id polylineIdsToRemove = call.arguments[@"polylineIdsToRemove"];
    if ([polylineIdsToRemove isKindOfClass:[NSArray class]]) {
      [self.polylinesController removePolylineWithIdentifiers:polylineIdsToRemove];
    }
    result(nil);
  } else if ([call.method isEqualToString:@"circles#update"]) {
    id circlesToAdd = call.arguments[@"circlesToAdd"];
    if ([circlesToAdd isKindOfClass:[NSArray class]]) {
      [self.circlesController addCircles:circlesToAdd];
    }
    id circlesToChange = call.arguments[@"circlesToChange"];
    if ([circlesToChange isKindOfClass:[NSArray class]]) {
      [self.circlesController changeCircles:circlesToChange];
    }
    id circleIdsToRemove = call.arguments[@"circleIdsToRemove"];
    if ([circleIdsToRemove isKindOfClass:[NSArray class]]) {
      [self.circlesController removeCircleWithIdentifiers:circleIdsToRemove];
    }
    result(nil);
  } else if ([call.method isEqualToString:@"tileOverlays#update"]) {
    id tileOverlaysToAdd = call.arguments[@"tileOverlaysToAdd"];
    if ([tileOverlaysToAdd isKindOfClass:[NSArray class]]) {
      [self.tileOverlaysController addTileOverlays:tileOverlaysToAdd];
    }
    id tileOverlaysToChange = call.arguments[@"tileOverlaysToChange"];
    if ([tileOverlaysToChange isKindOfClass:[NSArray class]]) {
      [self.tileOverlaysController changeTileOverlays:tileOverlaysToChange];
    }
    id tileOverlayIdsToRemove = call.arguments[@"tileOverlayIdsToRemove"];
    if ([tileOverlayIdsToRemove isKindOfClass:[NSArray class]]) {
      [self.tileOverlaysController removeTileOverlayWithIdentifiers:tileOverlayIdsToRemove];
    }
    result(nil);
  } else if ([call.method isEqualToString:@"tileOverlays#clearTileCache"]) {
    id rawTileOverlayId = call.arguments[@"tileOverlayId"];
    [self.tileOverlaysController clearTileCacheWithIdentifier:rawTileOverlayId];
    result(nil);
  } else if ([call.method isEqualToString:@"map#isCompassEnabled"]) {
    NSNumber *isCompassEnabled = @(self.mapView.settings.compassButton);
    result(isCompassEnabled);
  } else if ([call.method isEqualToString:@"map#isMapToolbarEnabled"]) {
    NSNumber *isMapToolbarEnabled = @NO;
    result(isMapToolbarEnabled);
  } else if ([call.method isEqualToString:@"map#getMinMaxZoomLevels"]) {
    NSArray *zoomLevels = @[ @(self.mapView.minZoom), @(self.mapView.maxZoom) ];
    result(zoomLevels);
  } else if ([call.method isEqualToString:@"map#getZoomLevel"]) {
    result(@(self.mapView.camera.zoom));
  } else if ([call.method isEqualToString:@"map#isZoomGesturesEnabled"]) {
    NSNumber *isZoomGesturesEnabled = @(self.mapView.settings.zoomGestures);
    result(isZoomGesturesEnabled);
  } else if ([call.method isEqualToString:@"map#isZoomControlsEnabled"]) {
    NSNumber *isZoomControlsEnabled = @NO;
    result(isZoomControlsEnabled);
  } else if ([call.method isEqualToString:@"map#isTiltGesturesEnabled"]) {
    NSNumber *isTiltGesturesEnabled = @(self.mapView.settings.tiltGestures);
    result(isTiltGesturesEnabled);
  } else if ([call.method isEqualToString:@"map#isRotateGesturesEnabled"]) {
    NSNumber *isRotateGesturesEnabled = @(self.mapView.settings.rotateGestures);
    result(isRotateGesturesEnabled);
  } else if ([call.method isEqualToString:@"map#isScrollGesturesEnabled"]) {
    NSNumber *isScrollGesturesEnabled = @(self.mapView.settings.scrollGestures);
    result(isScrollGesturesEnabled);
  } else if ([call.method isEqualToString:@"map#isMyLocationButtonEnabled"]) {
    NSNumber *isMyLocationButtonEnabled = @(self.mapView.settings.myLocationButton);
    result(isMyLocationButtonEnabled);
  } else if ([call.method isEqualToString:@"map#isTrafficEnabled"]) {
    NSNumber *isTrafficEnabled = @(self.mapView.trafficEnabled);
    result(isTrafficEnabled);
  } else if ([call.method isEqualToString:@"map#isBuildingsEnabled"]) {
    NSNumber *isBuildingsEnabled = @(self.mapView.buildingsEnabled);
    result(isBuildingsEnabled);
  } else if ([call.method isEqualToString:@"map#setStyle"]) {
    NSString *mapStyle = [call arguments];
    NSString *error = [self setMapStyle:mapStyle];
    if (error == nil) {
      result(@[ @(YES) ]);
    } else {
      result(@[ @(NO), error ]);
    }
  } else if ([call.method isEqualToString:@"map#getTileOverlayInfo"]) {
    NSString *rawTileOverlayId = call.arguments[@"tileOverlayId"];
    result([self.tileOverlaysController tileOverlayInfoWithIdentifier:rawTileOverlayId]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)showAtOrigin:(CGPoint)origin {
  CGRect frame = {origin, self.mapView.frame.size};
  self.mapView.frame = frame;
  self.mapView.hidden = NO;
}

- (void)hide {
  self.mapView.hidden = YES;
}

- (void)animateWithCameraUpdate:(GMSCameraUpdate *)cameraUpdate {
  [self.mapView animateWithCameraUpdate:cameraUpdate];
}

- (void)moveWithCameraUpdate:(GMSCameraUpdate *)cameraUpdate {
  [self.mapView moveCamera:cameraUpdate];
}

- (GMSCameraPosition *)cameraPosition {
  if (self.trackCameraPosition) {
    return self.mapView.camera;
  } else {
    return nil;
  }
}

- (void)setCamera:(GMSCameraPosition *)camera {
  self.mapView.camera = camera;
}

- (void)setCameraTargetBounds:(GMSCoordinateBounds *)bounds {
  self.mapView.cameraTargetBounds = bounds;
}

- (void)setCompassEnabled:(BOOL)enabled {
  self.mapView.settings.compassButton = enabled;
}

- (void)setIndoorEnabled:(BOOL)enabled {
  self.mapView.indoorEnabled = enabled;
}

- (void)setTrafficEnabled:(BOOL)enabled {
  self.mapView.trafficEnabled = enabled;
}

- (void)setBuildingsEnabled:(BOOL)enabled {
  self.mapView.buildingsEnabled = enabled;
}

- (void)setMapType:(GMSMapViewType)mapType {
  self.mapView.mapType = mapType;
}

- (void)setMinZoom:(float)minZoom maxZoom:(float)maxZoom {
  [self.mapView setMinZoom:minZoom maxZoom:maxZoom];
}

- (void)setPaddingTop:(float)top left:(float)left bottom:(float)bottom right:(float)right {
  self.mapView.padding = UIEdgeInsetsMake(top, left, bottom, right);
}

- (void)setRotateGesturesEnabled:(BOOL)enabled {
  self.mapView.settings.rotateGestures = enabled;
}

- (void)setScrollGesturesEnabled:(BOOL)enabled {
  self.mapView.settings.scrollGestures = enabled;
}

- (void)setTiltGesturesEnabled:(BOOL)enabled {
  self.mapView.settings.tiltGestures = enabled;
}

- (void)setTrackCameraPosition:(BOOL)enabled {
  _trackCameraPosition = enabled;
}

- (void)setZoomGesturesEnabled:(BOOL)enabled {
  self.mapView.settings.zoomGestures = enabled;
}

- (void)setMyLocationEnabled:(BOOL)enabled {
  self.mapView.myLocationEnabled = enabled;
}

- (void)setMyLocationButtonEnabled:(BOOL)enabled {
  self.mapView.settings.myLocationButton = enabled;
}

- (NSString *)setMapStyle:(NSString *)mapStyle {
  if (mapStyle == (id)[NSNull null] || mapStyle.length == 0) {
    self.mapView.mapStyle = nil;
    return nil;
  }
  NSError *error;
  GMSMapStyle *style = [GMSMapStyle styleWithJSONString:mapStyle error:&error];
  if (!style) {
    return [error localizedDescription];
  } else {
    self.mapView.mapStyle = style;
    return nil;
  }
}

#pragma mark - GMSMapViewDelegate methods

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
  [self.channel invokeMethod:@"camera#onMoveStarted" arguments:@{@"isGesture" : @(gesture)}];
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
  if (self.trackCameraPosition) {
    [self.channel invokeMethod:@"camera#onMove"
                     arguments:@{
                       @"position" : [FLTGoogleMapJSONConversions dictionaryFromPosition:position]
                     }];
  }
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
  [self.channel invokeMethod:@"camera#onIdle" arguments:@{}];
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
  NSString *markerId = marker.userData[0];
  return [self.markersController didTapMarkerWithIdentifier:markerId];
}

- (void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker {
  NSString *markerId = marker.userData[0];
  [self.markersController didEndDraggingMarkerWithIdentifier:markerId location:marker.position];
}

- (void)mapView:(GMSMapView *)mapView didStartDraggingMarker:(GMSMarker *)marker {
  NSString *markerId = marker.userData[0];
  [self.markersController didStartDraggingMarkerWithIdentifier:markerId location:marker.position];
}

- (void)mapView:(GMSMapView *)mapView didDragMarker:(GMSMarker *)marker {
  NSString *markerId = marker.userData[0];
  [self.markersController didDragMarkerWithIdentifier:markerId location:marker.position];
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
  NSString *markerId = marker.userData[0];
  [self.markersController didTapInfoWindowOfMarkerWithIdentifier:markerId];
}
- (void)mapView:(GMSMapView *)mapView didTapOverlay:(GMSOverlay *)overlay {
  NSString *overlayId = overlay.userData[0];
  if ([self.polylinesController hasPolylineWithIdentifier:overlayId]) {
    [self.polylinesController didTapPolylineWithIdentifier:overlayId];
  } else if ([self.polygonsController hasPolygonWithIdentifier:overlayId]) {
    [self.polygonsController didTapPolygonWithIdentifier:overlayId];
  } else if ([self.circlesController hasCircleWithIdentifier:overlayId]) {
    [self.circlesController didTapCircleWithIdentifier:overlayId];
  }
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
  [self.channel
      invokeMethod:@"map#onTap"
         arguments:@{@"position" : [FLTGoogleMapJSONConversions arrayFromLocation:coordinate]}];
}

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
  [self.channel
      invokeMethod:@"map#onLongPress"
         arguments:@{@"position" : [FLTGoogleMapJSONConversions arrayFromLocation:coordinate]}];
}

- (void)interpretMapOptions:(NSDictionary *)data {
  NSArray *cameraTargetBounds = data[@"cameraTargetBounds"];
  if (cameraTargetBounds && cameraTargetBounds != (id)[NSNull null]) {
    [self
        setCameraTargetBounds:cameraTargetBounds.count > 0 && cameraTargetBounds[0] != [NSNull null]
                                  ? [FLTGoogleMapJSONConversions
                                        coordinateBoundsFromLatLongs:cameraTargetBounds.firstObject]
                                  : nil];
  }
  NSNumber *compassEnabled = data[@"compassEnabled"];
  if (compassEnabled && compassEnabled != (id)[NSNull null]) {
    [self setCompassEnabled:[compassEnabled boolValue]];
  }
  id indoorEnabled = data[@"indoorEnabled"];
  if (indoorEnabled && indoorEnabled != [NSNull null]) {
    [self setIndoorEnabled:[indoorEnabled boolValue]];
  }
  id trafficEnabled = data[@"trafficEnabled"];
  if (trafficEnabled && trafficEnabled != [NSNull null]) {
    [self setTrafficEnabled:[trafficEnabled boolValue]];
  }
  id buildingsEnabled = data[@"buildingsEnabled"];
  if (buildingsEnabled && buildingsEnabled != [NSNull null]) {
    [self setBuildingsEnabled:[buildingsEnabled boolValue]];
  }
  id mapType = data[@"mapType"];
  if (mapType && mapType != [NSNull null]) {
    [self setMapType:[FLTGoogleMapJSONConversions mapViewTypeFromTypeValue:mapType]];
  }
  NSArray *zoomData = data[@"minMaxZoomPreference"];
  if (zoomData && zoomData != (id)[NSNull null]) {
    float minZoom = (zoomData[0] == [NSNull null]) ? kGMSMinZoomLevel : [zoomData[0] floatValue];
    float maxZoom = (zoomData[1] == [NSNull null]) ? kGMSMaxZoomLevel : [zoomData[1] floatValue];
    [self setMinZoom:minZoom maxZoom:maxZoom];
  }
  NSArray *paddingData = data[@"padding"];
  if (paddingData) {
    float top = (paddingData[0] == [NSNull null]) ? 0 : [paddingData[0] floatValue];
    float left = (paddingData[1] == [NSNull null]) ? 0 : [paddingData[1] floatValue];
    float bottom = (paddingData[2] == [NSNull null]) ? 0 : [paddingData[2] floatValue];
    float right = (paddingData[3] == [NSNull null]) ? 0 : [paddingData[3] floatValue];
    [self setPaddingTop:top left:left bottom:bottom right:right];
  }

  NSNumber *rotateGesturesEnabled = data[@"rotateGesturesEnabled"];
  if (rotateGesturesEnabled && rotateGesturesEnabled != (id)[NSNull null]) {
    [self setRotateGesturesEnabled:[rotateGesturesEnabled boolValue]];
  }
  NSNumber *scrollGesturesEnabled = data[@"scrollGesturesEnabled"];
  if (scrollGesturesEnabled && scrollGesturesEnabled != (id)[NSNull null]) {
    [self setScrollGesturesEnabled:[scrollGesturesEnabled boolValue]];
  }
  NSNumber *tiltGesturesEnabled = data[@"tiltGesturesEnabled"];
  if (tiltGesturesEnabled && tiltGesturesEnabled != (id)[NSNull null]) {
    [self setTiltGesturesEnabled:[tiltGesturesEnabled boolValue]];
  }
  NSNumber *trackCameraPosition = data[@"trackCameraPosition"];
  if (trackCameraPosition && trackCameraPosition != (id)[NSNull null]) {
    [self setTrackCameraPosition:[trackCameraPosition boolValue]];
  }
  NSNumber *zoomGesturesEnabled = data[@"zoomGesturesEnabled"];
  if (zoomGesturesEnabled && zoomGesturesEnabled != (id)[NSNull null]) {
    [self setZoomGesturesEnabled:[zoomGesturesEnabled boolValue]];
  }
  NSNumber *myLocationEnabled = data[@"myLocationEnabled"];
  if (myLocationEnabled && myLocationEnabled != (id)[NSNull null]) {
    [self setMyLocationEnabled:[myLocationEnabled boolValue]];
  }
  NSNumber *myLocationButtonEnabled = data[@"myLocationButtonEnabled"];
  if (myLocationButtonEnabled && myLocationButtonEnabled != (id)[NSNull null]) {
    [self setMyLocationButtonEnabled:[myLocationButtonEnabled boolValue]];
  }
}

@end
