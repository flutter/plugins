// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirestorePlugin.h"

#import <Firebase/Firebase.h>

typedef void (^FIRQueryBlock)(FIRQuery *_Nullable query,
                                      NSError *_Nullable error);

@interface NSError (FlutterError)
@property(readonly, nonatomic) FlutterError *flutterError;
@end

@implementation NSError (FlutterError)
- (FlutterError *)flutterError {
  return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %ld", self.code]
                             message:self.domain
                             details:self.localizedDescription];
}
@end

@interface NSObject (Flutter)
- (BOOL)notNull;
@end

@implementation NSObject (Flutter)
- (BOOL)notNull {
  return ![self isEqual:[NSNull null]];
}
@end

@interface FIRDocumentSnapshot (Flutter)
- (NSDictionary<NSString *, id> *)flutterSnapshot:(NSNumber *)handle;
@end

@interface FIRCollectionReference (Flutter)
- (FIRQuery *)queryWithParameters:(NSDictionary *)parameters;
- (void)queryStartingAtId:(NSString *)documentId withParameters:(NSDictionary *)parameters completion:(FIRQueryBlock)completion;
- (void)queryStartingAfterId:(NSString *)documentId withParameters:(NSDictionary *)parameters completion:(FIRQueryBlock)completion;
- (void)queryEndingAtId:(NSString *)documentId withParameters:(NSDictionary *)parameters completion:(FIRQueryBlock)completion;
@end

@interface FirestorePlugin ()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end

@implementation FirestorePlugin {
  NSMutableDictionary<NSNumber *, id<FIRListenerRegistration>> *_listeners;
  int _nextListenerHandle;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"firestore"
                                  binaryMessenger:[registrar messenger]];
  FirestorePlugin *instance = [[FirestorePlugin alloc] init];
  instance.channel = channel;
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    if (![FIRApp defaultApp]) {
      [FIRApp configure];
    }
    _listeners = [NSMutableDictionary<NSNumber *, id<FIRListenerRegistration>> dictionary];
    _nextListenerHandle = 0;
  }
  return self;
}

+ (NSDictionary *)replaceServerTimestamps:(NSDictionary *)data {
  static NSString * const sServerTimestampKey = @".sv";
  NSMutableDictionary *replaced = data.mutableCopy;
  for (NSString *key in data) {
    if ([data[key] isEqual:sServerTimestampKey]) {
      replaced[key] = [FIRFieldValue fieldValueForServerTimestamp];
    }
  }
  return replaced;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  void (^defaultCompletionBlock)(NSError *) = ^(NSError *error) {
    result(error.flutterError);
  };
  NSString *path = call.arguments[@"path"];
  NSDictionary *parameters = call.arguments[@"parameters"];
  if ([@"DocumentReference#setData" isEqualToString:call.method]) {
    FIRDocumentReference *reference = [[FIRFirestore firestore] documentWithPath:path];
    NSDictionary *data = [FirestorePlugin replaceServerTimestamps:call.arguments[@"data"]];
    [reference setData:data completion:defaultCompletionBlock];
  } else if ([@"Query#addSnapshotListener" isEqualToString:call.method]) {
    [self getQueryForPath:path withParamaters:parameters completion:^(FIRQuery * _Nullable query, NSError * _Nullable error) {
      if (error != nil) {
        result(error.flutterError);
        return;
      }
      __block NSNumber *handle = [NSNumber numberWithInt:_nextListenerHandle++];
      FIRQuerySnapshotBlock observer = [self getQueryObserver:handle];
      id<FIRListenerRegistration> listener = [query addSnapshotListener:observer];
      _listeners[handle] = listener;
      result(handle);
    }];
  } else if ([@"Query#addDocumentListener" isEqualToString:call.method]) {
    __block NSNumber *handle = [NSNumber numberWithInt:_nextListenerHandle++];
    FIRDocumentReference *reference =
        [[FIRFirestore firestore] documentWithPath:call.arguments[@"path"]];
    FIRDocumentSnapshotBlock observer = [self getDocumentObserver:handle];
    id<FIRListenerRegistration> listener = [reference addSnapshotListener:observer];
    _listeners[handle] = listener;
    result(handle);
  } else if ([@"Query#getSnapshot" isEqualToString:call.method]) {
    [self getQueryForPath:path withParamaters:parameters completion:^(FIRQuery * _Nullable query, NSError * _Nullable error) {
      if (error != nil) {
        result(error.flutterError);
      }
      else {
        [query getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable querySnap, NSError * _Nullable error) {
          if (querySnap != nil) {
            NSMutableArray *documents = [NSMutableArray array];
            for (FIRDocumentSnapshot *document in querySnap.documents) {
              [documents addObject:[document flutterSnapshot:nil]];
            }
            NSMutableDictionary *resultArguments = [NSMutableDictionary dictionary];
            resultArguments[@"documents"] = documents;
            resultArguments[@"documentChanges"] = @[];
            result(resultArguments);
          }
          else {
            result(error.flutterError);
          }
        }];
      }
    }];
  } else if ([@"Query#removeQueryListener" isEqualToString:call.method]
             || [@"Query#removeDocumentListener" isEqualToString:call.method]) {
    NSNumber *handle = call.arguments[@"handle"];
    [[_listeners objectForKey:handle] remove];
    [_listeners removeObjectForKey:handle];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)getQueryForPath:(NSString *)path withParamaters:(NSDictionary *)parameters completion:(FIRQueryBlock)completion {
  NSString *startAtId = parameters[@"startAtId"];
  NSString *startAfterId = parameters[@"startAfterId"];
  NSString *endAtId = parameters[@"endAtId"];
  FIRCollectionReference *collectionReference = [[FIRFirestore firestore] collectionWithPath:path];
  if (startAtId.notNull) {
    [collectionReference queryStartingAtId:startAtId withParameters:parameters completion:completion];
  }
  else if (startAfterId.notNull) {
    [collectionReference queryStartingAfterId:startAfterId withParameters:parameters completion:completion];
  }
  else if (endAtId.notNull) {
    [collectionReference queryEndingAtId:endAtId withParameters:parameters completion:completion];
  }
  else {
    completion([collectionReference queryWithParameters:parameters], nil);
  }
}

- (FIRQuerySnapshotBlock)getQueryObserver:(NSNumber *)handle {
  return ^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
    if (error) {
      NSLog(@"[FirestorePlugin] Error in query observer: %@", error.debugDescription);
    }
    if (snapshot == nil) return;
    NSMutableArray *documents = [NSMutableArray array];
    for (FIRDocumentSnapshot *document in snapshot.documents) {
      [documents addObject:[document flutterSnapshot:nil]];
    }
    NSMutableArray *documentChanges = [NSMutableArray array];
    for (FIRDocumentChange *documentChange in snapshot.documentChanges) {
      [documentChanges addObject:@{
                                   @"type" : @(documentChange.type),
                                   @"document" : [documentChange.document flutterSnapshot:nil],
                                   @"oldIndex" : [NSNumber numberWithUnsignedInteger:documentChange.oldIndex],
                                   @"newIndex" : [NSNumber numberWithUnsignedInteger:documentChange.newIndex],
                                   }];
    }
    [self.channel invokeMethod:@"QuerySnapshot"
                     arguments:@{
                                 @"handle" : handle,
                                 @"documents" : documents,
                                 @"documentChanges" : documentChanges
                                 }];
  };
}

- (FIRDocumentSnapshotBlock)getDocumentObserver:(NSNumber *)handle {
  return ^(FIRDocumentSnapshot *snapshot, NSError *_Nullable error) {
    if (error) {
      NSLog(@"[FirestorePlugin] Error in document observer: %@", error.debugDescription);
    }
    if (snapshot == nil) return;
    NSDictionary *document = snapshot.exists ? [snapshot flutterSnapshot:handle] : nil;
    [self.channel invokeMethod:@"DocumentSnapshot"
                     arguments:document];
  };
}

@end

@implementation FIRDocumentSnapshot (Flutter)
- (NSDictionary<NSString *, id> *)flutterSnapshot:(NSNumber *)handle {
  NSMutableDictionary *cleaned = self.data.mutableCopy;
  for (NSString *key in self.data) {
    id value = self.data[key];
    if ([value isKindOfClass:NSDate.class]) {
      cleaned[key] = @((long)([(NSDate *)value timeIntervalSince1970] * 1000));
    }
  }
  NSMutableDictionary *result = [NSMutableDictionary dictionary];
  result[@"data"] = cleaned;
  result[@"id"] = self.documentID;
  if (handle != nil) {
    result[@"handle"] = handle;
  }
  return result;
}
@end

@implementation FIRCollectionReference (Flutter)
- (FIRQuery *)queryWithParameters:(NSDictionary *)parameters {
  NSString *orderBy = parameters[@"orderBy"];
  NSNumber *limit = parameters[@"limit"];
  NSNumber *descending = parameters[@"descending"];
  BOOL desc = (descending != nil) ? descending.boolValue : false;
  FIRQuery *query = self;
  if (orderBy != nil) query = [query queryOrderedByField:orderBy descending:desc];
  if (limit != nil) query = [query queryLimitedTo:limit.integerValue];
  return query;
}

- (void)queryStartingAtId:(NSString *)documentId withParameters:(NSDictionary *)parameters completion:(FIRQueryBlock)completion {
  [[self documentWithPath:documentId] getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
    if (error != nil) completion(nil, error);
    else completion([[self queryWithParameters:parameters] queryStartingAtDocument:snapshot], nil);
  }];
}

- (void)queryStartingAfterId:(NSString *)documentId withParameters:(NSDictionary *)parameters completion:(FIRQueryBlock)completion {
  [[self documentWithPath:documentId] getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
    if (error != nil) completion(nil, error);
    else completion([[self queryWithParameters:parameters] queryStartingAfterDocument:snapshot], nil);
  }];
}

- (void)queryEndingAtId:(NSString *)documentId withParameters:(NSDictionary *)parameters completion:(FIRQueryBlock)completion {
  [[self documentWithPath:documentId] getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
    if (error != nil) completion(nil, error);
    else completion([[self queryWithParameters:parameters] queryEndingAtDocument:snapshot], nil);
  }];
}
@end
