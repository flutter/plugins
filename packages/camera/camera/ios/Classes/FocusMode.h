// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Mirrors FocusMode in camera.dart
typedef enum {
  FocusModeAuto,
  FocusModeLocked,
} FocusMode;

extern NSString *getStringForFocusMode(FocusMode mode);

extern FocusMode getFocusModeForString(NSString *mode);

NS_ASSUME_NONNULL_END
