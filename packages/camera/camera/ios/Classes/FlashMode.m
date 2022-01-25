// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FlashMode.h"

FlashMode getFlashModeForString(NSString *mode) {
  if ([mode isEqualToString:@"off"]) {
    return FlashModeOff;
  } else if ([mode isEqualToString:@"auto"]) {
    return FlashModeAuto;
  } else if ([mode isEqualToString:@"always"]) {
    return FlashModeAlways;
  } else if ([mode isEqualToString:@"torch"]) {
    return FlashModeTorch;
  } else {
    NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:NSURLErrorUnknown
                                     userInfo:@{
                                       NSLocalizedDescriptionKey : [NSString
                                           stringWithFormat:@"Unknown flash mode %@", mode]
                                     }];
    @throw error;
  }
}

AVCaptureFlashMode getAVCaptureFlashModeForFlashMode(FlashMode mode) {
  switch (mode) {
    case FlashModeOff:
      return AVCaptureFlashModeOff;
    case FlashModeAuto:
      return AVCaptureFlashModeAuto;
    case FlashModeAlways:
      return AVCaptureFlashModeOn;
    case FlashModeTorch:
    default:
      return -1;
  }
}
