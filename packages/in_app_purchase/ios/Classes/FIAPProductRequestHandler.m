// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FIAPProductRequestHandler.h"
#import <StoreKit/StoreKit.h>

#pragma mark - Main Handler

@interface FIAPProductRequestHandler () <SKProductsRequestDelegate>

@property(copy, nonatomic) ProductRequestCompletion completion;
@property(strong, nonatomic) NSMutableSet *delegateObjects;
@property(strong, nonatomic) SKProductsRequest *request;

@end

@implementation FIAPProductRequestHandler

- (instancetype)initWithProductRequest:(SKProductsRequest *)request {
  self = [super init];
  if (self) {
    self.request = request;
    request.delegate = self;
  }
  return self;
}

- (void)startWithCompletionHandler:(ProductRequestCompletion)completion {
  self.completion = completion;
  [self.request start];
}

- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response {
  if (self.completion) {
    self.completion(response);
  }
  [self.delegate productRequestHandlerDidFinish:self];
}

@end
