// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <Google-Maps-iOS-Utils/GMUClusterAlgorithm.h>
#import <Google-Maps-iOS-Utils/GMUClusterIconGenerator.h>
#import <Google-Maps-iOS-Utils/GMUClusterManager.h>
#import <Google-Maps-iOS-Utils/GMUClusterRenderer.h>
#import <Google-Maps-iOS-Utils/GMUDefaultClusterIconGenerator.h>
#import <Google-Maps-iOS-Utils/GMUDefaultClusterRenderer.h>
#import <Google-Maps-iOS-Utils/GMUGridBasedClusterAlgorithm.h>
#import <Google-Maps-iOS-Utils/GMUNonHierarchicalDistanceBasedAlgorithm.h>
#import <Google-Maps-iOS-Utils/GMUSimpleClusterAlgorithm.h>
#import <Google-Maps-iOS-Utils/GMUStaticCluster.h>
#import <GoogleMaps/GoogleMaps.h>

NS_ASSUME_NONNULL_BEGIN

// Defines cluster managers controller.
@interface FLTClusterManagersController : NSObject

/**
 * Initializes FLTClusterManagersController.
 *
 * @param methodChannel A Flutter method channel used to send events.
 * @param mapView A map view that will be used to display clustered markers.
 */
- (instancetype)init:(FlutterMethodChannel *)methodChannel mapView:(GMSMapView *)mapView;

/**
 * Creates ClusterManagers and initializes them.
 *
 * @param clusterManagersToAdd List of clustermanager object data.
 */
- (void)addClusterManagers:(NSArray *)clusterManagersToAdd;

/**
 * Removes requested ClusterManagers from the controller.
 *
 * @param identifiers List of clusterManagerIds to remove.
 */
- (void)removeClusterManagers:(NSArray *)identifiers;

/**
 * Adds marker to specific ClusterManager.
 *
 * @param marker GMSMArker object to be added to the ClusterManager.
 * @param clusterManagerId identifier of the ClusterManager.
 */
- (void)addItem:(GMSMarker *)marker clusterManagerId:(NSString *)clusterManagerId;

/**
 * Removes marker from specific ClusterManager.
 *
 * @param marker GMSMArker object to be removed from the ClusterManager.
 * @param clusterManagerId identifier of the ClusterManager.
 */
- (void)removeItem:(GMSMarker *)marker clusterManagerId:(NSString *)clusterManagerId;

/**
 * Converts all clusters from the specific ClusterManager to result object response.
 *
 * @param identifier identifier of the ClusterManager.
 * @param result FlutterResult object to be updated with cluster data.
 */
- (void)getClustersWithIdentifier:(NSString *)identifier result:(FlutterResult)result;

/**
 * Called when cluster marker is tapped on the map.
 *
 * @param cluster GMUStaticCluster object.
 */
- (bool)didTapCluster:(GMUStaticCluster *)cluster;

// Calls cluster method of all ClusterManagers.
- (void)clusterAll;
@end

NS_ASSUME_NONNULL_END
