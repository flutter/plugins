// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ExposureMode.h"

NSString *FLTGetStringForFLTExposureMode(FLTExposureMode mode) {
  switch (mode) {
    case FLTExposureModeAuto:
      return @"auto";
    case FLTExposureModeLocked:
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

FLTExposureMode FLTGetFLTExposureModeForString(NSString *mode) {
  if ([mode isEqualToString:@"auto"]) {
    return FLTExposureModeAuto;
  } else if ([mode isEqualToString:@"locked"]) {
    return FLTExposureModeLocked;
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

