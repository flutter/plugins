//
//  FIAPReceiptManager.m
//  in_app_purchase
//
//  Created by Chris Yang on 3/2/19.
//

#import "FIAPReceiptManager.h"
#import <Flutter/Flutter.h>

@implementation FIAPReceiptManager

- (NSDictionary *)retrieveReceipt:(BOOL)serialized error:(FlutterError **)error {
  NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
  NSData *receipt = [self getReceiptData:receiptURL];
  if (!receipt) {
    *error = [FlutterError errorWithCode:@"storekit_no_receipt"
                                 message:@"Cannot find receipt for the current main bundle."
                                 details:nil];
    return nil;
  }
  NSDictionary *returnMap;
  if (serialized) {
    NSError *nsError = nil;
    returnMap = [NSJSONSerialization JSONObjectWithData:receipt options:kNilOptions error:&nsError];
    if (error) {
      *error = [FlutterError errorWithCode:@"storekit_retrieve_receipt_json_serialization_error"
                                   message:nsError.domain
                                   details:nsError.userInfo];
      return nil;
    }
    return returnMap;
  } else {
    return @{@"base64data" : [receipt base64EncodedStringWithOptions:kNilOptions]};
  }
}

- (NSData *)getReceiptData:(NSURL *)url {
  return [NSData dataWithContentsOfURL:url];
}

@end
