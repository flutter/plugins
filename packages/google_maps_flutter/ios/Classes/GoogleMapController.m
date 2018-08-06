// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapController.h"

static uint64_t _nextMapId = 0;

@implementation FLTGoogleMapController {
  GMSMapView* _mapView;
  NSMutableDictionary* _markers;
    // enable location for partycon
    // DON'T ANYBODY DARE submit PR for this ugly try-catch sollution to google
  CLLocationManager *_locationManager;
  BOOL _trackCameraPosition;
    
    // enable location for partycon
    // DON'T ANYBODY DARE submit PR for this ugly try-catch sollution to google
  BOOL _initialLocation;
}

+ (instancetype)controllerWithWidth:(CGFloat)width
                             height:(CGFloat)height
                             camera:(GMSCameraPosition*)camera {
  GMSMapView* mapView = [GMSMapView mapWithFrame:CGRectMake(0.0, 0.0, width, height) camera:camera];
  return [[FLTGoogleMapController alloc] initWithMapView:mapView mapId:@(_nextMapId++)];
}

- (instancetype)initWithMapView:(GMSMapView*)mapView mapId:(id)mapId {
  self = [super init];
  if (self) {
    _mapView = mapView;
    _mapId = mapId;
    _markers = [NSMutableDictionary dictionaryWithCapacity:1];
    _trackCameraPosition = NO;
      
      // enable location for partycon
      // DON'T ANYBODY DARE submit PR for this ugly try-catch sollution to google
    _initialLocation = YES;
    
    [self setupLocationManager];
  }
  return self;
}


// enable location for partycon
// DON'T ANYBODY DARE submit PR for this ugly try-catch sollution to google
- (void)setupLocationManager {
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager requestWhenInUseAuthorization];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 50.0f;
    
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    if (authStatus == kCLAuthorizationStatusAuthorizedAlways || authStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [_locationManager startUpdatingLocation];
    } else {
        // TODO: Report error.
    }
    
    _mapView.settings.myLocationButton = authStatus == kCLAuthorizationStatusAuthorizedAlways || authStatus == kCLAuthorizationStatusAuthorizedWhenInUse;
    _mapView.myLocationEnabled = authStatus == kCLAuthorizationStatusAuthorizedAlways || authStatus == kCLAuthorizationStatusAuthorizedWhenInUse;
    
}

- (void)addToView:(UIView*)view {
  _mapView.hidden = YES;
  _mapView.delegate = self;
  [view addSubview:_mapView];
}

- (void)removeFromView {
  [_mapView removeFromSuperview];
  _mapView.delegate = nil;
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

- (NSString*)addMarkerWithPosition:(CLLocationCoordinate2D)position {
  FLTGoogleMapMarkerController* markerController =
      [[FLTGoogleMapMarkerController alloc] initWithPosition:position mapView:_mapView];
  _markers[markerController.markerId] = markerController;
  return markerController.markerId;
}

- (FLTGoogleMapMarkerController*)markerWithId:(NSString*)markerId {
  return _markers[markerId];
}

- (void)removeMarkerWithId:(NSString*)markerId {
  FLTGoogleMapMarkerController* markerController = _markers[markerId];
  if (markerController) {
    [markerController setVisible:NO];
    [_markers removeObjectForKey:markerId];
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

#pragma mark - GMSMapViewDelegate methods

- (void)mapView:(GMSMapView*)mapView willMove:(BOOL)gesture {
  [_delegate onCameraMoveStartedOnMap:_mapId gesture:gesture];
}

- (void)mapView:(GMSMapView*)mapView didChangeCameraPosition:(GMSCameraPosition*)position {
  if (_trackCameraPosition) {
    [_delegate onCameraMoveOnMap:_mapId cameraPosition:position];
  }
}

- (void)mapView:(GMSMapView*)mapView idleAtCameraPosition:(GMSCameraPosition*)position {
  [_delegate onCameraIdleOnMap:_mapId];
}

- (BOOL)mapView:(GMSMapView*)mapView didTapMarker:(GMSMarker*)marker {
  NSString* markerId = marker.userData[0];
  [_delegate onMarkerTappedOnMap:_mapId marker:markerId];
  return [marker.userData[1] boolValue];
}

- (void)mapView:(GMSMapView*)mapView didTapInfoWindowOfMarker:(GMSMarker*)marker {
  NSString* markerId = marker.userData[0];
  [_delegate onInfoWindowTappedOnMap:_mapId marker:markerId];
}

// enable location for partycon
// DON'T ANYBODY DARE submit PR for this ugly try-catch sollution to google
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location error: %@", error);
}


// enable location for partycon
// DON'T ANYBODY DARE submit PR for this ugly try-catch sollution to google
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (_initialLocation) {
        _initialLocation = NO;
        CLLocation *location = [locations lastObject];
    
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude zoom:15.0f];
        [_mapView animateToCameraPosition:camera];
    }
}

@end
