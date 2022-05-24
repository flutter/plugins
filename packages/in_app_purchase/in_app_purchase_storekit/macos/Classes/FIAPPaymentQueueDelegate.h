// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(ios(13),macos(10.15))
@interface FIAPPaymentQueueDelegate : NSObject <SKPaymentQueueDelegate>
- (id)initWithMethodChannel:(FlutterMethodChannel *)methodChannel;
@end

NS_ASSUME_NONNULL_END
