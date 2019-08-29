// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FLTConnectivityLocationDelegate;

typedef void (^FLTConnectivityLocationCompletion)(CLAuthorizationStatus);

@interface FLTConnectivityLocationHandler : NSObject

+ (CLAuthorizationStatus)locationAuthorizationStatus;

- (void)requestLocationAuthorization:(BOOL)always
                          completion:(_Nonnull FLTConnectivityLocationCompletion)completionHnadler;

@end

NS_ASSUME_NONNULL_END
