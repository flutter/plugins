// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "VideoFormat.h"

OSType getVideoFormatFromString(NSString *videoFormatString) {
  if ([videoFormatString isEqualToString:@"bgra8888"]) {
    return kCVPixelFormatType_32BGRA;
  } else if ([videoFormatString isEqualToString:@"yuv420"]) {
    return kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange;
  } else {
    NSLog(@"The selected imageFormatGroup is not supported by iOS. Defaulting to brga8888");
    return kCVPixelFormatType_32BGRA;
  }
}

