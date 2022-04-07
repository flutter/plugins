// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVAssetTrack (Utils)

/**
 * Note: https://stackoverflow.com/questions/64161544
 * `AVAssetTrack.preferredTransform` can have wrong `tx` and `ty`
 * on iOS 14 and above. This method provide a corrected transform
 * according to the orientation state of the track.
 */
- (CGAffineTransform)fixTransform;

@end

NS_ASSUME_NONNULL_END
