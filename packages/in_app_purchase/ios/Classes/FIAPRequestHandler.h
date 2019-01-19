// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FIAPRequestHandlerDelegate;

typedef void (^ProductRequestCompletion)(SKProductsResponse *_Nullable response,
                                         NSError *_Nullable errror);

@interface FIAPRequestHandler : NSObject

@property(nullable, weak, nonatomic) NSObject<FIAPRequestHandlerDelegate> *delegate;

- (instancetype)initWithRequest:(SKProductsRequest *)request;
- (void)startProductRequestWithCompletionHandler:(ProductRequestCompletion)completion;

NS_ASSUME_NONNULL_END

#pragma mark - categories

@end

#pragma mark - delegate

@protocol FIAPRequestHandlerDelegate <NSObject>

- (void)requestHandlerDidFinish:(nonnull FIAPRequestHandler *)handler;

@end
