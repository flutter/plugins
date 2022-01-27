// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Represents camera's resolution present. Mirrors ResolutionPreset in camera.dart.
 */
typedef NS_ENUM(NSInteger, FLTResolutionPreset) {
  FLTResolutionPresetVeryLow,
  FLTResolutionPresetLow,
  FLTResolutionPresetMedium,
  FLTResolutionPresetHigh,
  FLTResolutionPresetVeryHigh,
  FLTResolutionPresetUltraHigh,
  FLTResolutionPresetMax,
};

/**
 * Gets FLTResolutionPreset from its string representation.
 * @param preset a string representation of FLTResolutionPreset.
 */
extern FLTResolutionPreset FLTGetFLTResolutionPresetForString(NSString *preset);

NS_ASSUME_NONNULL_END
