// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Represents camera's exposure mode. Mirrors ExposureMode in camera.dart.
 */
typedef NS_ENUM(NSInteger, ExposureMode) {
  ExposureModeAuto,
  ExposureModeLocked,

};

/**
 * Gets a string representation of exposure mode.
 * @param mode exposure mode
 */
extern NSString *FLTGetStringForExposureMode(ExposureMode mode);

/**
 * Gets ExposureMode from its string representation.
 * @param mode a string representation of the ExposureMode.
 */
extern ExposureMode FLTGetExposureModeForString(NSString *mode);

NS_ASSUME_NONNULL_END
