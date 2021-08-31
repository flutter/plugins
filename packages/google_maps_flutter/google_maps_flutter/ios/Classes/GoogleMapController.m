// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapController.h"
#import "FLTGoogleMapTileOverlayController.h"
#import "JsonConversions.h"

#pragma mark - Conversion of JSON-like values sent via platform channels. Forward declarations.

static NSDictionary* PositionToJson(GMSCameraPosition* position);
static NSDictionary* PointToJson(CGPoint point);
static NSArray* LocationToJson(CLLocationCoordinate2D position);
static CGPoint ToCGPoint(NSDictionary* json);
static GMSCameraPosition* ToOptionalCameraPosition(NSDictionary* json);
static GMSCoordinateBounds* ToOptionalBounds(NSArray* json);
static GMSCameraUpdate* ToCameraUpdate(NSArray* data);
static NSDictionary* GMSCoordinateBoundsToJson(GMSCoordinateBounds* bounds);
static void InterpretMapOptions(NSDictionary* data, id<FLTGoogleMapOptionsSink> sink);
static double ToDouble(NSNumber* data) { return [FLTGoogleMapJsonConversions toDouble:data]; }

@implementation FLTGoogleMapFactory {
  NSObject<FlutterPluginRegistrar>* _registrar;
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  self = [super init];
  if (self) {
    _registrar = registrar;
  }
  return self;
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec {
  return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                   viewIdentifier:(int64_t)viewId
                                        arguments:(id _Nullable)args {
  return [[FLTGoogleMapController alloc] initWithFrame:frame
                                        viewIdentifier:viewId
                                             arguments:args
                                             registrar:_registrar];
}
@end

@implementation FLTGoogleMapController {
  GMSMapView* _mapView;
  int64_t _viewId;
  FlutterMethodChannel* _channel;
  BOOL _trackCameraPosition;
  NSObject<FlutterPluginRegistrar>* _registrar;
  BOOL _cameraDidInitialSetup;
  FLTMarkersController* _markersController;
  FLTPolygonsController* _polygonsController;
  FLTPolylinesController* _polylinesController;
  FLTCirclesController* _circlesController;
  FLTTileOverlaysController* _tileOverlaysController;
}

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
                    registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  if (self = [super init]) {
    _viewId = viewId;

    GMSCameraPosition* camera = ToOptionalCameraPosition(args[@"initialCameraPosition"]);
    _mapView = [GMSMapView mapWithFrame:frame camera:camera];
    _mapView.accessibilityElementsHidden = NO;
    _trackCameraPosition = NO;
    InterpretMapOptions(args[@"options"], self);
    NSString* channelName =
        [NSString stringWithFormat:@"plugins.flutter.io/google_maps_%lld", viewId];
    _channel = [FlutterMethodChannel methodChannelWithName:channelName
                                           binaryMessenger:registrar.messenger];
    __weak __typeof__(self) weakSelf = self;
    [_channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
      if (weakSelf) {
        [weakSelf onMethodCall:call result:result];
      }
    }];
    _mapView.delegate = weakSelf;
    _registrar = registrar;
    _cameraDidInitialSetup = NO;
    _markersController = [[FLTMarkersController alloc] init:_channel
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
  }
  return self;
}

- (UIView*)view {
  [_mapView addObserver:self forKeyPath:@"frame" options:0 context:nil];
  return _mapView;
}

- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context {
  if (_cameraDidInitialSetup) {
    // We only observe the frame for initial setup.
    [_mapView removeObserver:self forKeyPath:@"frame"];
    return;
  }
  if (object == _mapView && [keyPath isEqualToString:@"frame"]) {
    CGRect bounds = _mapView.bounds;
    if (CGRectEqualToRect(bounds, CGRectZero)) {
      // The workaround is to fix an issue that the camera location is not current when
      // the size of the map is zero at initialization.
      // So We only care about the size of the `_mapView`, ignore the frame changes when the size is
      // zero.
      return;
    }
    _cameraDidInitialSetup = YES;
    [_mapView removeObserver:self forKeyPath:@"frame"];
    [_mapView moveCamera:[GMSCameraUpdate setCamera:_mapView.camera]];
  } else {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([call.method isEqualToString:@"map#show"]) {
    [self showAtX:ToDouble(call.arguments[@"x"]) Y:ToDouble(call.arguments[@"y"])];
    result(nil);
  } else if ([call.method isEqualToString:@"map#hide"]) {
    [self hide];
    result(nil);
  } else if ([call.method isEqualToString:@"camera#animate"]) {
    [self animateWithCameraUpdate:ToCameraUpdate(call.arguments[@"cameraUpdate"])];
    result(nil);
  } else if ([call.method isEqualToString:@"camera#move"]) {
    [self moveWithCameraUpdate:ToCameraUpdate(call.arguments[@"cameraUpdate"])];
    result(nil);
  } else if ([call.method isEqualToString:@"map#update"]) {
    InterpretMapOptions(call.arguments[@"options"], self);
    result(PositionToJson([self cameraPosition]));
  } else if ([call.method isEqualToString:@"map#getVisibleRegion"]) {
    if (_mapView != nil) {
      GMSVisibleRegion visibleRegion = _mapView.projection.visibleRegion;
      GMSCoordinateBounds* bounds = [[GMSCoordinateBounds alloc] initWithRegion:visibleRegion];

      result(GMSCoordinateBoundsToJson(bounds));
    } else {
      result([FlutterError errorWithCode:@"GoogleMap uninitialized"
                                 message:@"getVisibleRegion called prior to map initialization"
                                 details:nil]);
    }
  } else if ([call.method isEqualToString:@"map#getScreenCoordinate"]) {
    if (_mapView != nil) {
      CLLocationCoordinate2D location = [FLTGoogleMapJsonConversions toLocation:call.arguments];
      CGPoint point = [_mapView.projection pointForCoordinate:location];
      result(PointToJson(point));
    } else {
      result([FlutterError errorWithCode:@"GoogleMap uninitialized"
                                 message:@"getScreenCoordinate called prior to map initialization"
                                 details:nil]);
    }
  } else if ([call.method isEqualToString:@"map#getLatLng"]) {
    if (_mapView != nil && call.arguments) {
      CGPoint point = ToCGPoint(call.arguments);
      CLLocationCoordinate2D latlng = [_mapView.projection coordinateForPoint:point];
      result(LocationToJson(latlng));
    } else {
      result([FlutterError errorWithCode:@"GoogleMap uninitialized"
                                 message:@"getLatLng called prior to map initialization"
                                 details:nil]);
    }
  } else if ([call.method isEqualToString:@"map#waitForMap"]) {
    result(nil);
  } else if ([call.method isEqualToString:@"map#takeSnapshot"]) {
    if (@available(iOS 10.0, *)) {
      if (_mapView != nil) {
        UIGraphicsImageRendererFormat* format = [UIGraphicsImageRendererFormat defaultFormat];
        format.scale = [[UIScreen mainScreen] scale];
        UIGraphicsImageRenderer* renderer =
            [[UIGraphicsImageRenderer alloc] initWithSize:_mapView.frame.size format:format];

        UIImage* image = [renderer imageWithActions:^(UIGraphicsImageRendererContext* context) {
          [_mapView.layer renderInContext:context.CGContext];
        }];
        result([FlutterStandardTypedData typedDataWithBytes:UIImagePNGRepresentation(image)]);
      } else {
        result([FlutterError errorWithCode:@"GoogleMap uninitialized"
                                   message:@"takeSnapshot called prior to map initialization"
                                   details:nil]);
      }
    } else {
      NSLog(@"Taking snapshots is not supported for Flutter Google Maps prior to iOS 10.");
      result(nil);
    }
  } else if ([call.method isEqualToString:@"markers#update"]) {
    id markersToAdd = call.arguments[@"markersToAdd"];
    if ([markersToAdd isKindOfClass:[NSArray class]]) {
      [_markersController addMarkers:markersToAdd];
    }
    id markersToChange = call.arguments[@"markersToChange"];
    if ([markersToChange isKindOfClass:[NSArray class]]) {
      [_markersController changeMarkers:markersToChange];
    }
    id markerIdsToRemove = call.arguments[@"markerIdsToRemove"];
    if ([markerIdsToRemove isKindOfClass:[NSArray class]]) {
      [_markersController removeMarkerIds:markerIdsToRemove];
    }
    result(nil);
  } else if ([call.method isEqualToString:@"markers#showInfoWindow"]) {
    id markerId = call.arguments[@"markerId"];
    if ([markerId isKindOfClass:[NSString class]]) {
      [_markersController showMarkerInfoWindow:markerId result:result];
    } else {
      result([FlutterError errorWithCode:@"Invalid markerId"
                                 message:@"showInfoWindow called with invalid markerId"
                                 details:nil]);
    }
  } else if ([call.method isEqualToString:@"markers#hideInfoWindow"]) {
    id markerId = call.arguments[@"markerId"];
    if ([markerId isKindOfClass:[NSString class]]) {
      [_markersController hideMarkerInfoWindow:markerId result:result];
    } else {
      result([FlutterError errorWithCode:@"Invalid markerId"
                                 message:@"hideInfoWindow called with invalid markerId"
                                 details:nil]);
    }
  } else if ([call.method isEqualToString:@"markers#isInfoWindowShown"]) {
    id markerId = call.arguments[@"markerId"];
    if ([markerId isKindOfClass:[NSString class]]) {
      [_markersController isMarkerInfoWindowShown:markerId result:result];
    } else {
      result([FlutterError errorWithCode:@"Invalid markerId"
                                 message:@"isInfoWindowShown called with invalid markerId"
                                 details:nil]);
    }
  } else if ([call.method isEqualToString:@"polygons#update"]) {
    id polygonsToAdd = call.arguments[@"polygonsToAdd"];
    if ([polygonsToAdd isKindOfClass:[NSArray class]]) {
      [_polygonsController addPolygons:polygonsToAdd];
    }
    id polygonsToChange = call.arguments[@"polygonsToChange"];
    if ([polygonsToChange isKindOfClass:[NSArray class]]) {
      [_polygonsController changePolygons:polygonsToChange];
    }
    id polygonIdsToRemove = call.arguments[@"polygonIdsToRemove"];
    if ([polygonIdsToRemove isKindOfClass:[NSArray class]]) {
      [_polygonsController removePolygonIds:polygonIdsToRemove];
    }
    result(nil);
  } else if ([call.method isEqualToString:@"polylines#update"]) {
    id polylinesToAdd = call.arguments[@"polylinesToAdd"];
    if ([polylinesToAdd isKindOfClass:[NSArray class]]) {
      [_polylinesController addPolylines:polylinesToAdd];
    }
    id polylinesToChange = call.arguments[@"polylinesToChange"];
    if ([polylinesToChange isKindOfClass:[NSArray class]]) {
      [_polylinesController changePolylines:polylinesToChange];
    }
    id polylineIdsToRemove = call.arguments[@"polylineIdsToRemove"];
    if ([polylineIdsToRemove isKindOfClass:[NSArray class]]) {
      [_polylinesController removePolylineIds:polylineIdsToRemove];
    }
    result(nil);
  } else if ([call.method isEqualToString:@"circles#update"]) {
    id circlesToAdd = call.arguments[@"circlesToAdd"];
    if ([circlesToAdd isKindOfClass:[NSArray class]]) {
      [_circlesController addCircles:circlesToAdd];
    }
    id circlesToChange = call.arguments[@"circlesToChange"];
    if ([circlesToChange isKindOfClass:[NSArray class]]) {
      [_circlesController changeCircles:circlesToChange];
    }
    id circleIdsToRemove = call.arguments[@"circleIdsToRemove"];
    if ([circleIdsToRemove isKindOfClass:[NSArray class]]) {
      [_circlesController removeCircleIds:circleIdsToRemove];
    }
    result(nil);
  } else if ([call.method isEqualToString:@"tileOverlays#update"]) {
    id tileOverlaysToAdd = call.arguments[@"tileOverlaysToAdd"];
    if ([tileOverlaysToAdd isKindOfClass:[NSArray class]]) {
      [_tileOverlaysController addTileOverlays:tileOverlaysToAdd];
    }
    id tileOverlaysToChange = call.arguments[@"tileOverlaysToChange"];
    if ([tileOverlaysToChange isKindOfClass:[NSArray class]]) {
      [_tileOverlaysController changeTileOverlays:tileOverlaysToChange];
    }
    id tileOverlayIdsToRemove = call.arguments[@"tileOverlayIdsToRemove"];
    if ([tileOverlayIdsToRemove isKindOfClass:[NSArray class]]) {
      [_tileOverlaysController removeTileOverlayIds:tileOverlayIdsToRemove];
    }
    result(nil);
  } else if ([call.method isEqualToString:@"tileOverlays#clearTileCache"]) {
    id rawTileOverlayId = call.arguments[@"tileOverlayId"];
    [_tileOverlaysController clearTileCache:rawTileOverlayId];
    result(nil);
  } else if ([call.method isEqualToString:@"map#isCompassEnabled"]) {
    NSNumber* isCompassEnabled = @(_mapView.settings.compassButton);
    result(isCompassEnabled);
  } else if ([call.method isEqualToString:@"map#isMapToolbarEnabled"]) {
    NSNumber* isMapToolbarEnabled = @NO;
    result(isMapToolbarEnabled);
  } else if ([call.method isEqualToString:@"map#getMinMaxZoomLevels"]) {
    NSArray* zoomLevels = @[ @(_mapView.minZoom), @(_mapView.maxZoom) ];
    result(zoomLevels);
  } else if ([call.method isEqualToString:@"map#getZoomLevel"]) {
    result(@(_mapView.camera.zoom));
  } else if ([call.method isEqualToString:@"map#isZoomGesturesEnabled"]) {
    NSNumber* isZoomGesturesEnabled = @(_mapView.settings.zoomGestures);
    result(isZoomGesturesEnabled);
  } else if ([call.method isEqualToString:@"map#isZoomControlsEnabled"]) {
    NSNumber* isZoomControlsEnabled = @NO;
    result(isZoomControlsEnabled);
  } else if ([call.method isEqualToString:@"map#isTiltGesturesEnabled"]) {
    NSNumber* isTiltGesturesEnabled = @(_mapView.settings.tiltGestures);
    result(isTiltGesturesEnabled);
  } else if ([call.method isEqualToString:@"map#isRotateGesturesEnabled"]) {
    NSNumber* isRotateGesturesEnabled = @(_mapView.settings.rotateGestures);
    result(isRotateGesturesEnabled);
  } else if ([call.method isEqualToString:@"map#isScrollGesturesEnabled"]) {
    NSNumber* isScrollGesturesEnabled = @(_mapView.settings.scrollGestures);
    result(isScrollGesturesEnabled);
  } else if ([call.method isEqualToString:@"map#isMyLocationButtonEnabled"]) {
    NSNumber* isMyLocationButtonEnabled = @(_mapView.settings.myLocationButton);
    result(isMyLocationButtonEnabled);
  } else if ([call.method isEqualToString:@"map#isTrafficEnabled"]) {
    NSNumber* isTrafficEnabled = @(_mapView.trafficEnabled);
    result(isTrafficEnabled);
  } else if ([call.method isEqualToString:@"map#isBuildingsEnabled"]) {
    NSNumber* isBuildingsEnabled = @(_mapView.buildingsEnabled);
    result(isBuildingsEnabled);
  } else if ([call.method isEqualToString:@"map#setStyle"]) {
    NSString* mapStyle = [call arguments];
    NSString* error = [self setMapStyle:mapStyle];
    if (error == nil) {
      result(@[ @(YES) ]);
    } else {
      result(@[ @(NO), error ]);
    }
  } else if ([call.method isEqualToString:@"map#getTileOverlayInfo"]) {
    NSString* rawTileOverlayId = call.arguments[@"tileOverlayId"];
    result([_tileOverlaysController getTileOverlayInfo:rawTileOverlayId]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)showAtX:(CGFloat)x Y:(CGFloat)y {
  _mapView.frame =
      CGRectMake(x, y, CGRectGetWidth(_mapView.frame), CGRectGetHeight(_mapView.frame));
  _mapView.hidden = NO;
}

- (void)hide {
  _mapView.hidden = YES;
}

- (void)animateWithCameraUpdate:(GMSCameraUpdate*)cameraUpdate {
  [_mapView animateWithCameraUpdate:cameraUpdate];
}

- (void)moveWithCameraUpdate:(GMSCameraUpdate*)cameraUpdate {
  [_mapView moveCamera:cameraUpdate];
}

- (GMSCameraPosition*)cameraPosition {
  if (_trackCameraPosition) {
    return _mapView.camera;
  } else {
    return nil;
  }
}

#pragma mark - FLTGoogleMapOptionsSink methods

- (void)setCamera:(GMSCameraPosition*)camera {
  _mapView.camera = camera;
}

- (void)setCameraTargetBounds:(GMSCoordinateBounds*)bounds {
  _mapView.cameraTargetBounds = bounds;
}

- (void)setCompassEnabled:(BOOL)enabled {
  _mapView.settings.compassButton = enabled;
}

- (void)setIndoorEnabled:(BOOL)enabled {
  _mapView.indoorEnabled = enabled;
}

- (void)setTrafficEnabled:(BOOL)enabled {
  _mapView.trafficEnabled = enabled;
}

- (void)setBuildingsEnabled:(BOOL)enabled {
  _mapView.buildingsEnabled = enabled;
}

- (void)setMapType:(GMSMapViewType)mapType {
  _mapView.mapType = mapType;
}

- (void)setMinZoom:(float)minZoom maxZoom:(float)maxZoom {
  [_mapView setMinZoom:minZoom maxZoom:maxZoom];
}

- (void)setPaddingTop:(float)top left:(float)left bottom:(float)bottom right:(float)right {
  _mapView.padding = UIEdgeInsetsMake(top, left, bottom, right);
}

- (void)setRotateGesturesEnabled:(BOOL)enabled {
  _mapView.settings.rotateGestures = enabled;
}

- (void)setScrollGesturesEnabled:(BOOL)enabled {
  _mapView.settings.scrollGestures = enabled;
}

- (void)setTiltGesturesEnabled:(BOOL)enabled {
  _mapView.settings.tiltGestures = enabled;
}

- (void)setTrackCameraPosition:(BOOL)enabled {
  _trackCameraPosition = enabled;
}

- (void)setZoomGesturesEnabled:(BOOL)enabled {
  _mapView.settings.zoomGestures = enabled;
}

- (void)setMyLocationEnabled:(BOOL)enabled {
  _mapView.myLocationEnabled = enabled;
}

- (void)setMyLocationButtonEnabled:(BOOL)enabled {
  _mapView.settings.myLocationButton = enabled;
}

- (NSString*)setMapStyle:(NSString*)mapStyle {
  if (mapStyle == (id)[NSNull null] || mapStyle.length == 0) {
    _mapView.mapStyle = nil;
    return nil;
  }
  NSError* error;
  GMSMapStyle* style = [GMSMapStyle styleWithJSONString:mapStyle error:&error];
  if (!style) {
    return [error localizedDescription];
  } else {
    _mapView.mapStyle = style;
    return nil;
  }
}

#pragma mark - GMSMapViewDelegate methods

- (void)mapView:(GMSMapView*)mapView willMove:(BOOL)gesture {
  [_channel invokeMethod:@"camera#onMoveStarted" arguments:@{@"isGesture" : @(gesture)}];
}

- (void)mapView:(GMSMapView*)mapView didChangeCameraPosition:(GMSCameraPosition*)position {
  if (_trackCameraPosition) {
    [_channel invokeMethod:@"camera#onMove" arguments:@{@"position" : PositionToJson(position)}];
  }
}

- (void)mapView:(GMSMapView*)mapView idleAtCameraPosition:(GMSCameraPosition*)position {
  [_channel invokeMethod:@"camera#onIdle" arguments:@{}];
}

- (BOOL)mapView:(GMSMapView*)mapView didTapMarker:(GMSMarker*)marker {
  NSString* markerId = marker.userData[0];
  return [_markersController onMarkerTap:markerId];
}

- (void)mapView:(GMSMapView*)mapView didEndDraggingMarker:(GMSMarker*)marker {
  NSString* markerId = marker.userData[0];
  [_markersController onMarkerDragEnd:markerId coordinate:marker.position];
}

- (void)mapView:(GMSMapView*)mapView didTapInfoWindowOfMarker:(GMSMarker*)marker {
  NSString* markerId = marker.userData[0];
  [_markersController onInfoWindowTap:markerId];
}
- (void)mapView:(GMSMapView*)mapView didTapOverlay:(GMSOverlay*)overlay {
  NSString* overlayId = overlay.userData[0];
  if ([_polylinesController hasPolylineWithId:overlayId]) {
    [_polylinesController onPolylineTap:overlayId];
  } else if ([_polygonsController hasPolygonWithId:overlayId]) {
    [_polygonsController onPolygonTap:overlayId];
  } else if ([_circlesController hasCircleWithId:overlayId]) {
    [_circlesController onCircleTap:overlayId];
  }
}

- (void)mapView:(GMSMapView*)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
  [_channel invokeMethod:@"map#onTap" arguments:@{@"position" : LocationToJson(coordinate)}];
}

- (void)mapView:(GMSMapView*)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
  [_channel invokeMethod:@"map#onLongPress" arguments:@{@"position" : LocationToJson(coordinate)}];
}

@end

#pragma mark - Implementations of JSON conversion functions.

static NSArray* LocationToJson(CLLocationCoordinate2D position) {
  return @[ @(position.latitude), @(position.longitude) ];
}

static NSDictionary* PositionToJson(GMSCameraPosition* position) {
  if (!position) {
    return nil;
  }
  return @{
    @"target" : LocationToJson([position target]),
    @"zoom" : @([position zoom]),
    @"bearing" : @([position bearing]),
    @"tilt" : @([position viewingAngle]),
  };
}

static NSDictionary* PointToJson(CGPoint point) {
  return @{
    @"x" : @(lroundf(point.x)),
    @"y" : @(lroundf(point.y)),
  };
}

static NSDictionary* GMSCoordinateBoundsToJson(GMSCoordinateBounds* bounds) {
  if (!bounds) {
    return nil;
  }
  return @{
    @"southwest" : LocationToJson([bounds southWest]),
    @"northeast" : LocationToJson([bounds northEast]),
  };
}

static float ToFloat(NSNumber* data) { return [FLTGoogleMapJsonConversions toFloat:data]; }

static CLLocationCoordinate2D ToLocation(NSArray* data) {
  return [FLTGoogleMapJsonConversions toLocation:data];
}

static int ToInt(NSNumber* data) { return [FLTGoogleMapJsonConversions toInt:data]; }

static BOOL ToBool(NSNumber* data) { return [FLTGoogleMapJsonConversions toBool:data]; }

static CGPoint ToPoint(NSArray* data) { return [FLTGoogleMapJsonConversions toPoint:data]; }

static GMSCameraPosition* ToCameraPosition(NSDictionary* data) {
  return [GMSCameraPosition cameraWithTarget:ToLocation(data[@"target"])
                                        zoom:ToFloat(data[@"zoom"])
                                     bearing:ToDouble(data[@"bearing"])
                                viewingAngle:ToDouble(data[@"tilt"])];
}

static GMSCameraPosition* ToOptionalCameraPosition(NSDictionary* json) {
  return json ? ToCameraPosition(json) : nil;
}

static CGPoint ToCGPoint(NSDictionary* json) {
  double x = ToDouble(json[@"x"]);
  double y = ToDouble(json[@"y"]);
  return CGPointMake(x, y);
}

static GMSCoordinateBounds* ToBounds(NSArray* data) {
  return [[GMSCoordinateBounds alloc] initWithCoordinate:ToLocation(data[0])
                                              coordinate:ToLocation(data[1])];
}

static GMSCoordinateBounds* ToOptionalBounds(NSArray* data) {
  return (data[0] == [NSNull null]) ? nil : ToBounds(data[0]);
}

static GMSMapViewType ToMapViewType(NSNumber* json) {
  int value = ToInt(json);
  return (GMSMapViewType)(value == 0 ? 5 : value);
}

static GMSCameraUpdate* ToCameraUpdate(NSArray* data) {
  NSString* update = data[0];
  if ([update isEqualToString:@"newCameraPosition"]) {
    return [GMSCameraUpdate setCamera:ToCameraPosition(data[1])];
  } else if ([update isEqualToString:@"newLatLng"]) {
    return [GMSCameraUpdate setTarget:ToLocation(data[1])];
  } else if ([update isEqualToString:@"newLatLngBounds"]) {
    return [GMSCameraUpdate fitBounds:ToBounds(data[1]) withPadding:ToDouble(data[2])];
  } else if ([update isEqualToString:@"newLatLngZoom"]) {
    return [GMSCameraUpdate setTarget:ToLocation(data[1]) zoom:ToFloat(data[2])];
  } else if ([update isEqualToString:@"scrollBy"]) {
    return [GMSCameraUpdate scrollByX:ToDouble(data[1]) Y:ToDouble(data[2])];
  } else if ([update isEqualToString:@"zoomBy"]) {
    if (data.count == 2) {
      return [GMSCameraUpdate zoomBy:ToFloat(data[1])];
    } else {
      return [GMSCameraUpdate zoomBy:ToFloat(data[1]) atPoint:ToPoint(data[2])];
    }
  } else if ([update isEqualToString:@"zoomIn"]) {
    return [GMSCameraUpdate zoomIn];
  } else if ([update isEqualToString:@"zoomOut"]) {
    return [GMSCameraUpdate zoomOut];
  } else if ([update isEqualToString:@"zoomTo"]) {
    return [GMSCameraUpdate zoomTo:ToFloat(data[1])];
  }
  return nil;
}

static void InterpretMapOptions(NSDictionary* data, id<FLTGoogleMapOptionsSink> sink) {
  NSArray* cameraTargetBounds = data[@"cameraTargetBounds"];
  if (cameraTargetBounds) {
    [sink setCameraTargetBounds:ToOptionalBounds(cameraTargetBounds)];
  }
  NSNumber* compassEnabled = data[@"compassEnabled"];
  if (compassEnabled != nil) {
    [sink setCompassEnabled:ToBool(compassEnabled)];
  }
  id indoorEnabled = data[@"indoorEnabled"];
  if (indoorEnabled) {
    [sink setIndoorEnabled:ToBool(indoorEnabled)];
  }
  id trafficEnabled = data[@"trafficEnabled"];
  if (trafficEnabled) {
    [sink setTrafficEnabled:ToBool(trafficEnabled)];
  }
  id buildingsEnabled = data[@"buildingsEnabled"];
  if (buildingsEnabled) {
    [sink setBuildingsEnabled:ToBool(buildingsEnabled)];
  }
  id mapType = data[@"mapType"];
  if (mapType) {
    [sink setMapType:ToMapViewType(mapType)];
  }
  NSArray* zoomData = data[@"minMaxZoomPreference"];
  if (zoomData) {
    float minZoom = (zoomData[0] == [NSNull null]) ? kGMSMinZoomLevel : ToFloat(zoomData[0]);
    float maxZoom = (zoomData[1] == [NSNull null]) ? kGMSMaxZoomLevel : ToFloat(zoomData[1]);
    [sink setMinZoom:minZoom maxZoom:maxZoom];
  }
  NSArray* paddingData = data[@"padding"];
  if (paddingData) {
    float top = (paddingData[0] == [NSNull null]) ? 0 : ToFloat(paddingData[0]);
    float left = (paddingData[1] == [NSNull null]) ? 0 : ToFloat(paddingData[1]);
    float bottom = (paddingData[2] == [NSNull null]) ? 0 : ToFloat(paddingData[2]);
    float right = (paddingData[3] == [NSNull null]) ? 0 : ToFloat(paddingData[3]);
    [sink setPaddingTop:top left:left bottom:bottom right:right];
  }

  NSNumber* rotateGesturesEnabled = data[@"rotateGesturesEnabled"];
  if (rotateGesturesEnabled != nil) {
    [sink setRotateGesturesEnabled:ToBool(rotateGesturesEnabled)];
  }
  NSNumber* scrollGesturesEnabled = data[@"scrollGesturesEnabled"];
  if (scrollGesturesEnabled != nil) {
    [sink setScrollGesturesEnabled:ToBool(scrollGesturesEnabled)];
  }
  NSNumber* tiltGesturesEnabled = data[@"tiltGesturesEnabled"];
  if (tiltGesturesEnabled != nil) {
    [sink setTiltGesturesEnabled:ToBool(tiltGesturesEnabled)];
  }
  NSNumber* trackCameraPosition = data[@"trackCameraPosition"];
  if (trackCameraPosition != nil) {
    [sink setTrackCameraPosition:ToBool(trackCameraPosition)];
  }
  NSNumber* zoomGesturesEnabled = data[@"zoomGesturesEnabled"];
  if (zoomGesturesEnabled != nil) {
    [sink setZoomGesturesEnabled:ToBool(zoomGesturesEnabled)];
  }
  NSNumber* myLocationEnabled = data[@"myLocationEnabled"];
  if (myLocationEnabled != nil) {
    [sink setMyLocationEnabled:ToBool(myLocationEnabled)];
  }
  NSNumber* myLocationButtonEnabled = data[@"myLocationButtonEnabled"];
  if (myLocationButtonEnabled != nil) {
    [sink setMyLocationButtonEnabled:ToBool(myLocationButtonEnabled)];
  }
}
