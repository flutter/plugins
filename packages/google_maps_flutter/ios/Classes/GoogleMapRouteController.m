// Copyright 2019 The HKTaxiApp Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapRouteController.h"
#import "JsonConversions.h"

static UIImage* ExtractIcon(NSObject<FlutterPluginRegistrar>* registrar, NSArray* icon);
static void InterpretInfoWindow(id<FLTGoogleMapMarkerOptionsSink> sink, NSDictionary* data);

static double ToDouble(NSNumber* data) { return [FLTGoogleMapJsonConversions toDouble:data]; }

static float ToFloat(NSNumber* data) { return [FLTGoogleMapJsonConversions toFloat:data]; }

static CLLocationCoordinate2D ToLocation(NSArray* data) {
  return [FLTGoogleMapJsonConversions toLocation:data];
}

static int ToInt(NSNumber* data) { return [FLTGoogleMapJsonConversions toInt:data]; }

static BOOL ToBool(NSNumber* data) { return [FLTGoogleMapJsonConversions toBool:data]; }

static CGPoint ToPoint(NSArray* data) { return [FLTGoogleMapJsonConversions toPoint:data]; }

static void InterpretMarkerOptions(NSDictionary* data, id<FLTGoogleMapMarkerOptionsSink> sink,
                                   NSObject<FlutterPluginRegistrar>* registrar) {
  NSNumber* alpha = data[@"alpha"];
  if (alpha) {
    [sink setAlpha:ToFloat(alpha)];
  }
  NSArray* anchor = data[@"anchor"];
  if (anchor) {
    [sink setAnchor:ToPoint(anchor)];
  }
  NSNumber* draggable = data[@"draggable"];
  if (draggable) {
    [sink setDraggable:ToBool(draggable)];
  }
  NSArray* icon = data[@"icon"];
  if (icon) {
    UIImage* image = ExtractIcon(registrar, icon);
    [sink setIcon:image];
  }
  NSNumber* flat = data[@"flat"];
  if (flat) {
    [sink setFlat:ToBool(flat)];
  }
  NSNumber* consumeTapEvents = data[@"consumeTapEvents"];
  if (consumeTapEvents) {
    [sink setConsumeTapEvents:ToBool(consumeTapEvents)];
  }
  InterpretInfoWindow(sink, data);
  NSArray* position = data[@"position"];
  if (position) {
    [sink setPosition:ToLocation(position)];
  }
  NSNumber* rotation = data[@"rotation"];
  if (rotation) {
    [sink setRotation:ToDouble(rotation)];
  }
  NSNumber* visible = data[@"visible"];
  if (visible) {
    [sink setVisible:ToBool(visible)];
  }
  NSNumber* zIndex = data[@"zIndex"];
  if (zIndex) {
    [sink setZIndex:ToInt(zIndex)];
  }
}

static void InterpretInfoWindow(id<FLTGoogleMapMarkerOptionsSink> sink, NSDictionary* data) {
  NSDictionary* infoWindow = data[@"infoWindow"];
  if (infoWindow) {
    NSString* title = infoWindow[@"title"];
    NSString* snippet = infoWindow[@"snippet"];
    if (title) {
      [sink setInfoWindowTitle:title snippet:snippet];
    }
    NSArray* infoWindowAnchor = infoWindow[@"infoWindowAnchor"];
    if (infoWindowAnchor) {
      [sink setInfoWindowAnchor:ToPoint(infoWindowAnchor)];
    }
  }
}

static UIImage* scaleImage(UIImage* image, NSNumber* scaleParam) {
  double scale = 1.0;
  if ([scaleParam isKindOfClass:[NSNumber class]]) {
    scale = scaleParam.doubleValue;
  }
  if (fabs(scale - 1) > 1e-3) {
    return [UIImage imageWithCGImage:[image CGImage]
                               scale:(image.scale * scale)
                         orientation:(image.imageOrientation)];
  }
  return image;
}

static UIImage* ExtractIcon(NSObject<FlutterPluginRegistrar>* registrar, NSArray* iconData) {
  UIImage* image;
  if ([iconData.firstObject isEqualToString:@"defaultMarker"]) {
    CGFloat hue = (iconData.count == 1) ? 0.0f : ToDouble(iconData[1]);
    image = [GMSMarker markerImageWithColor:[UIColor colorWithHue:hue / 360.0
                                                       saturation:1.0
                                                       brightness:0.7
                                                            alpha:1.0]];
  } else if ([iconData.firstObject isEqualToString:@"fromAsset"]) {
    if (iconData.count == 2) {
      image = [UIImage imageNamed:[registrar lookupKeyForAsset:iconData[1]]];
    } else {
      image = [UIImage imageNamed:[registrar lookupKeyForAsset:iconData[1]
                                                   fromPackage:iconData[2]]];
    }
  } else if ([iconData.firstObject isEqualToString:@"fromAssetImage"]) {
    if (iconData.count == 3) {
      image = [UIImage imageNamed:[registrar lookupKeyForAsset:iconData[1]]];
      NSNumber* scaleParam = iconData[2];
      image = scaleImage(image, scaleParam);
    } else {
      NSString* error =
          [NSString stringWithFormat:@"'fromAssetImage' should have exactly 3 arguments. Got: %lu",
                                     iconData.count];
      NSException* exception = [NSException exceptionWithName:@"InvalidBitmapDescriptor"
                                                       reason:error
                                                     userInfo:nil];
      @throw exception;
    }
  } else if ([iconData[0] isEqualToString:@"fromBytes"]) {
    if (iconData.count == 2) {
      @try {
        FlutterStandardTypedData* byteData = iconData[1];
        CGFloat screenScale = [[UIScreen mainScreen] scale];
        image = [UIImage imageWithData:[byteData data] scale:screenScale];
      } @catch (NSException* exception) {
        @throw [NSException exceptionWithName:@"InvalidByteDescriptor"
                                       reason:@"Unable to interpret bytes as a valid image."
                                     userInfo:nil];
      }
    } else {
      NSString* error = [NSString
          stringWithFormat:@"fromBytes should have exactly one argument, the bytes. Got: %lu",
                           iconData.count];
      NSException* exception = [NSException exceptionWithName:@"InvalidByteDescriptor"
                                                       reason:error
                                                     userInfo:nil];
      @throw exception;
    }
  }

  return image;
}

@implementation FLTGoogleMapRouteController {
  NSMutableArray<NSDictionary*>* _routes;
  FLTGoogleMapMarkerController* _markerController;
}
- (instancetype)initWithMarkerController:(FLTGoogleMapMarkerController*)markerController {
  self = [super init];
  if (self) {
    _routes = [[NSMutableArray alloc] init];
    _markerController = markerController;
  }
  return self;
}
- (void)remove {
  [_markerController removeMarker];
  [_routes removeAllObjects];
}
- (void)addMarker:(NSDictionary*)marker {
  [_routes addObject:marker];
}
- (void)clearMarkers {
  [_routes removeAllObjects];
}
- (NSMutableArray<NSDictionary*>*)getRoutes {
  return _routes;
}
- (FLTGoogleMapMarkerController*)getMarkerController {
  return _markerController;
}
@end

@implementation FLTRoutesController {
  NSMutableDictionary* _routeIdToController;
  FlutterMethodChannel* _methodChannel;
  NSObject<FlutterPluginRegistrar>* _registrar;
  GMSMapView* _mapView;
  float _markerAnimationDuration;
  BOOL _rotateThenTranslate;
}
- (instancetype)init:(FlutterMethodChannel*)methodChannel
             mapView:(GMSMapView*)mapView
           registrar:(NSObject<FlutterPluginRegistrar>*)registrar
markerAnimationDuration:(float)markerAnimationDuration
    rotateThenTranslate:(BOOL)rotateThenTranslate {
  self = [super init];
  if (self) {
    _methodChannel = methodChannel;
    _mapView = mapView;
    _routeIdToController = [NSMutableDictionary dictionaryWithCapacity:1];
    _registrar = registrar;
    _markerAnimationDuration = markerAnimationDuration;
    _rotateThenTranslate = rotateThenTranslate;
  }
  return self;
}
- (float)degreesToRadians:(float)degrees {
  return degrees * M_PI / 180;
};
- (float)radiansToDegrees:(float)radians {
  return radians * 180 / M_PI;
};
- (float)getBearing:(CLLocationCoordinate2D)position1 andSecond:(CLLocationCoordinate2D)position2 {
    float lat1 = [self degreesToRadians:position1.latitude];
    float lng1 = [self degreesToRadians:position1.longitude];
    float lat2 = [self degreesToRadians:position2.latitude];
    float lng2 = [self degreesToRadians:position2.longitude];
    float degree = [self radiansToDegrees:atan2(sin(lng2-lng1)*cos(lat2), cos(lat1)*sin(lat2)-sin(lat1)*cos(lat2)*cos(lng2-lng1))];
    if (degree >= 0) {
        return degree;
    }
    return degree+360;
}
- (void)routeAnimation:(FLTGoogleMapRouteController*)routeController {
  float fraction = 0.3;
  NSMutableArray<NSDictionary*>* routes = [routeController getRoutes];
  FLTGoogleMapMarkerController* markerController = [routeController getMarkerController];
  if (routes && markerController) {
    if (_markerAnimationDuration < 0) InterpretMarkerOptions([routes lastObject], markerController, _registrar);
    else {
      NSUInteger numberOfPositions = [routes count];
      float animationWithinRoute = _markerAnimationDuration / numberOfPositions;
      float delayInSeconds = 0.0f;
      CLLocationCoordinate2D startPosition = [markerController getPosition];
      for (NSDictionary* marker in routes) {
        CLLocationCoordinate2D finalPosition = [FLTMarkersController getPosition:marker];
        float bearing = [self getBearing:startPosition andSecond:finalPosition];
        NSMutableDictionary *newMarker = [[NSMutableDictionary alloc] init];
        NSDictionary *oldMarker = (NSDictionary *)[marker mutableCopy];
        [newMarker addEntriesFromDictionary:oldMarker];
        [newMarker setObject:@(bearing) forKey:@"rotation"];
      

        dispatch_time_t popTime1 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime1, dispatch_get_main_queue(), ^(void) {
          if (_rotateThenTranslate) {
            [CATransaction begin];
            [CATransaction setAnimationDuration:animationWithinRoute * fraction / 1000];
            [markerController setRotation:bearing];
            [CATransaction commit];
            dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animationWithinRoute * fraction / 1000 * NSEC_PER_SEC));
            dispatch_after(popTime2, dispatch_get_main_queue(), ^(void) {
              [CATransaction begin];
              [CATransaction setAnimationDuration:animationWithinRoute * (1 - fraction) / 1000];
              InterpretMarkerOptions(newMarker, markerController, _registrar);
              [CATransaction commit];
            });
          } else {
            [CATransaction begin];
            [CATransaction setAnimationDuration:animationWithinRoute / 1000];
            InterpretMarkerOptions(newMarker, markerController, _registrar);
            [CATransaction commit];
          }
        });

        startPosition = finalPosition;
        delayInSeconds += animationWithinRoute / 1000;
      }
    }
  }
}
- (void)addRoutes:(NSArray*)routesToAdd {
  for (NSDictionary* route in routesToAdd) {
    if (!route) {
      continue;
    }
    NSString* routeId = [self getRouteId:route];
    NSArray* markersToAdd = [self getMarkers:route];
    if (!markersToAdd) {
      continue;
    }
    FLTGoogleMapRouteController* routeController = nil;
    for (NSDictionary* markerToAdd in markersToAdd) {
      if (markerToAdd && routeController) {
        [routeController addMarker:markerToAdd];
      }
      else if (markerToAdd) {
        CLLocationCoordinate2D position = [FLTMarkersController getPosition:markerToAdd];
        FLTGoogleMapMarkerController* markerController =
        [[FLTGoogleMapMarkerController alloc] initMarkerWithPosition:position
                                                            markerId:routeId
                                                             mapView:_mapView];
        InterpretMarkerOptions(markerToAdd, markerController, _registrar);
        routeController = [[FLTGoogleMapRouteController alloc] initWithMarkerController:markerController];
        _routeIdToController[routeId] = routeController;
      }
    }
    if (routeController) {
      [self routeAnimation:routeController];
    }
  }
}
- (void)changeRoutes:(NSArray*)routesToChange {
  for (NSDictionary* route in routesToChange) {
    NSString* routeId = [self getRouteId:route];
    FLTGoogleMapRouteController* routeController = _routeIdToController[routeId];
    if (!routeController) {
      continue;
    }
    [routeController clearMarkers];
    NSArray* markers = [self getMarkers:route];
    if (!markers) {
      continue;
    }
    FLTGoogleMapMarkerController* markerController = [routeController getMarkerController];
    if (!markerController) {
      NSArray* routesToAdd = @[route];
      [self addRoutes:routesToAdd];
    }
    else {
      for (NSDictionary* marker in markers) {
        [routeController addMarker:marker];
      }
      [self routeAnimation:routeController];
    }
  }
}
- (void)removeRouteIds:(NSArray*)routeIdsToRemove {
  for (NSString* routeId in routeIdsToRemove) {
    if (!routeId) {
      continue;
    }
    FLTGoogleMapRouteController* routeController = _routeIdToController[routeId];
    if (!routeController) {
      continue;
    }
    [routeController remove];
    [_routeIdToController removeObjectForKey:routeId];
  }
}
- (BOOL)onMarkerTap:(NSString*)markerId {
  if (!markerId) {
    return NO;
  }
  FLTGoogleMapRouteController* routeController = _routeIdToController[markerId];
  if (!routeController) {
    return NO;
  }
  FLTGoogleMapMarkerController* markerController = [routeController getMarkerController];
  if (!markerController) {
    return NO;
  }
  [_methodChannel invokeMethod:@"marker#onTap" arguments:@{@"markerId" : markerId}];
  return markerController.consumeTapEvents;
}
- (void)onInfoWindowTap:(NSString*)markerId {
  if (markerId) {
    FLTGoogleMapRouteController* routeController = _routeIdToController[markerId];
    if (routeController && [routeController getMarkerController]) {
      [_methodChannel invokeMethod:@"infoWindow#onTap" arguments:@{@"markerId" : markerId}];
    }
  }
}
- (NSString*)getRouteId:(NSDictionary*)route {
  return route[@"routeId"];
}
- (NSArray*)getMarkers:(NSDictionary*)route {
  return route[@"markers"];
}
@end
