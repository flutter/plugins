// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

//
//  FIAPReceiptManager.m
//  in_app_purchase
//
//  Created by Chris Yang on 3/2/19.
//

#import "FIAPReceiptManager.h"
#import <Flutter/Flutter.h>

@implementation FIAPReceiptManager

- (NSString *)retrieveReceiptWithError:(FlutterError **)error {
  NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
  NSError *err;
  NSData *receipt = [self getReceiptData:receiptURL error:&err];
  if (error) {
    *error = [FlutterError errorWithCode:[[NSString alloc] initWithFormat:@"%li", err.code];
                                 message:error.domain details:err.userInfo];
    return nil;
  }
  if (!receipt) {
    return nil;
  }
  return [receipt base64EncodedStringWithOptions:kNilOptions];
}

- (NSData *)getReceiptData:(NSURL *)url error:(NSError **)error {
  return [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:error];
}

@end
