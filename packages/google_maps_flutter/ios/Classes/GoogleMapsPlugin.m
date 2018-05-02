#import "GoogleMapsPlugin.h"
#import "GoogleMaps/GoogleMaps.h"

@implementation FLTGoogleMapsPlugin {
  NSMutableDictionary* _mapViews;
  NSObject<FlutterPluginRegistrar>* _registrar;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/google_maps"
                                  binaryMessenger:[registrar messenger]];
  FLTGoogleMapsPlugin* instance = [[FLTGoogleMapsPlugin alloc] initWithRegistrar:registrar];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  self = [super init];
  if (self) {
    _registrar = registrar;
    _mapViews = [NSMutableDictionary dictionaryWithCapacity:1];
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([call.method isEqualToString:@"init"]) {
    // TODO(mravn): clear all map views
    result(nil);
  } else if ([call.method isEqualToString:@"createMap"]) {
    NSNumber* width = call.arguments[@"width"];
    NSNumber* height = call.arguments[@"height"];
    NSDictionary* options = call.arguments[@"options"];
    UIView* flutterView = [UIApplication sharedApplication].delegate.window.rootViewController.view;
    GMSMapView* mapView = [GMSMapView mapWithFrame:CGRectMake(0.0f, 0.0f, width.floatValue, height.floatValue)
                                            camera:toOptionalCameraPosition(options[@"cameraPosition"])];
    updateMapOptions(options, mapView);
    mapView.hidden = YES;
    _mapViews[@1] = mapView;
    [flutterView addSubview:mapView];
    result(@1);
  } else if ([call.method isEqualToString:@"showMapOverlay"]) {
    GMSMapView* mapView = _mapViews[call.arguments[@"map"]];
    NSNumber* x = call.arguments[@"x"];
    NSNumber* y = call.arguments[@"y"];
    mapView.frame = CGRectMake(x.floatValue, y.floatValue, CGRectGetWidth(mapView.frame), CGRectGetHeight(mapView.frame));
    mapView.hidden = NO;
  } else if ([call.method isEqualToString:@"hideMapOverlay"]) {
    FlutterError* error;
    GMSMapView* mapView = [self mapFromCall:call error:&error];
    if (mapView) {
      mapView.hidden = YES;
      result(nil);
    } else {
      result(error);
    }
  } else if ([call.method isEqualToString:@"animateCamera"]) {
    FlutterError* error;
    GMSMapView* mapView = [self mapFromCall:call error:&error];
    if (mapView) {
      [mapView animateWithCameraUpdate:toCameraUpdate(call.arguments[@"cameraUpdate"])];
      result(nil);
    } else {
      result(error);
    }
  } else if ([call.method isEqualToString:@"moveCamera"]) {
    FlutterError* error;
    GMSMapView* mapView = [self mapFromCall:call error:&error];
    if (mapView) {
      [mapView moveCamera:toCameraUpdate(call.arguments[@"cameraUpdate"])];
      result(nil);
    } else {
      result(error);
    }
  } else if ([call.method isEqualToString:@"updateMapOptions"]) {
    FlutterError* error;
    GMSMapView* mapView = [self mapFromCall:call error:&error];
    if (mapView) {
      updateMapOptions(call.arguments[@"options"], mapView);
      result(nil);
    } else {
      result(error);
    }
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (GMSMapView* _Nonnull) mapFromCall:(FlutterMethodCall*)call error:(FlutterError**)error {
  id mapId = call.arguments[@"map"];
  GMSMapView* mapView = _mapViews[mapId];
  if (!mapView && error) {
    *error = [FlutterError errorWithCode:@"unknown_map" message:nil details:mapId];
  }
  return mapView;
}

static void updateMapOptions(id json, GMSMapView* mapView) {
  NSDictionary* data = json;
  GMSUISettings* settings = mapView.settings;
  id cameraPosition = data[@"cameraPosition"];
  if (cameraPosition) {
    [mapView setCamera:toCameraPosition(cameraPosition)];
  }
  id cameraTargetBounds = data[@"cameraTargetBounds"];
  if (cameraTargetBounds) {
    [mapView setCameraTargetBounds:toBounds(cameraTargetBounds)];
  }
  id compassEnabled = data[@"compassEnabled"];
  if (compassEnabled) {
    settings.compassButton = toBool(compassEnabled);
  }
  id mapType = data[@"mapType"];
  if (mapType) {
    [mapView setMapType:toMapViewType(mapType)];
  }
  id minMaxZoomPreference = data[@"minMaxZoomPreference"];
  if (minMaxZoomPreference) {
    NSArray* zoomData = minMaxZoomPreference;
    float minZoom = kGMSMinZoomLevel;
    float maxZoom = kGMSMaxZoomLevel;
    if (![zoomData[0] isEqual:[NSNull null]]) {
      minZoom = toFloat(zoomData[0]);
    }
    if (![zoomData[1] isEqual:[NSNull null]]) {
      maxZoom = toFloat(zoomData[1]);
    }
    [mapView setMinZoom:minZoom maxZoom:maxZoom];
  }
  id rotateGesturesEnabled = data[@"rotateGesturesEnabled"];
  if (rotateGesturesEnabled) {
    settings.rotateGestures = toBool(rotateGesturesEnabled);
  }
  id scrollGesturesEnabled = data[@"scrollGesturesEnabled"];
  if (scrollGesturesEnabled) {
    settings.scrollGestures = toBool(scrollGesturesEnabled);
  }
  id tiltGesturesEnabled = data[@"tiltGesturesEnabled"];
  if (tiltGesturesEnabled) {
    settings.tiltGestures = toBool(tiltGesturesEnabled);
  }
  id zoomGesturesEnabled = data[@"zoomGesturesEnabled"];
  if (zoomGesturesEnabled) {
    settings.zoomGestures = toBool(zoomGesturesEnabled);
  }
}

static GMSCameraUpdate* _Nonnull toCameraUpdate(id json) {
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

static GMSCameraPosition* _Nonnull toCameraPosition(id json) {
  NSDictionary* data = json;
  return [GMSCameraPosition cameraWithTarget:toLocation(data[@"target"])
                                        zoom:toFloat(data[@"zoom"])
                                     bearing:toDouble(data[@"bearing"])
                                viewingAngle:toDouble(data[@"tilt"])];
}

static GMSCameraPosition* _Nullable toOptionalCameraPosition(id json) {
  return json ? toCameraPosition(json) : nil;
}

static GMSCoordinateBounds* _Nonnull toBounds(id json) {
  NSArray* data = json;
  return [[GMSCoordinateBounds alloc] initWithCoordinate:toLocation(data[0]) coordinate:toLocation(data[1])];
}

static CLLocationCoordinate2D toLocation(id json) {
  NSArray* data = json;
  return CLLocationCoordinate2DMake(toDouble(data[0]), toDouble(data[1]));
}

static GMSMapViewType toMapViewType(id json) {
  int value = toInt(json);
  return (GMSMapViewType) (value == 0 ? 5 : value);
}

static CGPoint toPoint(id json) {
  NSArray* data = json;
  return CGPointMake(toDouble(data[0]), toDouble(data[1]));
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
@end
