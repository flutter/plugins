// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SKProduct (Coder)

- (nullable NSDictionary *)toMap;

@end

@interface SKProductSubscriptionPeriod (Coder)

- (nullable NSDictionary *)toMap;

@end

@interface SKProductDiscount (Coder)

- (nullable NSDictionary *)toMap;

@end

@interface SKProductsResponse (Coder)

- (nullable NSDictionary *)toMap;

@end

NS_ASSUME_NONNULL_END
