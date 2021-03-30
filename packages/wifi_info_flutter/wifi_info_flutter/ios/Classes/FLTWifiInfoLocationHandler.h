// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FLTWifiInfoLocationDelegate;

typedef void (^FLTWifiInfoLocationCompletion)(CLAuthorizationStatus);

@interface FLTWifiInfoLocationHandler : NSObject

+ (CLAuthorizationStatus)locationAuthorizationStatus;

- (void)requestLocationAuthorization:(BOOL)always
                          completion:(_Nonnull FLTWifiInfoLocationCompletion)completionHnadler;

@end

NS_ASSUME_NONNULL_END
