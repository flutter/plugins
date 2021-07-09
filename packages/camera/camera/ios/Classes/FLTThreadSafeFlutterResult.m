//
//  FLTThreadSafeFlutterResult.m
//  camera
//
//  Created by Rene Floor on 07/07/2021.
//

#import "FLTThreadSafeFlutterResult.h"
#import <Foundation/Foundation.h>

@interface FLTThreadSafeFlutterResult ()
@property(readonly, nonatomic) FlutterResult flutterResult;
@end

@implementation FLTThreadSafeFlutterResult {
}

- (id)initWithResult:(FlutterResult)result {
  self = [super init];
  if (!self) {
    return nil;
  }
  _flutterResult = result;
  return self;
}

- (void)success {
  [self send:nil];
}

- (void)successWithData:(id)data {
  [self send:data];
}

- (void)error:(NSError*)error {
  [self errorWithCode:[NSString stringWithFormat:@"Error %d", (int)error.code]
              message:error.localizedDescription
              details:error.domain];
}

- (void)errorWithCode:(NSString*)code
              message:(NSString* _Nullable)message
              details:(id _Nullable)details {
  FlutterError* flutterError = [FlutterError errorWithCode:code message:message details:details];
  [self send:flutterError];
}

- (void)notImplemented {
  [self send:FlutterMethodNotImplemented];
}

- (void)send:(id _Nullable)result {
  if (!NSThread.isMainThread) {
    dispatch_async(dispatch_get_main_queue(), ^{
      self->_flutterResult(result);
    });
  } else {
    _flutterResult(result);
  }
}

@end
