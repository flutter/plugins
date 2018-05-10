// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapsPlugin.h"
#import "GoogleMapController.h"
#import "GoogleMapMarkerController.h"

#pragma mark - Conversion of JSON-like values sent via platform channels. Forward declarations.

static id positionToJson(GMSCameraPosition* position);
static double toDouble(id json);
static CLLocationCoordinate2D toLocation(id json);
static GMSCameraPosition* toOptionalCameraPosition(id json);
static GMSCoordinateBounds* toOptionalBounds(id json);
static GMSCameraUpdate* toCameraUpdate(id json);
static void interpretMapOptions(id json, id<FLTGoogleMapOptionsSink> sink);
static void interpretMarkerOptions(id json, id<FLTGoogleMapMarkerOptionsSink> sink,
                                   NSObject<FlutterPluginRegistrar>* registrar);

#pragma mark - GoogleMaps plugin implementation

@implementation FLTGoogleMapsPlugin {
  NSObject<FlutterPluginRegistrar>* _registrar;
  FlutterMethodChannel* _channel;
  NSMutableDictionary* _mapControllers;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/google_maps"
                                  binaryMessenger:[registrar messenger]];
  FLTGoogleMapsPlugin* instance =
      [[FLTGoogleMapsPlugin alloc] initWithRegistrar:registrar channel:channel];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar
                          channel:(FlutterMethodChannel*)channel {
  self = [super init];
  if (self) {
    _registrar = registrar;
    _channel = channel;
    _mapControllers = [NSMutableDictionary dictionaryWithCapacity:1];
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([call.method isEqualToString:@"init"]) {
    for (FLTGoogleMapController* controller in _mapControllers.allValues) {
      [controller removeFromView];
    }
    [_mapControllers removeAllObjects];
    result(nil);
  } else if ([call.method isEqualToString:@"map#create"]) {
    NSDictionary* options = call.arguments[@"options"];
    GMSCameraPosition* camera = toOptionalCameraPosition(options[@"cameraPosition"]);
    FLTGoogleMapController* controller =
        [FLTGoogleMapController controllerWithWidth:toDouble(call.arguments[@"width"])
                                             height:toDouble(call.arguments[@"height"])
                                             camera:camera];
    _mapControllers[controller.mapId] = controller;
    interpretMapOptions(options, controller);
    UIView* flutterView = [UIApplication sharedApplication].delegate.window.rootViewController.view;
    [controller addToView:flutterView];
    controller.delegate = self;
    result(controller.mapId);
  } else {
    FlutterError* error;
    FLTGoogleMapController* controller = [self mapFromCall:call error:&error];
    if (!controller) {
      result(error);
      return;
    }
    if ([call.method isEqualToString:@"map#show"]) {
      [controller showAtX:toDouble(call.arguments[@"x"]) Y:toDouble(call.arguments[@"y"])];
      result(nil);
    } else if ([call.method isEqualToString:@"map#hide"]) {
      [controller hide];
      result(nil);
    } else if ([call.method isEqualToString:@"camera#animate"]) {
      [controller animateWithCameraUpdate:toCameraUpdate(call.arguments[@"cameraUpdate"])];
      result(nil);
    } else if ([call.method isEqualToString:@"camera#move"]) {
      [controller moveWithCameraUpdate:toCameraUpdate(call.arguments[@"cameraUpdate"])];
      result(nil);
    } else if ([call.method isEqualToString:@"map#update"]) {
      interpretMapOptions(call.arguments[@"options"], controller);
      result(positionToJson([controller cameraPosition]));
    } else if ([call.method isEqualToString:@"marker#add"]) {
      NSDictionary* options = call.arguments[@"options"];
      NSString* markerId = [controller addMarkerWithPosition:toLocation(options[@"position"])];
      interpretMarkerOptions(options, [controller markerWithId:markerId], _registrar);
      result(markerId);
    } else if ([call.method isEqualToString:@"marker#update"]) {
      interpretMarkerOptions(call.arguments[@"options"],
                             [controller markerWithId:call.arguments[@"marker"]], _registrar);
      result(nil);
    } else if ([call.method isEqualToString:@"marker#remove"]) {
      [controller removeMarkerWithId:call.arguments[@"marker"]];
      result(nil);
    } else {
      result(FlutterMethodNotImplemented);
    }
  }
}

- (FLTGoogleMapController*)mapFromCall:(FlutterMethodCall*)call error:(FlutterError**)error {
  id mapId = call.arguments[@"map"];
  FLTGoogleMapController* controller = _mapControllers[mapId];
  if (!controller && error) {
    *error = [FlutterError errorWithCode:@"unknown_map" message:nil details:mapId];
  }
  return controller;
}

#pragma mark - FLTGoogleMapsDelegate methods, used to send platform messages to Flutter

- (void)onCameraMoveStartedOnMap:(id)mapId gesture:(BOOL)gesture {
  [_channel invokeMethod:@"camera#onMoveStarted"
               arguments:@{
                 @"map" : mapId,
                 @"isGesture" : @(gesture)
               }];
}

- (void)onCameraMoveOnMap:(id)mapId cameraPosition:(GMSCameraPosition*)cameraPosition {
  [_channel invokeMethod:@"camera#onMove"
               arguments:@{@"map" : mapId, @"position" : positionToJson(cameraPosition)}];
}

- (void)onCameraIdleOnMap:(id)mapId {
  [_channel invokeMethod:@"camera#onIdle" arguments:@{@"map" : mapId}];
}

- (void)onMarkerTappedOnMap:(id)mapId marker:(NSString*)markerId {
  [_channel invokeMethod:@"marker#onTap" arguments:@{@"map" : mapId, @"marker" : markerId}];
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

static bool toBool(id json) {
  NSNumber* data = json;
  return data.boolValue;
}

static int toInt(id json) {
  NSNumber* data = json;
  return data.intValue;
}

static double toDouble(id json) {
  NSNumber* data = json;
  return data.doubleValue;
}

static float toFloat(id json) {
  NSNumber* data = json;
  return data.floatValue;
}

static CLLocationCoordinate2D toLocation(id json) {
  NSArray* data = json;
  return CLLocationCoordinate2DMake(toDouble(data[0]), toDouble(data[1]));
}

static CGPoint toPoint(id json) {
  NSArray* data = json;
  return CGPointMake(toDouble(data[0]), toDouble(data[1]));
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
  id cameraPosition = data[@"cameraPosition"];
  if (cameraPosition) {
    [sink setCamera:toCameraPosition(cameraPosition)];
  }
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
}

static void interpretMarkerOptions(id json, id<FLTGoogleMapMarkerOptionsSink> sink,
                                   NSObject<FlutterPluginRegistrar>* registrar) {
  NSDictionary* data = json;
  id alpha = data[@"alpha"];
  if (alpha) {
    [sink setAlpha:toFloat(alpha)];
  }
  id anchor = data[@"anchor"];
  if (anchor) {
    [sink setAnchor:toPoint(anchor)];
  }
  id draggable = data[@"draggable"];
  if (draggable) {
    [sink setDraggable:toBool(draggable)];
  }
  id icon = data[@"icon"];
  if (icon) {
    NSArray* iconData = icon;
    UIImage* image;
    if ([iconData[0] isEqualToString:@"defaultMarker"]) {
      CGFloat hue = (iconData.count == 1) ? 0.0f : toDouble(iconData[1]);
      image = [GMSMarker markerImageWithColor:[UIColor colorWithHue:hue / 360.0
                                                         saturation:1.0
                                                         brightness:0.7
                                                              alpha:1.0]];
    } else if ([iconData[0] isEqualToString:@"fromAsset"]) {
      if (iconData.count == 2) {
        image = [UIImage imageNamed:[registrar lookupKeyForAsset:iconData[1]]];
      } else {
        image =
            [UIImage imageNamed:[registrar lookupKeyForAsset:iconData[1] fromPackage:iconData[2]]];
      }
    }
    [sink setIcon:image];
  }
  id flat = data[@"flat"];
  if (flat) {
    [sink setFlat:toBool(flat)];
  }
  id infoWindowAnchor = data[@"infoWindowAnchor"];
  if (infoWindowAnchor) {
    [sink setInfoWindowAnchor:toPoint(infoWindowAnchor)];
  }
  id infoWindowText = data[@"infoWindowText"];
  if (infoWindowText) {
    NSArray* infoWindowTextData = infoWindowText;
    NSString* title = (infoWindowTextData[0] == [NSNull null]) ? nil : infoWindowTextData[0];
    NSString* snippet = (infoWindowTextData[1] == [NSNull null]) ? nil : infoWindowTextData[1];
    [sink setInfoWindowTitle:title snippet:snippet];
  }
  id position = data[@"position"];
  if (position) {
    [sink setPosition:toLocation(position)];
  }
  id rotation = data[@"rotation"];
  if (rotation) {
    [sink setRotation:toDouble(rotation)];
  }
  id visible = data[@"visible"];
  if (visible) {
    [sink setVisible:toBool(visible)];
  }
  id zIndex = data[@"zIndex"];
  if (zIndex) {
    [sink setZIndex:toInt(zIndex)];
  }
}
