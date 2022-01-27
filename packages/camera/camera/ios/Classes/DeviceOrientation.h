// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Gets UIDeviceOrientation from its string representation.
 */
extern UIDeviceOrientation FLTGetUIDeviceOrientationForString(NSString *orientation);

/**
 * Gets a string representation of UIDeviceOrientation.
 */
extern NSString *FLTGetStringForUIDeviceOrientation(UIDeviceOrientation orientation);

NS_ASSUME_NONNULL_END
