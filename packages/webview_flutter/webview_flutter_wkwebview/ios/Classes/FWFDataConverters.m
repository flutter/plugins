// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFDataConverters.h"

#import <Flutter/Flutter.h>

NSURLRequest *_Nullable FWFNSURLRequestFromRequestData(FWFNSUrlRequestData *data) {
  NSURL *url = [NSURL URLWithString:data.url];
  if (!url) {
    return nil;
  }

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  if (!request) {
    return nil;
  }

  [request setHTTPMethod:data.httpMethod];
  [request setHTTPBody:data.httpBody.data];
  [request setAllHTTPHeaderFields:data.allHttpHeaderFields];

  return request;
}
