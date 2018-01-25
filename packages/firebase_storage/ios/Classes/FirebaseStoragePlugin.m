// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebaseStoragePlugin.h"

#import <Firebase/Firebase.h>

@interface NSError (FlutterError)
@property(readonly, nonatomic) FlutterError *flutterError;
@end

@implementation NSError (FlutterError)
- (FlutterError *)flutterError {
  return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %ld", (long)self.code]
                             message:self.domain
                             details:self.localizedDescription];
}
@end

@implementation FLTFirebaseStoragePlugin {
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"firebase_storage"
                                  binaryMessenger:[registrar messenger]];
  FLTFirebaseStoragePlugin *instance = [[FLTFirebaseStoragePlugin alloc] init];
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
  if ([@"StorageReference#putFile" isEqualToString:call.method]) {
    [self putFile:call result:result];
  } else if ([@"StorageReference#getData" isEqualToString:call.method]) {
    [self getData:call result:result];
  } else if ([@"StorageReference#delete" isEqualToString:call.method]) {
    [self delete:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)putFile:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSData *data = [NSData dataWithContentsOfFile:call.arguments[@"filename"]];
  NSString *path = call.arguments[@"path"];
  FIRStorageReference *fileRef = [[FIRStorage storage].reference child:path];
  [fileRef putData:data
          metadata:nil
        completion:^(FIRStorageMetadata *metadata, NSError *error) {
          if (error != nil) {
            result(error.flutterError);
          } else {
            // Metadata contains file metadata such as size,
            // content-type, and download URL.
            NSURL *downloadURL = metadata.downloadURL;
            result(downloadURL.absoluteString);
          }
        }];
}

- (void)getData:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSNumber *maxSize = call.arguments[@"maxSize"];
  NSString *path = call.arguments[@"path"];
  FIRStorageReference *ref = [[FIRStorage storage].reference child:path];
  [ref dataWithMaxSize:[maxSize longLongValue]
            completion:^(NSData *_Nullable data, NSError *_Nullable error) {
              if (error != nil) {
                result(error.flutterError);
                return;
              }
              if (data == nil) {
                result(nil);
                return;
              }

              FlutterStandardTypedData *dartData =
                  [FlutterStandardTypedData typedDataWithBytes:data];
              result(dartData);
            }];
}

- (void) delete:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *path = call.arguments[@"path"];
  FIRStorageReference *ref = [[FIRStorage storage].reference child:path];
  [ref deleteWithCompletion:^(NSError *error) {
    if (error != nil) {
      result(error.flutterError);
    } else {
      result(nil);
    }
  }];
}

@end
