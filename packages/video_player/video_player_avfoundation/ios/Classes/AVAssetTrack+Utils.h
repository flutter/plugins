// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

// Fix the transform for the track.
// Each fix case corresponding to `UIImage.Orientation`, with 8 cases in total.
@interface AVAssetTrack (Utils)
- (CGAffineTransform)fixTransform;
@end

NS_ASSUME_NONNULL_END
