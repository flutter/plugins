// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import GoogleMaps;

NS_ASSUME_NONNULL_BEGIN

@interface MockGMSMapView : GMSMapView

@property(nonatomic, assign) NSInteger frameObserverCount;

@end

NS_ASSUME_NONNULL_END
