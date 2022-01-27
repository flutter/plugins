// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ResolutionPreset.h"

FLTResolutionPreset FLTGetFLTResolutionPresetForString(NSString *preset) {
  if ([preset isEqualToString:@"veryLow"]) {
    return FLTResolutionPresetVeryLow;
  } else if ([preset isEqualToString:@"low"]) {
    return FLTResolutionPresetLow;
  } else if ([preset isEqualToString:@"medium"]) {
    return FLTResolutionPresetMedium;
  } else if ([preset isEqualToString:@"high"]) {
    return FLTResolutionPresetHigh;
  } else if ([preset isEqualToString:@"veryHigh"]) {
    return FLTResolutionPresetVeryHigh;
  } else if ([preset isEqualToString:@"ultraHigh"]) {
    return FLTResolutionPresetUltraHigh;
  } else if ([preset isEqualToString:@"max"]) {
    return FLTResolutionPresetMax;
  } else {
    NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:NSURLErrorUnknown
                                     userInfo:@{
                                       NSLocalizedDescriptionKey : [NSString
                                           stringWithFormat:@"Unknown resolution preset %@", preset]
                                     }];
    @throw error;
  }
}
