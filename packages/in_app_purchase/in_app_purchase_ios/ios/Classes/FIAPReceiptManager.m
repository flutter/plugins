// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FIAPReceiptManager.h"
#import <Flutter/Flutter.h>

@implementation FIAPReceiptManager

- (NSString *)retrieveReceiptWithError:(FlutterError **)error {
  NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
  NSError *err;
  NSData *receipt = [self getReceiptData:receiptURL error:&err];
  if (err) {
    *error = [FlutterError errorWithCode:[[NSString alloc] initWithFormat:@"%li", (long)err.code]
                                 message:err.domain
                                 details:err.userInfo];
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
