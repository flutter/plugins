// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ExposureMode.h"

NSString *FLTGetStringForExposureMode(ExposureMode mode) {
  switch (mode) {
    case ExposureModeAuto:
      return @"auto";
    case ExposureModeLocked:
      return @"locked";
  }
  NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                       code:NSURLErrorUnknown
                                   userInfo:@{
                                     NSLocalizedDescriptionKey : [NSString
                                         stringWithFormat:@"Unknown string for exposure mode"]
                                   }];
  @throw error;
}

ExposureMode FLTGetExposureModeForString(NSString *mode) {
  if ([mode isEqualToString:@"auto"]) {
    return ExposureModeAuto;
  } else if ([mode isEqualToString:@"locked"]) {
    return ExposureModeLocked;
  } else {
    NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:NSURLErrorUnknown
                                     userInfo:@{
                                       NSLocalizedDescriptionKey : [NSString
                                           stringWithFormat:@"Unknown exposure mode %@", mode]
                                     }];
    @throw error;
  }
}

