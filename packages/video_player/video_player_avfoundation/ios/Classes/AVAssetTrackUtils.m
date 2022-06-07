// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <AVFoundation/AVFoundation.h>

CGAffineTransform FLTGetStandardizedTransformForTrack(AVAssetTrack *track) {
  CGAffineTransform t = track.preferredTransform;
  CGSize size = track.naturalSize;
  // Each case of control flows corresponds to a specific
  // `UIImageOrientation`, with 8 cases in total.
  if (t.a == 1 && t.b == 0 && t.c == 0 && t.d == 1) {
    // UIImageOrientationUp
    t.tx = 0;
    t.ty = 0;
  } else if (t.a == -1 && t.b == 0 && t.c == 0 && t.d == -1) {
    // UIImageOrientationDown
    t.tx = size.width;
    t.ty = size.height;
  } else if (t.a == 0 && t.b == -1 && t.c == 1 && t.d == 0) {
    // UIImageOrientationLeft
    t.tx = 0;
    t.ty = size.width;
  } else if (t.a == 0 && t.b == 1 && t.c == -1 && t.d == 0) {
    // UIImageOrientationRight
    t.tx = size.height;
    t.ty = 0;
  } else if (t.a == -1 && t.b == 0 && t.c == 0 && t.d == 1) {
    // UIImageOrientationUpMirrored
    t.tx = size.width;
    t.ty = 0;
  } else if (t.a == 1 && t.b == 0 && t.c == 0 && t.d == -1) {
    // UIImageOrientationDownMirrored
    t.tx = 0;
    t.ty = size.height;
  } else if (t.a == 0 && t.b == -1 && t.c == -1 && t.d == 0) {
    // UIImageOrientationLeftMirrored
    t.tx = size.height;
    t.ty = size.width;
  } else if (t.a == 0 && t.b == 1 && t.c == 1 && t.d == 0) {
    // UIImageOrientationRightMirrored
    t.tx = 0;
    t.ty = 0;
  }
  return t;
}
