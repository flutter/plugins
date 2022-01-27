// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FocusMode.h"


NSString *getStringForFocusMode(FocusMode mode) {
  switch (mode) {
    case FocusModeAuto:
      return @"auto";
    case FocusModeLocked:
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

FocusMode getFocusModeForString(NSString *mode) {
  if ([mode isEqualToString:@"auto"]) {
    return FocusModeAuto;
  } else if ([mode isEqualToString:@"locked"]) {
    return FocusModeLocked;
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

