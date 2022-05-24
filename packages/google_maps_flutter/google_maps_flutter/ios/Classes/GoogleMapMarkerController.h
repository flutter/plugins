// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GoogleMapController.h"

NS_ASSUME_NONNULL_BEGIN

// Defines marker UI options writable from Flutter.
@protocol FLTGoogleMapMarkerOptionsSink
- (void)setAlpha:(float)alpha;
- (void)setAnchor:(CGPoint)anchor;
- (void)setConsumeTapEvents:(BOOL)consume;
- (void)setDraggable:(BOOL)draggable;
- (void)setFlat:(BOOL)flat;
- (void)setIcon:(UIImage *)icon;
- (void)setInfoWindowAnchor:(CGPoint)anchor;
- (void)setInfoWindowTitle:(NSString *)title snippet:(NSString *)snippet;
- (void)setPosition:(CLLocationCoordinate2D)position;
- (void)setRotation:(CLLocationDegrees)rotation;
- (void)setVisible:(BOOL)visible;
- (void)setZIndex:(int)zIndex;
@end

// Defines marker controllable by Flutter.
@interface FLTGoogleMapMarkerController : NSObject <FLTGoogleMapMarkerOptionsSink>
@property(assign, nonatomic, readonly) BOOL consumeTapEvents;
- (instancetype)initMarkerWithPosition:(CLLocationCoordinate2D)position
                            identifier:(NSString *)identifier
                               mapView:(GMSMapView *)mapView;
- (void)showInfoWindow;
- (void)hideInfoWindow;
- (BOOL)isInfoWindowShown;
- (void)removeMarker;
@end

@interface FLTMarkersController : NSObject
- (instancetype)initWithMethodChannel:(FlutterMethodChannel *)methodChannel
                              mapView:(GMSMapView *)mapView
                            registrar:(NSObject<FlutterPluginRegistrar> *)registrar;
- (void)addMarkers:(NSArray *)markersToAdd;
- (void)changeMarkers:(NSArray *)markersToChange;
- (void)removeMarkersWithIdentifiers:(NSArray *)identifiers;
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
