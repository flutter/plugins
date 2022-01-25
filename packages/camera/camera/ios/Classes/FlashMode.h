// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Represents camera's flash mode. Mirrors `FlashMode` enum in flash_mode.dart.
 */
typedef enum {
  FlashModeOff,
  FlashModeAuto,
  FlashModeAlways,
  FlashModeTorch,
} FlashMode;

/**
 * Gets FlashMode from its string representation.
 * @param mode a string representation of the FlashMode.
 */
FlashMode getFlashModeForString(NSString *mode);

/**
 * Gets AVCaptureFlashMode from FlashMode.
 * @param mode flash mode.
 */
AVCaptureFlashMode getAVCaptureFlashModeForFlashMode(FlashMode mode);

NS_ASSUME_NONNULL_END
