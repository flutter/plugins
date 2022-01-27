// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Mirrors ExposureMode in camera.dart
typedef enum {
  ExposureModeAuto,
  ExposureModeLocked,

} ExposureMode;

extern NSString *getStringForExposureMode(ExposureMode mode);
extern ExposureMode getExposureModeForString(NSString *mode);

NS_ASSUME_NONNULL_END
