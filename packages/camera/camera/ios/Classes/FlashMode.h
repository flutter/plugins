// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Represents camera's flash mode. Mirrors `FlashMode` enum in flash_mode.dart.
 */
typedef NS_ENUM(NSInteger, FLTFlashMode) {
  FLTFlashModeOff,
  FLTFlashModeAuto,
  FLTFlashModeAlways,
  FLTFlashModeTorch,
};

/**
 * Gets FLTFlashMode from its string representation.
 * @param mode a string representation of the FLTFlashMode.
 */
extern FLTFlashMode FLTGetFLTFlashModeForString(NSString *mode);

/**
 * Gets AVCaptureFlashMode from FLTFlashMode.
 * @param mode flash mode.
 */
extern AVCaptureFlashMode FLTGetAVCaptureFlashModeForFLTFlashMode(FLTFlashMode mode);

NS_ASSUME_NONNULL_END
