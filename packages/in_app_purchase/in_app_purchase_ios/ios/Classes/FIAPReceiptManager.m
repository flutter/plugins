// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FIAPReceiptManager.h"
#import <Flutter/Flutter.h>

@interface FIAPReceiptManager ()

- (NSData *)getReceiptData:(NSURL *)url error:(NSError **)error;

@end

@implementation FIAPReceiptManager

- (NSString *)retrieveReceiptWithError:(FlutterError **)flutterError {
  NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
  NSError *receiptError;
  NSData *receipt = [self getReceiptData:receiptURL error:&receiptError];
  if (receiptError) {
    if (flutterError != nil) {
      *flutterError = [FlutterError
          errorWithCode:[[NSString alloc] initWithFormat:@"%li", (long)receiptError.code]
                message:receiptError.domain
                details:receiptError.userInfo];
    }
    return nil;
  }
  if (!receipt) {
    if (flutterError != nil) {
      *flutterError = [FlutterError errorWithCode:@"0"
                                          message:@"dataWithContentsOfURL returned nil without an "
                                                  @"error in retrieveReceiptWithError"
                                          details:nil];
    }
    return nil;
  }
  return [receipt base64EncodedStringWithOptions:kNilOptions];
}

- (NSData *)getReceiptData:(NSURL *)url error:(NSError **)error {
  return [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:error];
}

@end
