// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapGroundOverlayController.h"
#import "JsonConversions.h"

static UIImage* ExtractBitmapDescriptor(NSObject<FlutterPluginRegistrar>* registrar, NSArray* bitmap);

@implementation FLTGoogleMapGroundOverlayController {
  GMSGroundOverlay* _groundOverlay;
  GMSMapView* _mapView;
  BOOL _consumeTapEvents;
}
- (instancetype)initGroundOverlayWithPosition:(CLLocationCoordinate2D)position
                                         icon:(UIImage*)icon
                                    zoomLevel:(CGFloat)zoomLevel
                              groundOverlayId:(NSString*)groundOverlayId
                                      mapView:(GMSMapView*)mapView {
  self = [super init];
  if (self) {
    _groundOverlay = [GMSGroundOverlay groundOverlayWithPosition:position icon:icon zoomLevel:zoomLevel];
    _mapView = mapView;
    _groundOverlayId = groundOverlayId;
    _groundOverlay.userData = @[ _groundOverlayId ];
    _consumeTapEvents = NO;
  }
  return self;
}

- (instancetype)initGroundOverlayWithBounds:(GMSCoordinateBounds*)bounds
                                       icon:(UIImage*)icon
                            groundOverlayId:(NSString*)groundOverlayId
                                    mapView:(GMSMapView*)mapView {
  self = [super init];
  if (self) {
    _groundOverlay = [GMSGroundOverlay groundOverlayWithBounds:bounds icon:icon];
    _mapView = mapView;
    _groundOverlayId = groundOverlayId;
    _groundOverlay.userData = @[ _groundOverlayId ];
    _consumeTapEvents = NO;
  }
  return self;
}

- (BOOL)consumeTapEvents {
  return _consumeTapEvents;
}

- (void)removeGroundOverlay {
  _groundOverlay.map = nil;
}

#pragma mark - FLTGoogleMapGroundOverlayOptionsSink methods

- (void)setConsumeTapEvents:(BOOL)consumes {
  _groundOverlay.tappable = consumes;
}
- (void)setVisible:(BOOL)visible {
  _groundOverlay.map = visible ? _mapView : nil;
}
- (void)setZIndex:(int)zIndex {
  _groundOverlay.zIndex = zIndex;
}
- (void)setBounds:(GMSCoordinateBounds *)bounds {
  _groundOverlay.bounds = bounds;
}
- (void)setLocation:(CLLocationCoordinate2D)location width:(CGFloat)width height:(CGFloat)height {
  _groundOverlay.position = location;
}
- (void)setBitmapDescriptor:(UIImage*)bd {
  _groundOverlay.icon = bd;
}
- (void)setBearing:(CLLocationDirection)bearing {
  _groundOverlay.bearing = bearing;
}
- (void)setOpacity:(float)opacity {
  _groundOverlay.opacity = opacity;
}
@end

static int ToInt(NSNumber* data) { return [FLTGoogleMapJsonConversions toInt:data]; }

static BOOL ToBool(NSNumber* data) { return [FLTGoogleMapJsonConversions toBool:data]; }

static double ToDouble(NSNumber* data) { return [FLTGoogleMapJsonConversions toDouble:data]; }

static float ToFloat(NSNumber* data) { return [FLTGoogleMapJsonConversions toFloat:data]; }

static CLLocationCoordinate2D ToLocation(NSArray* data) {
  return [FLTGoogleMapJsonConversions toLocation:data];
}

static GMSCoordinateBounds* ToLatLngBounds(NSArray* data) {
  return [[GMSCoordinateBounds alloc] initWithCoordinate:ToLocation(data[0])
                                              coordinate:ToLocation(data[1])];
}

static void InterpretGroundOverlayOptions(NSDictionary* data, id<FLTGoogleMapGroundOverlayOptionsSink> sink,
                                   NSObject<FlutterPluginRegistrar>* registrar) {
  NSNumber* consumeTapEvents = data[@"consumeTapEvents"];
  if (consumeTapEvents != nil) {
    [sink setConsumeTapEvents:ToBool(consumeTapEvents)];
  }
  NSNumber* visible = data[@"visible"];
  if (visible != nil) {
    [sink setVisible:ToBool(visible)];
  }
  NSNumber* zIndex = data[@"zIndex"];
  if (zIndex != nil) {
    [sink setZIndex:ToInt(zIndex)];
  }
  NSNumber* transparency = data[@"transparency"];
  if (transparency != nil) {
    float opacity = 1 - ToFloat(transparency);
    [sink setOpacity:opacity];
  }
  NSNumber* width = data[@"width"];
  NSNumber* height = data[@"height"];
  NSArray* location = data[@"location"];
  if (location) {
    if (height != nil) {
      [sink setLocation:ToLocation(location) width:ToDouble(width) height:ToDouble(height)];
    } else {
      if (width != nil) {
        [sink setLocation:ToLocation(location) width:ToDouble(width) height:0];
      }
    }
  }
  NSArray* bounds = data[@"bounds"];
  if (bounds) {
    [sink setBounds:ToLatLngBounds(bounds)];
  }
  NSNumber* bearing = data[@"bearing"];
  if (bearing != nil) {
    [sink setBearing:ToFloat(bearing)];
  }  
  NSArray* bitmap = data[@"bitmap"];
  if (bitmap) {
    UIImage* image = ExtractBitmapDescriptor(registrar, bitmap);
    [sink setBitmapDescriptor:image];
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

static UIImage* ExtractBitmapDescriptor(NSObject<FlutterPluginRegistrar>* registrar, NSArray* bitmapData) {
  UIImage* image;
  if ([bitmapData.firstObject isEqualToString:@"fromAsset"]) {
    if (bitmapData.count == 2) {
      image = [UIImage imageNamed:[registrar lookupKeyForAsset:bitmapData[1]]];
    } else {
      image = [UIImage imageNamed:[registrar lookupKeyForAsset:bitmapData[1]
                                                   fromPackage:bitmapData[2]]];
    }
  } else if ([bitmapData.firstObject isEqualToString:@"fromAssetImage"]) {
    if (bitmapData.count == 3) {
      image = [UIImage imageNamed:[registrar lookupKeyForAsset:bitmapData[1]]];
      NSNumber* scaleParam = bitmapData[2];
      image = scaleImage(image, scaleParam);
    } else {
      NSString* error =
          [NSString stringWithFormat:@"'fromAssetImage' should have exactly 3 arguments. Got: %lu",
                                     (unsigned long)bitmapData.count];
      NSException* exception = [NSException exceptionWithName:@"InvalidBitmapDescriptor"
                                                       reason:error
                                                     userInfo:nil];
      @throw exception;
    }
  } else if ([bitmapData[0] isEqualToString:@"fromBytes"]) {
    if (bitmapData.count == 2) {
      @try {
        FlutterStandardTypedData* byteData = bitmapData[1];
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
                           (unsigned long)bitmapData.count];
      NSException* exception = [NSException exceptionWithName:@"InvalidByteDescriptor"
                                                       reason:error
                                                     userInfo:nil];
      @throw exception;
    }
  }

  return image;
}

@implementation FLTGroundOverlaysController {
  NSMutableDictionary* _groundOverlayIdToController;
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
    _groundOverlayIdToController = [NSMutableDictionary dictionaryWithCapacity:1];
    _registrar = registrar;
  }
  return self;
}
- (void)addGroundOverlays:(NSArray*)groundOverlaysToAdd {
  for (NSDictionary* groundOverlay in groundOverlaysToAdd) {
    GMSCoordinateBounds* bounds = [FLTGroundOverlaysController getBounds:groundOverlay];
    UIImage* icon = [FLTGroundOverlaysController getImage:groundOverlay registrar:_registrar];
    NSString* groundOverlayId = [FLTGroundOverlaysController getGroundOverlayId:groundOverlay];
    
    FLTGoogleMapGroundOverlayController* controller =
        [[FLTGoogleMapGroundOverlayController alloc] initGroundOverlayWithBounds:bounds
                                                                            icon:icon
                                                                 groundOverlayId:groundOverlayId
                                                                         mapView:_mapView];
    InterpretGroundOverlayOptions(groundOverlay, controller, _registrar);
    _groundOverlayIdToController[groundOverlayId] = controller;
  }
}
- (void)changeGroundOverlays:(NSArray*)groundOverlaysToChange {
  for (NSDictionary* groundOverlay in groundOverlaysToChange) {
    NSString* groundOverlayId = [FLTGroundOverlaysController getGroundOverlayId:groundOverlay];
    FLTGoogleMapGroundOverlayController* controller = _groundOverlayIdToController[groundOverlayId];
    if (!controller) {
      continue;
    }
    InterpretGroundOverlayOptions(groundOverlay, controller, _registrar);
  }
}
- (void)removeGroundOverlayIds:(NSArray*)groundOverlayIdsToRemove {
  for (NSString* groundOverlayId in groundOverlayIdsToRemove) {
    if (!groundOverlayId) {
      continue;
    }
    FLTGoogleMapGroundOverlayController* controller = _groundOverlayIdToController[groundOverlayId];
    if (!controller) {
      continue;
    }
    [controller removeGroundOverlay];
    [_groundOverlayIdToController removeObjectForKey:groundOverlayId];
  }
}
- (bool)hasGroundOverlayWithId:(NSString*)groundOverlayId {
  if (!groundOverlayId) {
    return false;
  }
  return _groundOverlayIdToController[groundOverlayId] != nil;
}
- (void)onGroundOverlayTap:(NSString*)groundOverlayId {
  if (!groundOverlayId) {
    return;
  }
  FLTGoogleMapGroundOverlayController* controller = _groundOverlayIdToController[groundOverlayId];
  if (!controller) {
    return;
  }
  [_methodChannel invokeMethod:@"groundOverlay#onTap" arguments:@{@"groundOverlayId" : groundOverlayId}];
}
+ (GMSCoordinateBounds*)getBounds:(NSDictionary*)groundOverlay {
  NSArray* bounds = groundOverlay[@"bounds"];
  return ToLatLngBounds(bounds);
}
+ (UIImage*)getImage:(NSDictionary*)groundOverlay registrar:(NSObject<FlutterPluginRegistrar>*) registrar {
  NSArray* image = groundOverlay[@"bitmap"];
  return ExtractBitmapDescriptor(registrar, image);
}
+ (NSString*)getGroundOverlayId:(NSDictionary*)groundOverlay {
  return groundOverlay[@"groundOverlayId"];
}
@end
