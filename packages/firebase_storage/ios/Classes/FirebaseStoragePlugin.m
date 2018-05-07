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
  FIRStorage *storage;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_storage"
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
  NSString *appName = call.arguments[@"app"];
  NSString *storageBucket = call.arguments[@"bucket"];
  if ([appName isEqual:[NSNull null]] && [storageBucket isEqual:[NSNull null]]) {
    storage = [FIRStorage storage];
  } else if ([appName isEqual:[NSNull null]]) {
    storage = [FIRStorage storageWithURL:storageBucket];
  } else if ([storageBucket isEqual:[NSNull null]]) {
    storage = [FIRStorage storageForApp:[FIRApp appNamed:appName]];
  } else {
    storage = [FIRStorage storageForApp:[FIRApp appNamed:appName] URL:storageBucket];
  }

  if ([@"StorageReference#putFile" isEqualToString:call.method]) {
    [self putFile:call result:result];
  } else if ([@"StorageReference#putData" isEqualToString:call.method]) {
    [self putData:call result:result];
  } else if ([@"StorageReference#getData" isEqualToString:call.method]) {
    [self getData:call result:result];
  } else if ([@"StorageReference#getBucket" isEqualToString:call.method]) {
    [self getBucket:call result:result];
  } else if ([@"StorageReference#getPath" isEqualToString:call.method]) {
    [self getPath:call result:result];
  } else if ([@"StorageReference#getName" isEqualToString:call.method]) {
    [self getName:call result:result];
  } else if ([@"StorageReference#getDownloadUrl" isEqualToString:call.method]) {
    [self getDownloadUrl:call result:result];
  } else if ([@"StorageReference#delete" isEqualToString:call.method]) {
    [self delete:call result:result];
  } else if ([@"StorageReference#getMetadata" isEqualToString:call.method]) {
    [self getMetadata:call result:result];
  } else if ([@"StorageReference#updateMetadata" isEqualToString:call.method]) {
    [self updateMetadata:call result:result];
  } else if ([@"StorageReference#writeToFile" isEqualToString:call.method]) {
    [self writeToFile:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)putFile:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSData *data = [NSData dataWithContentsOfFile:call.arguments[@"filename"]];
  [self put:data call:call result:result];
}

- (void)putData:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSData *data = [(FlutterStandardTypedData *)call.arguments[@"data"] data];
  [self put:data call:call result:result];
}

- (void)put:(NSData *)data call:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *path = call.arguments[@"path"];
  NSDictionary *metadataDictionary = call.arguments[@"metadata"];
  FIRStorageMetadata *metadata;
  if (![metadataDictionary isEqual:[NSNull null]]) {
    metadata = [self buildMetadataFromDictionary:metadataDictionary];
  }
  FIRStorageReference *fileRef = [storage.reference child:path];
  [fileRef putData:data
          metadata:metadata
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

- (FIRStorageMetadata *)buildMetadataFromDictionary:(NSDictionary *)dictionary {
  FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
  if (![dictionary[@"cacheControl"] isEqual:[NSNull null]])
    metadata.cacheControl = dictionary[@"cacheControl"];
  if (![dictionary[@"contentDisposition"] isEqual:[NSNull null]])
    metadata.contentDisposition = dictionary[@"contentDisposition"];
  if (![dictionary[@"contentEncoding"] isEqual:[NSNull null]])
    metadata.contentEncoding = dictionary[@"contentEncoding"];
  if (![dictionary[@"contentLanguage"] isEqual:[NSNull null]])
    metadata.contentLanguage = dictionary[@"contentLanguage"];
  if (![dictionary[@"contentType"] isEqual:[NSNull null]])
    metadata.contentType = dictionary[@"contentType"];
  return metadata;
}

- (NSDictionary *)buildDictionaryFromMetadata:(FIRStorageMetadata *)metadata {
  NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
  [dictionary setValue:[metadata bucket] forKey:@"bucket"];
  [dictionary setValue:[NSString stringWithFormat:@"%lld", [metadata generation]]
                forKey:@"generation"];
  [dictionary setValue:[NSString stringWithFormat:@"%lld", [metadata metageneration]]
                forKey:@"metadataGeneration"];
  [dictionary setValue:[metadata path] forKey:@"path"];
  [dictionary setValue:@((long)([[metadata timeCreated] timeIntervalSince1970] * 1000.0))
                forKey:@"creationTimeMillis"];
  [dictionary setValue:@((long)([[metadata updated] timeIntervalSince1970] * 1000.0))
                forKey:@"updatedTimeMillis"];
  [dictionary setValue:@([metadata size]) forKey:@"sizeBytes"];
  [dictionary setValue:[metadata md5Hash] forKey:@"md5Hash"];
  [dictionary setValue:[metadata cacheControl] forKey:@"cacheControl"];
  [dictionary setValue:[metadata contentDisposition] forKey:@"contentDisposition"];
  [dictionary setValue:[metadata contentEncoding] forKey:@"contentEncoding"];
  [dictionary setValue:[metadata contentLanguage] forKey:@"contentLanguage"];
  [dictionary setValue:[metadata contentType] forKey:@"contentType"];
  [dictionary setValue:[metadata name] forKey:@"name"];
  return dictionary;
}

- (void)getData:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSNumber *maxSize = call.arguments[@"maxSize"];
  NSString *path = call.arguments[@"path"];
  FIRStorageReference *ref = [storage.reference child:path];
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

- (void)writeToFile:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *path = call.arguments[@"path"];
  NSString *filePath = call.arguments[@"filePath"];
  NSURL *localURL = [NSURL fileURLWithPath:filePath];
  FIRStorageReference *ref = [storage.reference child:path];
  FIRStorageDownloadTask *task = [ref writeToFile:localURL];
  [task observeStatus:FIRStorageTaskStatusSuccess
              handler:^(FIRStorageTaskSnapshot *snapshot) {
                result(@(snapshot.progress.totalUnitCount));
              }];
  [task observeStatus:FIRStorageTaskStatusFailure
              handler:^(FIRStorageTaskSnapshot *snapshot) {
                if (snapshot.error != nil) {
                  result(snapshot.error.flutterError);
                }
              }];
}

- (void)getMetadata:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *path = call.arguments[@"path"];
  FIRStorageReference *ref = [storage.reference child:path];
  [ref metadataWithCompletion:^(FIRStorageMetadata *metadata, NSError *error) {
    if (error != nil) {
      result(error.flutterError);
    } else {
      result([self buildDictionaryFromMetadata:metadata]);
    }
  }];
}

- (void)updateMetadata:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *path = call.arguments[@"path"];
  NSDictionary *metadataDictionary = call.arguments[@"metadata"];
  FIRStorageReference *ref = [storage.reference child:path];
  [ref updateMetadata:[self buildMetadataFromDictionary:metadataDictionary]
           completion:^(FIRStorageMetadata *metadata, NSError *error) {
             if (error != nil) {
               result(error.flutterError);
             } else {
               result([self buildDictionaryFromMetadata:metadata]);
             }
           }];
}

- (void)getBucket:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *path = call.arguments[@"path"];
  FIRStorageReference *ref = [storage.reference child:path];
  result([ref bucket]);
}

- (void)getName:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *path = call.arguments[@"path"];
  FIRStorageReference *ref = [storage.reference child:path];
  result([ref name]);
}

- (void)getPath:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *path = call.arguments[@"path"];
  FIRStorageReference *ref = [storage.reference child:path];
  result([ref fullPath]);
}

- (void)getDownloadUrl:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *path = call.arguments[@"path"];
  FIRStorageReference *ref = [storage.reference child:path];
  [ref downloadURLWithCompletion:^(NSURL *URL, NSError *error) {
    if (error != nil) {
      result(error.flutterError);
    } else {
      result(URL.absoluteString);
    }
  }];
}

- (void) delete:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *path = call.arguments[@"path"];
  FIRStorageReference *ref = [storage.reference child:path];
  [ref deleteWithCompletion:^(NSError *error) {
    if (error != nil) {
      result(error.flutterError);
    } else {
      result(nil);
    }
  }];
}

@end
