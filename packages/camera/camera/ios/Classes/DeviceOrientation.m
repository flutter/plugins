// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "DeviceOrientation.h"


UIDeviceOrientation getUIDeviceOrientationForString(NSString *orientation) {
  if ([orientation isEqualToString:@"portraitDown"]) {
    return UIDeviceOrientationPortraitUpsideDown;
  } else if ([orientation isEqualToString:@"landscapeLeft"]) {
    return UIDeviceOrientationLandscapeRight;
  } else if ([orientation isEqualToString:@"landscapeRight"]) {
    return UIDeviceOrientationLandscapeLeft;
  } else if ([orientation isEqualToString:@"portraitUp"]) {
    return UIDeviceOrientationPortrait;
  } else {
    NSError *error = [NSError
        errorWithDomain:NSCocoaErrorDomain
                   code:NSURLErrorUnknown
               userInfo:@{
                 NSLocalizedDescriptionKey :
                     [NSString stringWithFormat:@"Unknown device orientation %@", orientation]
               }];
    @throw error;
  }
}


NSString *getStringForUIDeviceOrientation(UIDeviceOrientation orientation) {
  switch (orientation) {
    case UIDeviceOrientationPortraitUpsideDown:
      return @"portraitDown";
    case UIDeviceOrientationLandscapeRight:
      return @"landscapeLeft";
    case UIDeviceOrientationLandscapeLeft:
      return @"landscapeRight";
    case UIDeviceOrientationPortrait:
    default:
      return @"portraitUp";
      break;
  };
}
