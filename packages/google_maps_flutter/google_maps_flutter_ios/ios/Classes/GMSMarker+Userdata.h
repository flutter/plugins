// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <GoogleMaps/GoogleMaps.h>

NS_ASSUME_NONNULL_BEGIN

@interface GMSMarker (Userdata)

/**
 * Sets MarkerId to GMSMarker UserData.
 *
 * @param markerId Id of marker.
 */
- (void)setMarkerId:(NSString *)markerId;

/**
 * Sets MarkerId and ClusterManagerId to GMSMarker UserData.
 *
 * @param markerId Id of marker.
 * @param clusterManagerId Id of cluster manager.
 */
- (void)setMarkerID:(NSString *)markerId andClusterManagerId:(NSString *)clusterManagerId;

/**
 * Get MarkerId from GMSMarker UserData.
 *
 * @return NSString if found otherwise nil.
 */
- (NSString *)getMarkerId;

/**
 * Get ClusterManagerId from GMSMarker UserData.
 *
 * @return NSString if found otherwise nil.
 */
- (NSString *)getClusterManagerId;

@end

NS_ASSUME_NONNULL_END
