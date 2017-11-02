// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "CloudFirestorePlugin.h"

#import <Firebase/Firebase.h>

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

FIRQuery *getQuery(NSDictionary *arguments) {
  FIRQuery *query = [[FIRFirestore firestore] collectionWithPath:arguments[@"path"]];
  NSDictionary *parameters = arguments[@"parameters"];
  for (id key in parameters) {
    NSString *keyString = key;
    if ([keyString hasPrefix:@"where==:"]) {
      NSString *field = [keyString stringByReplacingOccurrencesOfString:@"where==:"
                                                             withString:@""];
      query = [query queryWhereField:field isEqualTo:parameters[key]];
    } else if ([keyString hasPrefix:@"where<:"]) {
      NSString *field = [keyString stringByReplacingOccurrencesOfString:@"where<:"
                                                             withString:@""];
      query = [query queryWhereField:field isLessThan:parameters[key]];
    } else if ([keyString hasPrefix:@"where<=:"]) {
      NSString *field = [keyString stringByReplacingOccurrencesOfString:@"where<=:"
                                                             withString:@""];
      query = [query queryWhereField:field isLessThanOrEqualTo:parameters[key]];
    } else if ([keyString hasPrefix:@"where>:"]) {
      NSString *field = [keyString stringByReplacingOccurrencesOfString:@"where>:"
                                                             withString:@""];
      query = [query queryWhereField:field isGreaterThan:parameters[key]];
    } else if ([keyString hasPrefix:@"where>=:"]) {
      NSString *field = [keyString stringByReplacingOccurrencesOfString:@"where>=:"
                                                             withString:@""];
      query = [query queryWhereField:field isGreaterThanOrEqualTo:parameters[key]];
    } else if ([keyString hasPrefix:@"orderBy:"]) {
      NSString *field = [keyString stringByReplacingOccurrencesOfString:@"orderBy:"
                                                             withString:@""];
      NSNumber *val = parameters[key];
      BOOL desc = [val boolValue];
      query = [query queryOrderedByField:field descending:desc];
    } else {
      // Not implemented.
    }
  }
  return query;
}

@interface CloudFirestorePlugin ()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end

@implementation CloudFirestorePlugin {
  NSMutableDictionary<NSNumber *, id<FIRListenerRegistration>> *_listeners;
  int _nextListenerHandle;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/cloud_firestore"
                                  binaryMessenger:[registrar messenger]];
  CloudFirestorePlugin *instance = [[CloudFirestorePlugin alloc] init];
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

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  void (^defaultCompletionBlock)(NSError *) = ^(NSError *error) {
    result(error.flutterError);
  };
  if ([@"DocumentReference#setData" isEqualToString:call.method]) {
    NSString *path = call.arguments[@"path"];
    FIRDocumentReference *reference = [[FIRFirestore firestore] documentWithPath:path];
    [reference setData:call.arguments[@"data"] completion:defaultCompletionBlock];
  } else if ([@"DocumentReference#delete" isEqualToString:call.method]) {
    NSString *path = call.arguments[@"path"];
    FIRDocumentReference *reference = [[FIRFirestore firestore] documentWithPath:path];
    [reference deleteDocumentWithCompletion:defaultCompletionBlock];
  } else if ([@"Query#addSnapshotListener" isEqualToString:call.method]) {
    __block NSNumber *handle = [NSNumber numberWithInt:_nextListenerHandle++];
    id<FIRListenerRegistration> listener = [getQuery(call.arguments)
        addSnapshotListener:^(FIRQuerySnapshot *_Nullable snapshot, NSError *_Nullable error) {
          if (error) result(error.flutterError);
          NSMutableArray *paths = [NSMutableArray array];
          NSMutableArray *documents = [NSMutableArray array];
          for (FIRDocumentSnapshot *document in snapshot.documents) {
            [paths addObject:document.reference.path];
            [documents addObject:document.data];
          }
          NSMutableArray *documentChanges = [NSMutableArray array];
          for (FIRDocumentChange *documentChange in snapshot.documentChanges) {
            NSString *type;
            switch (documentChange.type) {
              case FIRDocumentChangeTypeAdded:
                type = @"DocumentChangeType.added";
                break;
              case FIRDocumentChangeTypeModified:
                type = @"DocumentChangeType.modified";
                break;
              case FIRDocumentChangeTypeRemoved:
                type = @"DocumentChangeType.removed";
                break;
            }
            [documentChanges addObject:@{
              @"type" : type,
              @"document" : documentChange.document.data,
              @"path" : documentChange.document.reference.path,
              @"oldIndex" : [NSNumber numberWithUnsignedInteger:documentChange.oldIndex],
              @"newIndex" : [NSNumber numberWithUnsignedInteger:documentChange.newIndex],
            }];
          }
          [self.channel invokeMethod:@"QuerySnapshot"
                           arguments:@{
                             @"handle" : handle,
                             @"paths" : paths,
                             @"documents" : documents,
                             @"documentChanges" : documentChanges
                           }];
        }];
    _listeners[handle] = listener;
    result(handle);
  } else if ([@"Query#addDocumentListener" isEqualToString:call.method]) {
    __block NSNumber *handle = [NSNumber numberWithInt:_nextListenerHandle++];
    FIRDocumentReference *reference =
        [[FIRFirestore firestore] documentWithPath:call.arguments[@"path"]];
    id<FIRListenerRegistration> listener =
        [reference addSnapshotListener:^(FIRDocumentSnapshot *snapshot, NSError *_Nullable error) {
          if (error) result(error.flutterError);
          [self.channel invokeMethod:@"DocumentSnapshot"
                           arguments:@{
                             @"handle" : handle,
                             @"path" : snapshot.reference.path,
                             @"data" : snapshot.exists ? snapshot.data : [NSNull null],
                           }];
        }];
    _listeners[handle] = listener;
    result(handle);
  } else if ([@"Query#removeListener" isEqualToString:call.method]) {
    NSNumber *handle = call.arguments[@"handle"];
    [[_listeners objectForKey:handle] remove];
    [_listeners removeObjectForKey:handle];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
