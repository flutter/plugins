// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import GoogleMaps;

/**
 * Defines a map view used for testing key-value observing.
 */
@interface PartiallyMockedMapView : GMSMapView

/**
 * The number of times that the `frame` KVO has been added.
 */
@property(nonatomic, assign, readonly) NSInteger frameObserverCount;

@end
