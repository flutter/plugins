// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FIAPReceiptManager.h"
#import <Flutter/Flutter.h>
#import "FIAObjectTranslator.h"

@interface FIAPReceiptManager ()
// Gets the receipt file data from the location of the url. Can be nil if
// there is an error. This interface is defined so it can be stubbed for testing.
- (NSData *)getReceiptData:(NSURL *)url error:(NSError **)error;

@end

@implementation FIAPReceiptManager

- (NSString *)retrieveReceiptWithError:(FlutterError **)flutterError {
  NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
  NSError *receiptError;
  NSData *receipt = [self getReceiptData:receiptURL error:&receiptError];
  if (!receipt || receiptError) {
    if (flutterError) {
      NSDictionary *errorMap = [FIAObjectTranslator getMapFromNSError:receiptError];
      *flutterError = [FlutterError errorWithCode:errorMap[@"code"]
                                          message:errorMap[@"domain"]
                                          details:errorMap[@"userInfo"]];
    }
    return nil;
  }
  return [receipt base64EncodedStringWithOptions:kNilOptions];
}

- (NSData *)getReceiptData:(NSURL *)url error:(NSError **)error {
  return [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:error];
}

@end
