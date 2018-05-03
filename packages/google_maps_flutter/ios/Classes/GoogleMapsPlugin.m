#import "GoogleMapsPlugin.h"

// JSON conversion

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

static id locationToJson(CLLocationCoordinate2D position) {
  return @[@(position.latitude), @(position.longitude)];
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

static id positionToJson(GMSCameraPosition* position) {
  return @{
           @"target": locationToJson([position target]),
           @"zoom": @([position zoom]),
           @"bearing": @([position bearing]),
           @"tilt": @([position viewingAngle]),
           };
}

static GMSCameraPosition* toOptionalCameraPosition(id json) {
  return json ? toCameraPosition(json) : nil;
}

static GMSCoordinateBounds* toBounds(id json) {
  NSArray* data = json;
  return [[GMSCoordinateBounds alloc] initWithCoordinate:toLocation(data[0]) coordinate:toLocation(data[1])];
}

static GMSMapViewType toMapViewType(id json) {
  int value = toInt(json);
  return (GMSMapViewType) (value == 0 ? 5 : value);
}

static void updateMarkerOptions(id json, GMSMarker* marker, GMSMapView* mapView, NSObject<FlutterPluginRegistrar>* registrar) {
  NSDictionary* data = json;
  id alpha = data[@"alpha"];
  if (alpha) {
    marker.opacity = toFloat(alpha);
  }
  id anchor = data[@"anchor"];
  if (anchor) {
    marker.groundAnchor = toPoint(anchor);
  }
  id draggable = data[@"draggable"];
  if (draggable) {
    marker.draggable = toBool(draggable);
  }
  id icon = data[@"icon"];
  if (icon) {
    NSArray* iconData = icon;
    if ([iconData[0] isEqualToString:@"defaultMarker"]) {
      CGFloat hue = (iconData.count == 1) ? 0.0f : toDouble(iconData[1]);
      marker.icon = [GMSMarker markerImageWithColor:[UIColor colorWithHue:hue / 360.0
                                                               saturation:1.0
                                                               brightness:0.7
                                                                    alpha:1.0]];
    } else if ([iconData[0] isEqualToString:@"fromAsset"]) {
      if (iconData.count == 2) {
        marker.icon = [UIImage imageNamed:[registrar lookupKeyForAsset:iconData[1]]];
      } else {
        marker.icon = [UIImage imageNamed:[registrar lookupKeyForAsset:iconData[1] fromPackage:iconData[2]]];
      }
      // TODO(mravn): handle file-based icons
    }
  }
  id flat = data[@"flat"];
  if (flat) {
    marker.flat = toBool(flat);
  }
  id infoWindowAnchor = data[@"infoWindowAnchor"];
  if (infoWindowAnchor) {
    marker.infoWindowAnchor = toPoint(infoWindowAnchor);
  }
  // TODO(mravn): handle infoWindowShown
  id infoWindowText = data[@"infoWindowText"];
  if (infoWindowText) {
    NSArray* infoWindowTextData = infoWindowText;
    marker.title = [infoWindowTextData[0] isEqual:[NSNull null]] ? nil : infoWindowTextData[0];
    marker.snippet = [infoWindowTextData[1] isEqual:[NSNull null]] ? nil : infoWindowTextData[1];
  }
  id rotation = data[@"rotation"];
  if (rotation) {
    marker.rotation = toDouble(rotation);
  }
  id visible = data[@"visible"];
  if (visible) {
    marker.map = toBool(visible) ? mapView : nil;
  }
  id zIndex = data[@"zIndex"];
  if (zIndex) {
    marker.zIndex = toInt(zIndex);
  }
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

// Controller interfaces

@interface FLTGoogleMapController : NSObject<GMSMapViewDelegate>
@property (atomic, readonly) GMSMapView* mapView;
@property (atomic, readonly) id mapId;
@property (atomic) BOOL tracksCameraPosition;
+(instancetype)controllerWithWidth:(CGFloat)width height:(CGFloat)height options:(id)json channel:(FlutterMethodChannel*)channel registrar:(NSObject<FlutterPluginRegistrar>*)registrar;
-(void)updateMapOptions:(id)json;
-(void)showAtX:(CGFloat)x Y:(CGFloat)y;
-(void)hide;
-(void)animateWithCameraUpdate:(GMSCameraUpdate*)cameraUpdate;
-(void)moveWithCameraUpdate:(GMSCameraUpdate*)cameraUpdate;
-(NSString*)addMarkerWithPosition:(CLLocationCoordinate2D)position;
-(GMSMarker*)markerWithId:(NSString*)markerId;
-(void)removeMarkerWithId:(NSString*)markerId;
@end

@interface FLTGoogleMapMarkerController : NSObject
@property (atomic, readonly) GMSMarker* marker;
@property (atomic, readonly) NSString* markerId;
@property (atomic) BOOL consumesTapEvents;
@end

// Controller implementations

static uint64_t _nextMap = 1;

@implementation FLTGoogleMapController {
  NSObject<FlutterPluginRegistrar>* _registrar;
  FlutterMethodChannel* _channel;
  NSMutableDictionary* _markers;
  uint64_t _nextMarker;
  BOOL _trackCameraPosition;
}

+(instancetype)controllerWithWidth:(CGFloat)width height:(CGFloat)height options:(id)json channel:(FlutterMethodChannel*)channel registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  NSDictionary* data = json;
  GMSCameraPosition* camera = toOptionalCameraPosition(data[@"cameraPosition"]);
  GMSMapView* mapView = [GMSMapView mapWithFrame:CGRectMake(0.0, 0.0, width, height)
                                          camera:camera];
  FLTGoogleMapController* controller = [[FLTGoogleMapController alloc] initWithMapView:mapView mapId:@(_nextMap++) channel:channel registrar:registrar];
  mapView.hidden = YES;
  mapView.delegate = controller;
  [controller updateMapOptions:data];
  return controller;
}

-(instancetype)initWithMapView:(GMSMapView*)mapView mapId:(id)mapId channel:(FlutterMethodChannel*)channel registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  self = [super init];
  if (self) {
    _registrar = registrar;
    _mapView = mapView;
    _channel = channel;
    _mapId = mapId;
    _nextMarker = 0;
    _markers = [NSMutableDictionary dictionaryWithCapacity:1];
    _tracksCameraPosition = false;
  }
  return self;
}

-(void)showAtX:(CGFloat)x Y:(CGFloat)y {
  _mapView.frame = CGRectMake(x, y, CGRectGetWidth(_mapView.frame), CGRectGetHeight(_mapView.frame));
  _mapView.hidden = NO;
}

-(void)hide {
  _mapView.hidden = YES;
}

-(void)updateMapOptions:(id)json {
  NSDictionary* data = json;
  GMSUISettings* settings = _mapView.settings;
  id cameraPosition = data[@"cameraPosition"];
  if (cameraPosition) {
    [_mapView setCamera:toCameraPosition(cameraPosition)];
  }
  id cameraTargetBounds = data[@"cameraTargetBounds"];
  if (cameraTargetBounds) {
    [_mapView setCameraTargetBounds:toBounds(cameraTargetBounds)];
  }
  id compassEnabled = data[@"compassEnabled"];
  if (compassEnabled) {
    settings.compassButton = toBool(compassEnabled);
  }
  id mapType = data[@"mapType"];
  if (mapType) {
    [_mapView setMapType:toMapViewType(mapType)];
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
    [_mapView setMinZoom:minZoom maxZoom:maxZoom];
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
  id trackCameraPosition = data[@"trackCameraPosition"];
  if (trackCameraPosition) {
    _trackCameraPosition = toBool(trackCameraPosition);
  }
  id zoomGesturesEnabled = data[@"zoomGesturesEnabled"];
  if (zoomGesturesEnabled) {
    settings.zoomGestures = toBool(zoomGesturesEnabled);
  }
}

-(void)animateWithCameraUpdate:(GMSCameraUpdate*)cameraUpdate {
  [_mapView animateWithCameraUpdate:cameraUpdate];
}

-(void)moveWithCameraUpdate:(GMSCameraUpdate*)cameraUpdate {
  [_mapView moveCamera:cameraUpdate];
}

-(NSString*)addMarkerWithPosition:(CLLocationCoordinate2D)position {
  NSString* markerId = [NSString stringWithFormat:@"%lld", _nextMarker++];
  GMSMarker* marker = [GMSMarker markerWithPosition:position];
  _markers[markerId] = marker;
  marker.map = _mapView;
  marker.userData = @{@"map":_mapId, @"marker":markerId};
  return markerId;
}

-(GMSMarker*)markerWithId:(NSString*)markerId {
  return _markers[markerId];
}

-(void)removeMarkerWithId:(NSString*)markerId {
  GMSMarker* marker = _markers[markerId];
  if (marker) {
    marker.map = nil;
    [_markers removeObjectForKey:markerId];
  }
}

// GMSMapViewDelegate methods

- (void)mapView:(GMSMapView*)mapView willMove:(BOOL)gesture {
  [_channel invokeMethod:@"map#onCameraMoveStarted" arguments:@{@"map":_mapId, @"isGesture":@(gesture)}];
}

- (void)mapView:(GMSMapView*)mapView didChangeCameraPosition:(GMSCameraPosition*)position {
  [_channel invokeMethod:@"map#onCameraMove" arguments:@{@"map":_mapId, @"position":positionToJson(position)}];
}

- (void)mapView:(GMSMapView*)mapView idleAtCameraPosition:(GMSCameraPosition*)position {
  [_channel invokeMethod:@"map#onCameraIdle" arguments:@{@"map":_mapId}];
}

- (BOOL)mapView:(GMSMapView*)mapView didTapMarker:(GMSMarker*)marker {
  [_channel invokeMethod:@"marker#onTap" arguments:marker.userData];
  return NO;
}
@end

// Plugin implementation

@implementation FLTGoogleMapsPlugin {
  NSObject<FlutterPluginRegistrar>* _registrar;
  FlutterMethodChannel* _channel;
  NSMutableDictionary* _mapControllers;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/google_maps"
                                  binaryMessenger:[registrar messenger]];
  FLTGoogleMapsPlugin* instance = [[FLTGoogleMapsPlugin alloc] initWithRegistrar:registrar channel:channel];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar channel:(FlutterMethodChannel*)channel {
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
      [controller.mapView removeFromSuperview];
      controller.mapView.delegate = nil; // Breaks retain cycle mapView->delegate->mapView.
    }
    [_mapControllers removeAllObjects];
    result(nil);
  } else if ([call.method isEqualToString:@"createMap"]) {
    UIView* flutterView = [UIApplication sharedApplication].delegate.window.rootViewController.view;
    FLTGoogleMapController* controller = [FLTGoogleMapController controllerWithWidth:toDouble(call.arguments[@"width"])
                                                                              height:toDouble(call.arguments[@"height"])
                                                                             options:call.arguments[@"options"]
                                                                             channel:_channel
                                                                           registrar:_registrar];
    _mapControllers[controller.mapId] = controller;
    [flutterView addSubview:controller.mapView];
    result(controller.mapId);
  } else if ([call.method isEqualToString:@"showMapOverlay"]) {
    FlutterError* error;
    FLTGoogleMapController* controller = [self mapFromCall:call error:&error];
    if (controller) {
      [controller showAtX:toDouble(call.arguments[@"x"]) Y:toDouble(call.arguments[@"y"])];
      result(nil);
    } else {
      result(error);
    }
  } else if ([call.method isEqualToString:@"hideMapOverlay"]) {
    FlutterError* error;
    FLTGoogleMapController* controller = [self mapFromCall:call error:&error];
    if (controller) {
      [controller hide];
      result(nil);
    } else {
      result(error);
    }
  } else if ([call.method isEqualToString:@"animateCamera"]) {
    FlutterError* error;
    FLTGoogleMapController* controller = [self mapFromCall:call error:&error];
    if (controller) {
      [controller animateWithCameraUpdate:toCameraUpdate(call.arguments[@"cameraUpdate"])];
      result(nil);
    } else {
      result(error);
    }
  } else if ([call.method isEqualToString:@"moveCamera"]) {
    FlutterError* error;
    FLTGoogleMapController* controller = [self mapFromCall:call error:&error];
    if (controller) {
      [controller moveWithCameraUpdate:toCameraUpdate(call.arguments[@"cameraUpdate"])];
      result(nil);
    } else {
      result(error);
    }
  } else if ([call.method isEqualToString:@"updateMapOptions"]) {
    FlutterError* error;
    FLTGoogleMapController* controller = [self mapFromCall:call error:&error];
    if (controller) {
      [controller updateMapOptions:call.arguments[@"options"]];
      result(nil);
    } else {
      result(error);
    }
  } else if ([call.method isEqualToString:@"addMarker"]) {
    NSDictionary* options = call.arguments[@"options"];
    FlutterError* error;
    FLTGoogleMapController* controller = [self mapFromCall:call error:&error];
    if (controller) {
      id markerId = [controller addMarkerWithPosition:toLocation(options[@"position"])];
      updateMarkerOptions(options, [controller markerWithId:markerId], controller.mapView, _registrar);
      result([NSString stringWithFormat:@"%@", markerId]);
    } else {
      result(error);
    }
  } else if ([call.method isEqualToString:@"marker#update"]) {
    FlutterError* error;
    FLTGoogleMapController* controller = [self mapFromCall:call error:&error];
    if (controller) {
      updateMarkerOptions(call.arguments[@"options"], [controller markerWithId:call.arguments[@"marker"]], controller.mapView, _registrar);
      result(nil);
    } else {
      result(error);
    }
  } else if ([call.method isEqualToString:@"marker#remove"]) {
    FlutterError* error;
    FLTGoogleMapController* controller = [self mapFromCall:call error:&error];
    if (controller) {
      [controller removeMarkerWithId:call.arguments[@"marker"]];
      result(nil);
    } else {
      result(error);
    }
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (FLTGoogleMapController*) mapFromCall:(FlutterMethodCall*)call error:(FlutterError**)error {
  id mapId = call.arguments[@"map"];
  FLTGoogleMapController* controller = _mapControllers[mapId];
  if (!controller && error) {
    *error = [FlutterError errorWithCode:@"unknown_map" message:nil details:mapId];
  }
  return controller;
}
@end
