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
  NSArray *whereConditions = parameters[@"where"];
  for (id item in whereConditions) {
    NSArray *condition = item;
    NSString *fieldName = condition[0];
    NSString *op = condition[1];
    id value = condition[2];
    if ([op isEqualToString:@"=="]) {
      query = [query queryWhereField:fieldName isEqualTo:value];
    } else if ([op isEqualToString:@"<"]) {
      query = [query queryWhereField:fieldName isLessThan:value];
    } else if ([op isEqualToString:@"<="]) {
      query = [query queryWhereField:fieldName isLessThanOrEqualTo:value];
    } else if ([op isEqualToString:@">"]) {
      query = [query queryWhereField:fieldName isGreaterThan:value];
    } else if ([op isEqualToString:@">="]) {
      query = [query queryWhereField:fieldName isGreaterThanOrEqualTo:value];
    } else {
      // Unsupported operator
    }
  }
  id limit = parameters[@"limit"];
  if (limit) {
    NSNumber *length = limit;
    query = [query queryLimitedTo:[length intValue]];
  }
  NSArray *orderBy = parameters[@"orderBy"];
  if (orderBy) {
    for (id item in orderBy) {
      NSArray *orderByParameters = item;
      NSString *fieldName = orderByParameters[0];
      NSNumber *descending = orderByParameters[1];
      query = [query queryOrderedByField:fieldName descending:[descending boolValue]];
    }
  }
  id startAt = parameters[@"startAt"];
  if (startAt) {
    NSArray *startAtValues = startAt;
    query = [query queryStartingAtValues:startAtValues];
  }
  id startAfter = parameters[@"startAfter"];
  if (startAfter) {
    NSArray *startAfterValues = startAfter;
    query = [query queryStartingAfterValues:startAfterValues];
  }
  id endAt = parameters[@"endAt"];
  if (endAt) {
    NSArray *endAtValues = endAt;
    query = [query queryEndingAtValues:endAtValues];
  }
  id endBefore = parameters[@"endBefore"];
  if (endBefore) {
    NSArray *endBeforeValues = endBefore;
    query = [query queryEndingBeforeValues:endBeforeValues];
  }
  return query;
}

@interface FLTCloudFirestorePlugin ()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end

@implementation FLTCloudFirestorePlugin {
  NSMutableDictionary<NSNumber *, id<FIRListenerRegistration>> *_listeners;
  int _nextListenerHandle;
  NSMutableDictionary *transactions;
  NSMutableDictionary *transactionResults;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/cloud_firestore"
                                  binaryMessenger:[registrar messenger]];
  FLTCloudFirestorePlugin *instance = [[FLTCloudFirestorePlugin alloc] init];
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
    transactions = [NSMutableDictionary<NSNumber *, FIRTransaction *> dictionary];
    transactionResults = [NSMutableDictionary<NSNumber *, id> dictionary];
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  void (^defaultCompletionBlock)(NSError *) = ^(NSError *error) {
    result(error.flutterError);
  };
  if ([@"Firestore#runTransaction" isEqualToString:call.method]) {
    [[FIRFirestore firestore] runTransactionWithBlock:^id(FIRTransaction *transaction,
                                                          NSError **pError) {
      NSNumber *transactionId = call.arguments[@"transactionId"];
      NSNumber *transactionTimeout = call.arguments[@"transactionTimeout"];

      transactions[transactionId] = transaction;

      dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

      [self.channel invokeMethod:@"DoTransaction"
                       arguments:call.arguments
                          result:^(id doTransactionResult) {
                            transactionResults[transactionId] = doTransactionResult;
                            dispatch_semaphore_signal(semaphore);
                          }];

      dispatch_semaphore_wait(
          semaphore, dispatch_time(DISPATCH_TIME_NOW, [transactionTimeout integerValue] * 1000000));

      return transactionResults[transactionId];
    }
        completion:^(id transactionResult, NSError *error) {
          if (error != nil) {
            result([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", error.code]
                                       message:error.localizedDescription
                                       details:nil]);
          }
          result(transactionResult);
        }];
  } else if ([@"Transaction#get" isEqualToString:call.method]) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      NSNumber *transactionId = call.arguments[@"transactionId"];
      NSString *path = call.arguments[@"path"];
      FIRDocumentReference *documentReference = [[FIRFirestore firestore] documentWithPath:path];
      FIRTransaction *transaction = transactions[transactionId];
      NSError *error = [[NSError alloc] init];

      FIRDocumentSnapshot *snapshot = [transaction getDocument:documentReference error:&error];

      if (error != nil) {
        result([FlutterError errorWithCode:[NSString stringWithFormat:@"%tu", [error code]]
                                   message:[error localizedDescription]
                                   details:nil]);
      } else if (snapshot != nil) {
        result(@{
          @"path" : snapshot.reference.path,
          @"data" : snapshot.exists ? snapshot.data : [NSNull null]
        });
      } else {
        result([FlutterError errorWithCode:@"DOCUMENT_NOT_FOUND"
                                   message:@"Document not found."
                                   details:nil]);
      }
    });
  } else if ([@"Transaction#update" isEqualToString:call.method]) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      NSNumber *transactionId = call.arguments[@"transactionId"];
      NSString *path = call.arguments[@"path"];
      FIRDocumentReference *documentReference = [[FIRFirestore firestore] documentWithPath:path];
      FIRTransaction *transaction = transactions[transactionId];

      [transaction updateData:call.arguments[@"data"] forDocument:documentReference];
      result(nil);
    });
  } else if ([@"Transaction#set" isEqualToString:call.method]) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      NSNumber *transactionId = call.arguments[@"transactionId"];
      NSString *path = call.arguments[@"path"];
      FIRDocumentReference *documentReference = [[FIRFirestore firestore] documentWithPath:path];
      FIRTransaction *transaction = transactions[transactionId];

      [transaction setData:call.arguments[@"data"] forDocument:documentReference];
      result(nil);
    });
  } else if ([@"Transaction#delete" isEqualToString:call.method]) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      NSNumber *transactionId = call.arguments[@"transactionId"];
      NSString *path = call.arguments[@"path"];
      FIRDocumentReference *documentReference = [[FIRFirestore firestore] documentWithPath:path];
      FIRTransaction *transaction = transactions[transactionId];

      [transaction deleteDocument:documentReference];
      result(nil);
    });
  } else if ([@"DocumentReference#setData" isEqualToString:call.method]) {
    NSString *path = call.arguments[@"path"];
    NSDictionary *options = call.arguments[@"options"];
    FIRDocumentReference *reference = [[FIRFirestore firestore] documentWithPath:path];
    if (![options isEqual:[NSNull null]] &&
        [options[@"merge"] isEqual:[NSNumber numberWithBool:YES]]) {
      [reference setData:call.arguments[@"data"]
                 options:[FIRSetOptions merge]
              completion:defaultCompletionBlock];
    } else {
      [reference setData:call.arguments[@"data"] completion:defaultCompletionBlock];
    }
  } else if ([@"DocumentReference#updateData" isEqualToString:call.method]) {
    NSString *path = call.arguments[@"path"];
    FIRDocumentReference *reference = [[FIRFirestore firestore] documentWithPath:path];
    [reference updateData:call.arguments[@"data"] completion:defaultCompletionBlock];
  } else if ([@"DocumentReference#delete" isEqualToString:call.method]) {
    NSString *path = call.arguments[@"path"];
    FIRDocumentReference *reference = [[FIRFirestore firestore] documentWithPath:path];
    [reference deleteDocumentWithCompletion:defaultCompletionBlock];
  } else if ([@"DocumentReference#get" isEqualToString:call.method]) {
    NSString *path = call.arguments[@"path"];
    FIRDocumentReference *reference = [[FIRFirestore firestore] documentWithPath:path];
    [reference getDocumentWithCompletion:^(FIRDocumentSnapshot *_Nullable snapshot,
                                           NSError *_Nullable error) {
      if (error) {
        result(error.flutterError);
      } else {
        result(@{
          @"path" : snapshot.reference.path,
          @"data" : snapshot.exists ? snapshot.data : [NSNull null]
        });
      }
    }];
  } else if ([@"Query#addSnapshotListener" isEqualToString:call.method]) {
    __block NSNumber *handle = [NSNumber numberWithInt:_nextListenerHandle++];
    FIRQuery *query;
    @try {
      query = getQuery(call.arguments);
    } @catch (NSException *exception) {
      result([FlutterError errorWithCode:@"invalid_query"
                                 message:[exception name]
                                 details:[exception reason]]);
    }
    id<FIRListenerRegistration> listener = [query
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
              @"oldIndex" : [NSNumber numberWithInt:documentChange.oldIndex],
              @"newIndex" : [NSNumber numberWithInt:documentChange.newIndex],
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
