// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapController.h"
#import "JsonConversions.h"

#pragma mark - Conversion of JSON-like values sent via platform channels. Forward declarations.

static id positionToJson(GMSCameraPosition* position);
static GMSCameraPosition* toOptionalCameraPosition(id json);
static GMSCoordinateBounds* toOptionalBounds(id json);
static GMSCameraUpdate* toCameraUpdate(id json);
static void interpretMapOptions(id json, id<FLTGoogleMapOptionsSink> sink);

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
  // Used for the temporary workaround for a bug that the camera is not properly positioned at
  // initialization. https://github.com/flutter/flutter/issues/24806
  // TODO(cyanglaz): Remove this temporary fix once the Maps SDK issue is resolved.
  // https://github.com/flutter/flutter/issues/27550
  BOOL _cameraDidInitialSetup;
  FLTMarkersController* _markersController;
}

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
                    registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  if ([super init]) {
    _viewId = viewId;

    GMSCameraPosition* camera = toOptionalCameraPosition(args[@"initialCameraPosition"]);
    _mapView = [GMSMapView mapWithFrame:frame camera:camera];
    _trackCameraPosition = NO;
    interpretMapOptions(args[@"options"], self);
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
    _markersController = [[FLTMarkersController alloc] init:_channel mapView:_mapView];
    id markersToAdd = args[@"markersToAdd"];
    [_markersController addMarkers:markersToAdd];
  }
  return self;
}

- (UIView*)view {
  return _mapView;
}

- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([call.method isEqualToString:@"map#show"]) {
    [self showAtX:toDouble(call.arguments[@"x"]) Y:toDouble(call.arguments[@"y"])];
    result(nil);
  } else if ([call.method isEqualToString:@"map#hide"]) {
    [self hide];
    result(nil);
  } else if ([call.method isEqualToString:@"camera#animate"]) {
    [self animateWithCameraUpdate:toCameraUpdate(call.arguments[@"cameraUpdate"])];
    result(nil);
  } else if ([call.method isEqualToString:@"camera#move"]) {
    [self moveWithCameraUpdate:toCameraUpdate(call.arguments[@"cameraUpdate"])];
    result(nil);
  } else if ([call.method isEqualToString:@"map#update"]) {
    interpretMapOptions(call.arguments[@"options"], self);
    result(positionToJson([self cameraPosition]));
  } else if ([call.method isEqualToString:@"map#waitForMap"]) {
    result(nil);
  } else if ([call.method isEqualToString:@"markers#update"]) {
    id markersToAdd = call.arguments[@"markersToAdd"];
    [_markersController addMarkers:markersToAdd];
    id markersToChange = call.arguments[@"markersToChange"];
    [_markersController changeMarkers:markersToChange];
    id markerIdsToRemove = call.arguments[@"markerIdsToRemove"];
    [_markersController removeMarkerIds:markerIdsToRemove];
    result(nil);
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

- (void)setMapType:(GMSMapViewType)mapType {
  _mapView.mapType = mapType;
}

- (void)setMinZoom:(float)minZoom maxZoom:(float)maxZoom {
  [_mapView setMinZoom:minZoom maxZoom:maxZoom];
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
  _mapView.settings.myLocationButton = enabled;
}

#pragma mark - GMSMapViewDelegate methods

- (void)mapView:(GMSMapView*)mapView willMove:(BOOL)gesture {
  [_channel invokeMethod:@"camera#onMoveStarted" arguments:@{@"isGesture" : @(gesture)}];
}

- (void)mapView:(GMSMapView*)mapView didChangeCameraPosition:(GMSCameraPosition*)position {
  if (!_cameraDidInitialSetup) {
    // We suspected a bug in the iOS Google Maps SDK caused the camera is not properly positioned at
    // initialization. https://github.com/flutter/flutter/issues/24806
    // This temporary workaround fix is provided while the actual fix in the Google Maps SDK is
    // still being investigated.
    // TODO(cyanglaz): Remove this temporary fix once the Maps SDK issue is resolved.
    // https://github.com/flutter/flutter/issues/27550
    _cameraDidInitialSetup = YES;
    [mapView moveCamera:[GMSCameraUpdate setCamera:_mapView.camera]];
  }
  if (_trackCameraPosition) {
    [_channel invokeMethod:@"camera#onMove" arguments:@{@"position" : positionToJson(position)}];
  }
}

- (void)mapView:(GMSMapView*)mapView idleAtCameraPosition:(GMSCameraPosition*)position {
  [_channel invokeMethod:@"camera#onIdle" arguments:@{}];
}

- (BOOL)mapView:(GMSMapView*)mapView didTapMarker:(GMSMarker*)marker {
  NSString* markerId = marker.userData[0];
  return [_markersController onMarkerTap:markerId];
}

- (void)mapView:(GMSMapView*)mapView didTapInfoWindowOfMarker:(GMSMarker*)marker {
  NSString* markerId = marker.userData[0];
  [_markersController onInfoWindowTap:markerId];
}

@end

#pragma mark - Implementations of JSON conversion functions.

static id locationToJson(CLLocationCoordinate2D position) {
  return @[ @(position.latitude), @(position.longitude) ];
}

static id positionToJson(GMSCameraPosition* position) {
  if (!position) {
    return nil;
  }
  return @{
    @"target" : locationToJson([position target]),
    @"zoom" : @([position zoom]),
    @"bearing" : @([position bearing]),
    @"tilt" : @([position viewingAngle]),
  };
}

static GMSCameraPosition* toCameraPosition(id json) {
  NSDictionary* data = json;
  return [GMSCameraPosition cameraWithTarget:toLocation(data[@"target"])
                                        zoom:toFloat(data[@"zoom"])
                                     bearing:toDouble(data[@"bearing"])
                                viewingAngle:toDouble(data[@"tilt"])];
}

static GMSCameraPosition* toOptionalCameraPosition(id json) {
  return json ? toCameraPosition(json) : nil;
}

static GMSCoordinateBounds* toBounds(id json) {
  NSArray* data = json;
  return [[GMSCoordinateBounds alloc] initWithCoordinate:toLocation(data[0])
                                              coordinate:toLocation(data[1])];
}

static GMSCoordinateBounds* toOptionalBounds(id json) {
  NSArray* data = json;
  return (data[0] == [NSNull null]) ? nil : toBounds(data[0]);
}

static GMSMapViewType toMapViewType(id json) {
  int value = toInt(json);
  return (GMSMapViewType)(value == 0 ? 5 : value);
}

static GMSCameraUpdate* toCameraUpdate(id json) {
  NSArray* data = json;
  NSString* update = data[0];
  if ([update isEqualToString:@"newCameraPosition"]) {
    return [GMSCameraUpdate setCamera:toCameraPosition(data[1])];
  } else if ([update isEqualToString:@"newLatLng"]) {
    return [GMSCameraUpdate setTarget:toLocation(data[1])];
  } else if ([update isEqualToString:@"newLatLngBounds"]) {
    return [GMSCameraUpdate fitBounds:toBounds(data[1]) withPadding:toDouble(data[2])];
  } else if ([update isEqualToString:@"newLatLngZoom"]) {
    return [GMSCameraUpdate setTarget:toLocation(data[1]) zoom:toFloat(data[2])];
  } else if ([update isEqualToString:@"scrollBy"]) {
    return [GMSCameraUpdate scrollByX:toDouble(data[1]) Y:toDouble(data[2])];
  } else if ([update isEqualToString:@"zoomBy"]) {
    if (data.count == 2) {
      return [GMSCameraUpdate zoomBy:toFloat(data[1])];
    } else {
      return [GMSCameraUpdate zoomBy:toFloat(data[1]) atPoint:toPoint(data[2])];
    }
  } else if ([update isEqualToString:@"zoomIn"]) {
    return [GMSCameraUpdate zoomIn];
  } else if ([update isEqualToString:@"zoomOut"]) {
    return [GMSCameraUpdate zoomOut];
  } else if ([update isEqualToString:@"zoomTo"]) {
    return [GMSCameraUpdate zoomTo:toFloat(data[1])];
  }
  return nil;
}

static void interpretMapOptions(id json, id<FLTGoogleMapOptionsSink> sink) {
  NSDictionary* data = json;
  id cameraTargetBounds = data[@"cameraTargetBounds"];
  if (cameraTargetBounds) {
    [sink setCameraTargetBounds:toOptionalBounds(cameraTargetBounds)];
  }
  id compassEnabled = data[@"compassEnabled"];
  if (compassEnabled) {
    [sink setCompassEnabled:toBool(compassEnabled)];
  }
  id mapType = data[@"mapType"];
  if (mapType) {
    [sink setMapType:toMapViewType(mapType)];
  }
  id minMaxZoomPreference = data[@"minMaxZoomPreference"];
  if (minMaxZoomPreference) {
    NSArray* zoomData = minMaxZoomPreference;
    float minZoom = (zoomData[0] == [NSNull null]) ? kGMSMinZoomLevel : toFloat(zoomData[0]);
    float maxZoom = (zoomData[1] == [NSNull null]) ? kGMSMaxZoomLevel : toFloat(zoomData[1]);
    [sink setMinZoom:minZoom maxZoom:maxZoom];
  }
  id rotateGesturesEnabled = data[@"rotateGesturesEnabled"];
  if (rotateGesturesEnabled) {
    [sink setRotateGesturesEnabled:toBool(rotateGesturesEnabled)];
  }
  id scrollGesturesEnabled = data[@"scrollGesturesEnabled"];
  if (scrollGesturesEnabled) {
    [sink setScrollGesturesEnabled:toBool(scrollGesturesEnabled)];
  }
  id tiltGesturesEnabled = data[@"tiltGesturesEnabled"];
  if (tiltGesturesEnabled) {
    [sink setTiltGesturesEnabled:toBool(tiltGesturesEnabled)];
  }
  id trackCameraPosition = data[@"trackCameraPosition"];
  if (trackCameraPosition) {
    [sink setTrackCameraPosition:toBool(trackCameraPosition)];
  }
  id zoomGesturesEnabled = data[@"zoomGesturesEnabled"];
  if (zoomGesturesEnabled) {
    [sink setZoomGesturesEnabled:toBool(zoomGesturesEnabled)];
  }
  id myLocationEnabled = data[@"myLocationEnabled"];
  if (myLocationEnabled) {
    [sink setMyLocationEnabled:toBool(myLocationEnabled)];
  }
}
