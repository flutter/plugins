// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FlashMode.h"

FLTFlashMode FLTGetFLTFlashModeForString(NSString *mode) {
  if ([mode isEqualToString:@"off"]) {
    return FLTFlashModeOff;
  } else if ([mode isEqualToString:@"auto"]) {
    return FLTFlashModeAuto;
  } else if ([mode isEqualToString:@"always"]) {
    return FLTFlashModeAlways;
  } else if ([mode isEqualToString:@"torch"]) {
    return FLTFlashModeTorch;
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

AVCaptureFlashMode FLTGetAVCaptureFlashModeForFLTFlashMode(FLTFlashMode mode) {
  switch (mode) {
    case FLTFlashModeOff:
      return AVCaptureFlashModeOff;
    case FLTFlashModeAuto:
      return AVCaptureFlashModeAuto;
    case FLTFlashModeAlways:
      return AVCaptureFlashModeOn;
    case FLTFlashModeTorch:
    default:
      return -1;
  }
}
