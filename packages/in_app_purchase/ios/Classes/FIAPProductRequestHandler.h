// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FIAPProductRequestHandlerDelegate;

typedef void (^ProductRequestCompletion)(SKProductsResponse *_Nullable response);

@interface FIAPProductRequestHandler : NSObject

@property(nullable, weak, nonatomic) NSObject<FIAPProductRequestHandlerDelegate> *delegate;

- (instancetype)initWithProductRequest:(SKProductsRequest *)request;
- (void)startWithCompletionHandler:(ProductRequestCompletion)completion;

NS_ASSUME_NONNULL_END

#pragma mark - categories

@end

#pragma mark - delegate

@protocol FIAPProductRequestHandlerDelegate <NSObject>

- (void)productRequestHandlerDidFinish:(nonnull FIAPProductRequestHandler *)handler;

@end
