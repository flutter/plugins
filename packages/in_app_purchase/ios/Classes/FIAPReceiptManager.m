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
  NSError *error;
  NSData *receipt = [self getReceiptData:receiptURL error:&error];
  if (!receipt) {
    return nil;
  }
  if (error) {
    *error = [FlutterError errorWithCode:[[NSString alloc] initWithFormat:@"%li", error.code];
                                 message:error.domain details:error.userInfo];
    return nil;
  }
  return [receipt base64EncodedStringWithOptions:kNilOptions];
}

- (NSData *)getReceiptData:(NSURL *)url error:(NSError **)error {
  return [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:error];
}

@end
