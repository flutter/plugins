// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FIAPRequestHandler.h"
#import <StoreKit/StoreKit.h>

#pragma mark - Main Handler

@interface FIAPRequestHandler () <SKProductsRequestDelegate>

@property(copy, nonatomic) ProductRequestCompletion completion;
@property(strong, nonatomic) SKProductsRequest *request;

@end

@implementation FIAPRequestHandler

- (instancetype)initWithRequest:(SKProductsRequest *)request {
  self = [super init];
  if (self) {
    self.request = request;
    request.delegate = self;
  }
  return self;
}

- (void)startProductRequestWithCompletionHandler:(ProductRequestCompletion)completion {
  self.completion = completion;
  [self.request start];
}

- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response {
  if (self.completion) {
    self.completion(response, nil);
  }
}

// Reserved for other SKRequests.
- (void)requestDidFinish:(SKRequest *)request {
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
  if (self.completion) {
    self.completion(nil, error);
  }
}

@end
