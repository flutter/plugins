// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FlutterError;

@interface FIAPReceiptManager : NSObject

- (NSString *)retrieveReceiptWithError:(FlutterError **)error;

@end

NS_ASSUME_NONNULL_END
