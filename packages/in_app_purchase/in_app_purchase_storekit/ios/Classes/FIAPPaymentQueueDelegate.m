// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FIAPPaymentQueueDelegate.h"
#import "FIAObjectTranslator.h"

@interface FIAPPaymentQueueDelegate ()

@property(strong, nonatomic, readonly) FlutterMethodChannel *callbackChannel;

@end

@implementation FIAPPaymentQueueDelegate

- (id)initWithMethodChannel:(FlutterMethodChannel *)methodChannel {
  self = [super init];
  if (self) {
    _callbackChannel = methodChannel;
  }

  return self;
}

- (BOOL)paymentQueue:(SKPaymentQueue *)paymentQueue
    shouldContinueTransaction:(SKPaymentTransaction *)transaction
                 inStorefront:(SKStorefront *)newStorefront {
  // Default return value for this method is true (see
  // https://developer.apple.com/documentation/storekit/skpaymentqueuedelegate/3521328-paymentqueueshouldshowpriceconse?language=objc)
  __block BOOL shouldContinue = YES;
  dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
  [self.callbackChannel invokeMethod:@"shouldContinueTransaction"
                           arguments:[FIAObjectTranslator getMapFromSKStorefront:newStorefront
                                                         andSKPaymentTransaction:transaction]
                              result:^(id _Nullable result) {
                                // When result is a valid instance of NSNumber use it to determine
                                // if the transaction should continue. Otherwise use the default
                                // value.
                                if (result && [result isKindOfClass:[NSNumber class]]) {
                                  shouldContinue = [(NSNumber *)result boolValue];
                                }

                                dispatch_semaphore_signal(semaphore);
                              }];

  // The client should respond within 1 second otherwise continue
  // with default value.
  dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC));

  return shouldContinue;
}

- (BOOL)paymentQueueShouldShowPriceConsent:(SKPaymentQueue *)paymentQueue {
  // Default return value for this method is true (see
  // https://developer.apple.com/documentation/storekit/skpaymentqueuedelegate/3521328-paymentqueueshouldshowpriceconse?language=objc)
  __block BOOL shouldShowPriceConsent = YES;
  dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
  [self.callbackChannel invokeMethod:@"shouldShowPriceConsent"
                           arguments:nil
                              result:^(id _Nullable result) {
                                // When result is a valid instance of NSNumber use it to determine
                                // if the transaction should continue. Otherwise use the default
                                // value.
                                if (result && [result isKindOfClass:[NSNumber class]]) {
                                  shouldShowPriceConsent = [(NSNumber *)result boolValue];
                                }

                                dispatch_semaphore_signal(semaphore);
                              }];

  // The client should respond within 1 second otherwise continue
  // with default value.
  dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC));

  return shouldShowPriceConsent;
}

@end
