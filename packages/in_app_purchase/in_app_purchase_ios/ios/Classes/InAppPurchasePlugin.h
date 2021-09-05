// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif
@class FIAPaymentQueueHandler;
@class FIAPReceiptManager;

@interface InAppPurchasePlugin : NSObject <FlutterPlugin>

@property(strong, nonatomic) FIAPaymentQueueHandler *paymentQueueHandler;

- (instancetype)initWithReceiptManager:(FIAPReceiptManager *)receiptManager
    NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end
