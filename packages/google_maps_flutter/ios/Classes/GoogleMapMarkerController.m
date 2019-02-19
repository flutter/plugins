// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapMarkerController.h"
#import "JsonConversions.h"

@implementation FLTGoogleMapMarkerController {
  GMSMarker* _marker;
  GMSMapView* _mapView;
  BOOL _consumeTapEvents;
}
- (instancetype)initWithPositionAndId:(CLLocationCoordinate2D)position
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
        image = [UIImage imageNamed:[registrar lookupKeyForAsset:iconData[1]
                                                     fromPackage:iconData[2]]];
      }
    }
    [sink setIcon:image];
  }
  id flat = data[@"flat"];
  if (flat) {
    [sink setFlat:toBool(flat)];
  }
  id consumeTapEvents = data[@"consumeTapEvents"];
  if (consumeTapEvents) {
    [sink setConsumeTapEvents:toBool(consumeTapEvents)];
  }
  id infoWindow = data[@"infoWindow"];
  if (infoWindow) {
    NSString* title = infoWindow[@"title"];
    NSString* snippet = infoWindow[@"snippet"];
    if (title) {
      [sink setInfoWindowTitle:title snippet:snippet];
    }
    id infoWindowAnchor = infoWindow[@"infoWindowAnchor"];
    if (infoWindowAnchor) {
      [sink setInfoWindowAnchor:toPoint(infoWindowAnchor)];
    }
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

@implementation FLTMarkersController {
  NSMutableDictionary* _markerIdToController;
  FlutterMethodChannel* _methodChannel;
  NSObject<FlutterPluginRegistrar>* _registrar;
  GMSMapView* _mapView;
}
- (instancetype)init:(FlutterMethodChannel*)methodChannel mapView:(GMSMapView*)mapView {
  self = [super init];
  if (self) {
    _methodChannel = methodChannel;
    _mapView = mapView;
    _markerIdToController = [NSMutableDictionary dictionaryWithCapacity:1];
  }
  return self;
}
- (void)addMarkers:(id)markersToAdd {
  NSArray<id>* markers = markersToAdd;
  if (!markers) {
    return;
  }
  for (id marker in markers) {
    if (!marker) {
      continue;
    }
    CLLocationCoordinate2D position = [FLTMarkersController getPosition:marker];
    NSString* markerId = [FLTMarkersController getMarkerId:marker];
    FLTGoogleMapMarkerController* controller =
        [[FLTGoogleMapMarkerController alloc] initWithPositionAndId:position
                                                           markerId:markerId
                                                            mapView:_mapView];
    interpretMarkerOptions(marker, controller, _registrar);
    _markerIdToController[markerId] = controller;
  }
}
- (void)changeMarkers:(id)markersToChange {
  NSArray<id>* markers = markersToChange;
  if (!markers) {
    return;
  }
  for (id marker in markers) {
    if (!marker) {
      continue;
    }
    NSString* markerId = [FLTMarkersController getMarkerId:marker];
    FLTGoogleMapMarkerController* controller = _markerIdToController[markerId];
    if (!controller) {
      continue;
    }
    interpretMarkerOptions(marker, controller, _registrar);
  }
}
- (void)removeMarkerIds:(id)markerIdsToRemove {
  NSArray<id>* markerIds = markerIdsToRemove;
  if (!markerIds) {
    return;
  }
  for (id markerId in markerIds) {
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

+ (CLLocationCoordinate2D)getPosition:(id)rawMarker {
  NSDictionary* marker = rawMarker;
  id position = marker[@"position"];
  return toLocation(position);
}
+ (NSString*)getMarkerId:(id)rawMarker {
  NSDictionary* marker = rawMarker;
  return marker[@"markerId"];
}
@end
