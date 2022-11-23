// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>
#import "ClusterManagersController.h"
#import "GoogleMapController.h"

NS_ASSUME_NONNULL_BEGIN

// Defines marker controllable by Flutter.
@interface FLTGoogleMapMarkerController : NSObject
@property(assign, nonatomic, readonly) BOOL consumeTapEvents;
- (instancetype)initWithMarker:(GMSMarker *)marker
                    identifier:(NSString *)identifier
              clusterManagerId:(NSString *)identifier
                       mapView:(GMSMapView *)mapView;
- (void)showInfoWindow;
- (void)hideInfoWindow;
- (BOOL)isInfoWindowShown;
- (void)removeMarker;
@end

@interface FLTMarkersController : NSObject
- (instancetype)initWithClusterManagersController:(FLTClusterManagersController *)clusterManagers
                                          channel:(FlutterMethodChannel *)channel
                                          mapView:(GMSMapView *)mapView
                                        registrar:(NSObject<FlutterPluginRegistrar> *)registrar;
- (void)addMarkers:(NSArray *)markersToAdd;
- (void)addMarker:(NSDictionary *)markerToAdd;
- (void)changeMarkers:(NSArray *)markersToChange;
- (void)changeMarker:(NSDictionary *)markerToChange;
- (void)removeMarkersWithIdentifiers:(NSArray *)identifiers;
- (void)removeMarker:(NSString *)identifier;
- (BOOL)didTapMarkerWithIdentifier:(NSString *)identifier;
- (void)didStartDraggingMarkerWithIdentifier:(NSString *)identifier
                                    location:(CLLocationCoordinate2D)coordinate;
- (void)didEndDraggingMarkerWithIdentifier:(NSString *)identifier
                                  location:(CLLocationCoordinate2D)coordinate;
- (void)didDragMarkerWithIdentifier:(NSString *)identifier
                           location:(CLLocationCoordinate2D)coordinate;
- (void)didTapInfoWindowOfMarkerWithIdentifier:(NSString *)identifier;
- (void)showMarkerInfoWindowWithIdentifier:(NSString *)identifier result:(FlutterResult)result;
- (void)hideMarkerInfoWindowWithIdentifier:(NSString *)identifier result:(FlutterResult)result;
- (void)isInfoWindowShownForMarkerWithIdentifier:(NSString *)identifier
                                          result:(FlutterResult)result;
@end

NS_ASSUME_NONNULL_END
