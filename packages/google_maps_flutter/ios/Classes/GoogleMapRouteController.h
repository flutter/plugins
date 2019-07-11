// Copyright 2019 The HKTaxiApp Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GoogleMapController.h"
#import "GoogleMapMarkerController.h"
@class FLTGoogleMapMarkerController;

// Defines route controllable by Flutter.
@interface FLTGoogleMapRouteController : NSObject
- (instancetype)initWithMarkerController:(FLTGoogleMapMarkerController*)markerController;
- (void)remove;
- (void)addMarker:(NSDictionary*)marker;
- (void)clearMarkers;
- (NSMutableArray<NSDictionary*>*)getRoutes;
- (FLTGoogleMapMarkerController*)getMarkerController;
@end

@interface FLTRoutesController : NSObject
- (instancetype)init:(FlutterMethodChannel*)methodChannel
             mapView:(GMSMapView*)mapView
           registrar:(NSObject<FlutterPluginRegistrar>*)registrar
markerAnimationDuration:(float)markerAnimationDuration
 rotateThenTranslate:(bool)rotateThenTranslate;
- (void)routeAnimation:(FLTGoogleMapRouteController*)routeController;
- (void)addRoutes:(NSArray*)routesToAdd;
- (void)changeRoutes:(NSArray*)routesToChange;
- (void)removeRouteIds:(NSArray*)routeIdsToRemove;
- (BOOL)onMarkerTap:(NSString*)markerId;
- (void)onInfoWindowTap:(NSString*)markerId;
- (NSString*)getRouteId:(NSDictionary*)route;
- (NSArray*)getMarkers:(NSDictionary*)route;
@end
