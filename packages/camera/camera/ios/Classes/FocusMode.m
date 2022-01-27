// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FocusMode.h"


NSString *FLTGetStringForFLTFocusMode(FLTFocusMode mode) {
  switch (mode) {
    case FLTFocusModeAuto:
      return @"auto";
    case FLTFocusModeLocked:
      return @"locked";
  }
  NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                       code:NSURLErrorUnknown
                                   userInfo:@{
                                     NSLocalizedDescriptionKey : [NSString
                                         stringWithFormat:@"Unknown string for focus mode"]
                                   }];
  @throw error;
}

FLTFocusMode getFLTFocusModeForString(NSString *mode) {
  if ([mode isEqualToString:@"auto"]) {
    return FLTFocusModeAuto;
  } else if ([mode isEqualToString:@"locked"]) {
    return FLTFocusModeLocked;
  } else {
    NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:NSURLErrorUnknown
                                     userInfo:@{
                                       NSLocalizedDescriptionKey : [NSString
                                           stringWithFormat:@"Unknown focus mode %@", mode]
                                     }];
    @throw error;
  }
}

