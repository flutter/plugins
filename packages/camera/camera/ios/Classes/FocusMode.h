// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Represents camera's focus mode. Mirrors FocusMode in camera.dart.
 */
typedef NS_ENUM(NSInteger, FocusMode) {
  FocusModeAuto,
  FocusModeLocked,
};

/**
 * Gets a string representation from FocusMode.
 * @param mode focus mode
 */
extern NSString *FLTGetStringForFocusMode(FocusMode mode);

/**
 * Gets FocusMode from its string representation.
 * @param mode a string representation of focus mode.
 */
extern FocusMode getFocusModeForString(NSString *mode);

NS_ASSUME_NONNULL_END
