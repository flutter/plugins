// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapMarkerController.h"
#import "JsonConversions.h"

static UIImage* ExtractIcon(NSObject<FlutterPluginRegistrar>* registrar, NSArray* icon);
static void InterpretInfoWindow(id<FLTGoogleMapMarkerOptionsSink> sink, NSDictionary* data);

@implementation FLTGoogleMapMarkerController {
  GMSMarker* _marker;
  GMSMapView* _mapView;
  BOOL _consumeTapEvents;
}
- (instancetype)initMarkerWithPosition:(CLLocationCoordinate2D)position
                              markerId:(NSString*)markerId
                               mapView:(GMSMapView*)mapView {
  self = [super init];
  if (self) {
    _marker = [GMSMarker markerWithPosition:position];
    _mapView = mapView;
    _markerId = markerId;
    _marker.userData = @[ _markerId ];
    _consumeTapEvents = NO;
  }
  return self;
}
- (BOOL)consumeTapEvents {
  return _consumeTapEvents;
}
- (void)removeMarker {
  _marker.map = nil;
}
- (CLLocationCoordinate2D)getPosition {
  return _marker.position;
}

#pragma mark - FLTGoogleMapMarkerOptionsSink methods

- (void)setAlpha:(float)alpha {
  _marker.opacity = alpha;
}
- (void)setAnchor:(CGPoint)anchor {
  _marker.groundAnchor = anchor;
}
- (void)setConsumeTapEvents:(BOOL)consumes {
  _consumeTapEvents = consumes;
}
- (void)setDraggable:(BOOL)draggable {
  _marker.draggable = draggable;
}
- (void)setFlat:(BOOL)flat {
  _marker.flat = flat;
}
- (void)setIcon:(UIImage*)icon {
  _marker.icon = icon;
}
- (void)setInfoWindowAnchor:(CGPoint)anchor {
  _marker.infoWindowAnchor = anchor;
}
- (void)setInfoWindowTitle:(NSString*)title snippet:(NSString*)snippet {
  _marker.title = title;
  _marker.snippet = snippet;
}
- (void)setPosition:(CLLocationCoordinate2D)position {
  _marker.position = position;
}
- (void)setRotation:(CLLocationDegrees)rotation {
  _marker.rotation = rotation;
}
- (void)setVisible:(BOOL)visible {
  _marker.map = visible ? _mapView : nil;
}
- (void)setZIndex:(int)zIndex {
  _marker.zIndex = zIndex;
}
@end

static double ToDouble(NSNumber* data) { return [FLTGoogleMapJsonConversions toDouble:data]; }

static float ToFloat(NSNumber* data) { return [FLTGoogleMapJsonConversions toFloat:data]; }

static CLLocationCoordinate2D ToLocation(NSArray* data) {
  return [FLTGoogleMapJsonConversions toLocation:data];
}

static int ToInt(NSNumber* data) { return [FLTGoogleMapJsonConversions toInt:data]; }

static BOOL ToBool(NSNumber* data) { return [FLTGoogleMapJsonConversions toBool:data]; }

static CGPoint ToPoint(NSArray* data) { return [FLTGoogleMapJsonConversions toPoint:data]; }

static NSArray* PositionToJson(CLLocationCoordinate2D data) {
  return [FLTGoogleMapJsonConversions positionToJson:data];
}

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

@implementation FLTMarkersController {
  NSMutableDictionary* _markerIdToController;
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
    _markerIdToController = [NSMutableDictionary dictionaryWithCapacity:1];
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
- (void)addMarkers:(NSArray*)markersToAdd {
  for (NSDictionary* marker in markersToAdd) {
    CLLocationCoordinate2D position = [FLTMarkersController getPosition:marker];
    NSString* markerId = [FLTMarkersController getMarkerId:marker];
    FLTGoogleMapMarkerController* controller =
        [[FLTGoogleMapMarkerController alloc] initMarkerWithPosition:position
                                                            markerId:markerId
                                                             mapView:_mapView];
    InterpretMarkerOptions(marker, controller, _registrar);
    _markerIdToController[markerId] = controller;
  }
}
- (void)changeMarkers:(NSArray*)markersToChange {
  float fraction = 0.3;
  for (NSDictionary* marker in markersToChange) {
    NSString* markerId = [FLTMarkersController getMarkerId:marker];
    FLTGoogleMapMarkerController* controller = _markerIdToController[markerId];
    if (!controller) {
      continue;
    }
    if (_markerAnimationDuration < 0) InterpretMarkerOptions(marker, controller, _registrar);
    else {
      CLLocationCoordinate2D startPosition = [controller getPosition];
      CLLocationCoordinate2D finalPosition = [FLTMarkersController getPosition:marker];
      float bearing = [self getBearing:startPosition andSecond:finalPosition];
      NSMutableDictionary *newMarker = [[NSMutableDictionary alloc] init];
      NSDictionary *oldMarker = (NSDictionary *)[marker mutableCopy];
      [newMarker addEntriesFromDictionary:oldMarker];
      [newMarker setObject:@(bearing) forKey:@"rotation"];
      
      if (_rotateThenTranslate) {
        [CATransaction begin];
        [CATransaction setAnimationDuration:_markerAnimationDuration * fraction / 1000];
        [controller setRotation:bearing];
        [CATransaction commit];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_markerAnimationDuration * fraction / 1000 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
          [CATransaction begin];
          [CATransaction setAnimationDuration:_markerAnimationDuration * (1 - fraction) / 1000];
          InterpretMarkerOptions(newMarker, controller, _registrar);
          [CATransaction commit];
        });
      } else {
        [CATransaction begin];
        [CATransaction setAnimationDuration:_markerAnimationDuration / 1000];
        InterpretMarkerOptions(newMarker, controller, _registrar);
        [CATransaction commit];
      }
    }
  }
}
- (void)removeMarkerIds:(NSArray*)markerIdsToRemove {
  for (NSString* markerId in markerIdsToRemove) {
    if (!markerId) {
      continue;
    }
    FLTGoogleMapMarkerController* controller = _markerIdToController[markerId];
    if (!controller) {
      continue;
    }
    [controller removeMarker];
    [_markerIdToController removeObjectForKey:markerId];
  }
}
- (BOOL)onMarkerTap:(NSString*)markerId {
  if (!markerId) {
    return NO;
  }
  FLTGoogleMapMarkerController* controller = _markerIdToController[markerId];
  if (!controller) {
    return NO;
  }
  [_methodChannel invokeMethod:@"marker#onTap" arguments:@{@"markerId" : markerId}];
  return controller.consumeTapEvents;
}
- (void)onInfoWindowTap:(NSString*)markerId {
  if (markerId && _markerIdToController[markerId]) {
    [_methodChannel invokeMethod:@"infoWindow#onTap" arguments:@{@"markerId" : markerId}];
  }
}

+ (CLLocationCoordinate2D)getPosition:(NSDictionary*)marker {
  NSArray* position = marker[@"position"];
  return ToLocation(position);
}
+ (NSString*)getMarkerId:(NSDictionary*)marker {
  return marker[@"markerId"];
}
@end
