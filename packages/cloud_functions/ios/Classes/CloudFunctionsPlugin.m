// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "CloudFunctionsPlugin.h"

#import "FIRFunctions+Internal.h"
#import "Firebase/Firebase.h"

@interface CloudFunctionsPlugin ()
@property(nonatomic, retain) FlutterMethodChannel *_channel;
@end

@implementation CloudFunctionsPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"cloud_functions"
                                  binaryMessenger:[registrar messenger]];
  CloudFunctionsPlugin *instance = [[CloudFunctionsPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    if (![FIRApp defaultApp]) {
      [FIRApp configure];
    }
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"CloudFunctions#call" isEqualToString:call.method]) {
    NSString *functionName = call.arguments[@"functionName"];
    NSObject *parameters = call.arguments[@"parameters"];
    [[FIRFunctions functions]
        callFunction:functionName
          withObject:parameters
          completion:^(FIRHTTPSCallableResult *callableResult, NSError *error) {
            if (error) {
              FlutterError *flutterError;
              if (error.domain == FIRFunctionsErrorDomain) {
                NSDictionary *details = [NSMutableDictionary dictionary];
                [details setValue:[self mapFunctionsErrorCodes:error.code] forKey:@"code"];
                if (error.localizedDescription != nil) {
                  [details setValue:error.localizedDescription forKey:@"message"];
                }
                if (error.userInfo[FIRFunctionsErrorDetailsKey] != nil) {
                  [details setValue:error.userInfo[FIRFunctionsErrorDetailsKey] forKey:@"details"];
                }

                flutterError =
                    [FlutterError errorWithCode:@"functionsError"
                                        message:@"Firebase function failed with exception."
                                        details:details];
              } else {
                flutterError = [FlutterError errorWithCode:nil
                                                   message:error.localizedDescription
                                                   details:nil];
              }
              result(flutterError);
            } else {
              result(callableResult.data);
            }
          }];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

// Map function error code objects to Strings that match error names on Android.
- (NSString *)mapFunctionsErrorCodes:(FIRFunctionsErrorCode)code {
  if (code == FIRFunctionsErrorCodeAborted) {
    return @"ABORTED";
  } else if (code == FIRFunctionsErrorCodeAlreadyExists) {
    return @"ALREADY_EXISTS";
  } else if (code == FIRFunctionsErrorCodeCancelled) {
    return @"CANCELLED";
  } else if (code == FIRFunctionsErrorCodeDataLoss) {
    return @"DATA_LOSS";
  } else if (code == FIRFunctionsErrorCodeDeadlineExceeded) {
    return @"DEADLINE_EXCEEDED";
  } else if (code == FIRFunctionsErrorCodeFailedPrecondition) {
    return @"FAILED_PRECONDITION";
  } else if (code == FIRFunctionsErrorCodeInternal) {
    return @"INTERNAL";
  } else if (code == FIRFunctionsErrorCodeInvalidArgument) {
    return @"INVALID_ARGUMENT";
  } else if (code == FIRFunctionsErrorCodeNotFound) {
    return @"NOT_FOUND";
  } else if (code == FIRFunctionsErrorCodeOK) {
    return @"OK";
  } else if (code == FIRFunctionsErrorCodeOutOfRange) {
    return @"OUT_OF_RANGE";
  } else if (code == FIRFunctionsErrorCodePermissionDenied) {
    return @"PERMISSION_DENIED";
  } else if (code == FIRFunctionsErrorCodeResourceExhausted) {
    return @"RESOURCE_EXHAUSTED";
  } else if (code == FIRFunctionsErrorCodeUnauthenticated) {
    return @"UNAUTHENTICATED";
  } else if (code == FIRFunctionsErrorCodeUnavailable) {
    return @"UNAVAILABLE";
  } else if (code == FIRFunctionsErrorCodeUnimplemented) {
    return @"UNIMPLEMENTED";
  } else {
    return @"UNKNOWN";
  }
}

@end
