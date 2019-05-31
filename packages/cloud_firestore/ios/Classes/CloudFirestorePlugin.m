// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "CloudFirestorePlugin.h"

#import <Firebase/Firebase.h>

<<<<<<< HEAD
@interface NSError (FlutterError)
@property(readonly, nonatomic) FlutterError *flutterError;
@end
=======
#define LIBRARY_NAME @"flutter-firebase_cloud_firestore"
#define LIBRARY_VERSION @"0.12.1"

static FlutterError *getFlutterError(NSError *error) {
  if (error == nil) return nil;
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a

@implementation NSError (FlutterError)
- (FlutterError *)flutterError {
  return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %ld", self.code]
                             message:self.domain
                             details:self.localizedDescription];
}
@end

static FIRFirestore *getFirestore(NSDictionary *arguments) {
  FIRApp *app = [FIRApp appNamed:arguments[@"app"]];
  return [FIRFirestore firestoreForApp:app];
}

static FIRDocumentReference *getDocumentReference(NSDictionary *arguments) {
  return [getFirestore(arguments) documentWithPath:arguments[@"path"]];
}

static NSArray *getDocumentValues(NSDictionary *document, NSArray *orderBy) {
  NSMutableArray *values = [[NSMutableArray alloc] init];
  NSString *documentId = document[@"id"];
  NSDictionary *documentData = document[@"data"];
  if (orderBy) {
    for (id item in orderBy) {
      NSArray *orderByParameters = item;
      NSString *fieldName = orderByParameters[0];
      [values addObject:[documentData objectForKey:fieldName]];
    }
  }
  [values addObject:documentId];
  return values;
}

static FIRQuery *getQuery(NSDictionary *arguments) {
  FIRQuery *query = [getFirestore(arguments) collectionWithPath:arguments[@"path"]];
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
    for (NSArray *orderByParameters in orderBy) {
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
  id startAtDocument = parameters[@"startAtDocument"];
  if (startAtDocument) {
    query = [query queryOrderedByFieldPath:FIRFieldPath.documentID descending:NO];
    query = [query queryStartingAtValues:getDocumentValues(startAtDocument, orderBy)];
  }
  id startAfter = parameters[@"startAfter"];
  if (startAfter) {
    NSArray *startAfterValues = startAfter;
    query = [query queryStartingAfterValues:startAfterValues];
  }
  id startAfterDocument = parameters[@"startAfterDocument"];
  if (startAfterDocument) {
    query = [query queryOrderedByFieldPath:FIRFieldPath.documentID descending:NO];
    query = [query queryStartingAfterValues:getDocumentValues(startAfterDocument, orderBy)];
  }
  id endAt = parameters[@"endAt"];
  if (endAt) {
    NSArray *endAtValues = endAt;
    query = [query queryEndingAtValues:endAtValues];
  }
  id endAtDocument = parameters[@"endAtDocument"];
  if (endAtDocument) {
    query = [query queryOrderedByFieldPath:FIRFieldPath.documentID descending:NO];
    query = [query queryEndingAtValues:getDocumentValues(endAtDocument, orderBy)];
  }
  id endBefore = parameters[@"endBefore"];
  if (endBefore) {
    NSArray *endBeforeValues = endBefore;
    query = [query queryEndingBeforeValues:endBeforeValues];
  }
  id endBeforeDocument = parameters[@"endBeforeDocument"];
  if (endBeforeDocument) {
    query = [query queryOrderedByFieldPath:FIRFieldPath.documentID descending:NO];
    query = [query queryEndingBeforeValues:getDocumentValues(endBeforeDocument, orderBy)];
  }
  return query;
}

static FIRFirestoreSource getSource(NSDictionary *arguments) {
  NSString *source = arguments[@"source"];
  if ([@"server" isEqualToString:source]) {
    return FIRFirestoreSourceServer;
  }
  if ([@"cache" isEqualToString:source]) {
    return FIRFirestoreSourceCache;
  }
  return FIRFirestoreSourceDefault;
}

static NSDictionary *parseQuerySnapshot(FIRQuerySnapshot *snapshot) {
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
  return @{
    @"paths" : paths,
    @"documentChanges" : documentChanges,
    @"documents" : documents,
  };
}

const UInt8 DATE_TIME = 128;
const UInt8 GEO_POINT = 129;
const UInt8 DOCUMENT_REFERENCE = 130;
const UInt8 BLOB = 131;
<<<<<<< HEAD
=======
const UInt8 ARRAY_UNION = 132;
const UInt8 ARRAY_REMOVE = 133;
const UInt8 DELETE = 134;
const UInt8 SERVER_TIMESTAMP = 135;
const UInt8 TIMESTAMP = 136;
const UInt8 INCREMENT_DOUBLE = 137;
const UInt8 INCREMENT_INTEGER = 138;
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a

@interface FirestoreWriter : FlutterStandardWriter
- (void)writeValue:(id)value;
@end

@implementation FirestoreWriter : FlutterStandardWriter
- (void)writeValue:(id)value {
  if ([value isKindOfClass:[NSDate class]]) {
    [self writeByte:DATE_TIME];
    NSDate *date = value;
    NSTimeInterval time = date.timeIntervalSince1970;
    SInt64 ms = (SInt64)(time * 1000.0);
    [self writeBytes:&ms length:8];
  } else if ([value isKindOfClass:[FIRGeoPoint class]]) {
    FIRGeoPoint *geoPoint = value;
    Float64 latitude = geoPoint.latitude;
    Float64 longitude = geoPoint.longitude;
    [self writeByte:GEO_POINT];
    [self writeAlignment:8];
    [self writeBytes:(UInt8 *)&latitude length:8];
    [self writeBytes:(UInt8 *)&longitude length:8];
  } else if ([value isKindOfClass:[FIRDocumentReference class]]) {
    FIRDocumentReference *document = value;
    NSString *documentPath = [document path];
    [self writeByte:DOCUMENT_REFERENCE];
    [self writeUTF8:document.firestore.app.name];
    [self writeUTF8:documentPath];
  } else if ([value isKindOfClass:[NSData class]]) {
    NSData *blob = value;
    [self writeByte:BLOB];
    [self writeSize:blob.length];
    [self writeData:blob];
  } else {
    [super writeValue:value];
  }
}
@end

@interface FirestoreReader : FlutterStandardReader
- (id)readValueOfType:(UInt8)type;
@end

@implementation FirestoreReader
- (id)readValueOfType:(UInt8)type {
  switch (type) {
    case DATE_TIME: {
      SInt64 value;
      [self readBytes:&value length:8];
      NSTimeInterval time = [NSNumber numberWithLong:value].doubleValue / 1000.0;
      return [NSDate dateWithTimeIntervalSince1970:time];
    }
    case GEO_POINT: {
      Float64 latitude;
      Float64 longitude;
      [self readAlignment:8];
      [self readBytes:&latitude length:8];
      [self readBytes:&longitude length:8];
      return [[FIRGeoPoint alloc] initWithLatitude:latitude longitude:longitude];
    }
    case DOCUMENT_REFERENCE: {
      NSString *appName = [self readUTF8];
      FIRFirestore *firestore = [FIRFirestore firestoreForApp:[FIRApp appNamed:appName]];
      NSString *documentPath = [self readUTF8];
      return [firestore documentWithPath:documentPath];
    }
    case BLOB: {
      UInt32 elementCount = [self readSize];
      return [self readData:elementCount];
    }
<<<<<<< HEAD
=======
    case ARRAY_UNION: {
      return [FIRFieldValue fieldValueForArrayUnion:[self readValue]];
    }
    case ARRAY_REMOVE: {
      return [FIRFieldValue fieldValueForArrayRemove:[self readValue]];
    }
    case DELETE: {
      return [FIRFieldValue fieldValueForDelete];
    }
    case SERVER_TIMESTAMP: {
      return [FIRFieldValue fieldValueForServerTimestamp];
    }
    case INCREMENT_DOUBLE: {
      NSNumber *value = [self readValue];
      return [FIRFieldValue fieldValueForDoubleIncrement:value.doubleValue];
    }
    case INCREMENT_INTEGER: {
      NSNumber *value = [self readValue];
      return [FIRFieldValue fieldValueForIntegerIncrement:value.intValue];
    }
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
    default:
      return [super readValueOfType:type];
  }
}
@end

@interface FirestoreReaderWriter : FlutterStandardReaderWriter
- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data;
- (FlutterStandardReader *)readerWithData:(NSData *)data;
@end

@implementation FirestoreReaderWriter
- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data {
  return [[FirestoreWriter alloc] initWithData:data];
}
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[FirestoreReader alloc] initWithData:data];
}
@end

@interface FLTCloudFirestorePlugin ()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end

@implementation FLTCloudFirestorePlugin {
  NSMutableDictionary<NSNumber *, id<FIRListenerRegistration>> *_listeners;
  int _nextListenerHandle;
  NSMutableDictionary *transactions;
  NSMutableDictionary *transactionResults;
  NSMutableDictionary<NSNumber *, FIRWriteBatch *> *_batches;
  int _nextBatchHandle;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FirestoreReaderWriter *firestoreReaderWriter = [FirestoreReaderWriter new];
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/cloud_firestore"
                                  binaryMessenger:[registrar messenger]
                                            codec:[FlutterStandardMethodCodec
                                                      codecWithReaderWriter:firestoreReaderWriter]];
  FLTCloudFirestorePlugin *instance = [[FLTCloudFirestorePlugin alloc] init];
  instance.channel = channel;
  [registrar addMethodCallDelegate:instance channel:channel];

  SEL sel = NSSelectorFromString(@"registerLibrary:withVersion:");
  if ([FIRApp respondsToSelector:sel]) {
    [FIRApp performSelector:sel withObject:LIBRARY_NAME withObject:LIBRARY_VERSION];
  }
}

- (instancetype)init {
  self = [super init];
  if (self) {
    if (![FIRApp defaultApp]) {
      [FIRApp configure];
    }
    _listeners = [NSMutableDictionary<NSNumber *, id<FIRListenerRegistration>> dictionary];
    _batches = [NSMutableDictionary<NSNumber *, FIRWriteBatch *> dictionary];
    _nextListenerHandle = 0;
    _nextBatchHandle = 0;
    transactions = [NSMutableDictionary<NSNumber *, FIRTransaction *> dictionary];
    transactionResults = [NSMutableDictionary<NSNumber *, id> dictionary];
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  __weak __typeof__(self) weakSelf = self;
  void (^defaultCompletionBlock)(NSError *) = ^(NSError *error) {
    result(error.flutterError);
  };
  if ([@"Firestore#runTransaction" isEqualToString:call.method]) {
    [getFirestore(call.arguments) runTransactionWithBlock:^id(FIRTransaction *transaction,
                                                              NSError **pError) {
      NSNumber *transactionId = call.arguments[@"transactionId"];
      NSNumber *transactionTimeout = call.arguments[@"transactionTimeout"];

      transactions[transactionId] = transaction;

      dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

<<<<<<< HEAD
      [self.channel invokeMethod:@"DoTransaction"
                       arguments:call.arguments
                          result:^(id doTransactionResult) {
                            transactionResults[transactionId] = doTransactionResult;
                            dispatch_semaphore_signal(semaphore);
                          }];
=======
          [weakSelf.channel invokeMethod:@"DoTransaction"
                               arguments:call.arguments
                                  result:^(id doTransactionResult) {
                                    FLTCloudFirestorePlugin *currentSelf = weakSelf;
                                    currentSelf->transactionResults[transactionId] =
                                        doTransactionResult;
                                    dispatch_semaphore_signal(semaphore);
                                  }];
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a

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
      FIRDocumentReference *document = getDocumentReference(call.arguments);
      FIRTransaction *transaction = transactions[transactionId];
      NSError *error = [[NSError alloc] init];

      FIRDocumentSnapshot *snapshot = [transaction getDocument:document error:&error];

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
      FIRDocumentReference *document = getDocumentReference(call.arguments);
      FIRTransaction *transaction = transactions[transactionId];

      [transaction updateData:call.arguments[@"data"] forDocument:document];
      result(nil);
    });
  } else if ([@"Transaction#set" isEqualToString:call.method]) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      NSNumber *transactionId = call.arguments[@"transactionId"];
      FIRDocumentReference *document = getDocumentReference(call.arguments);
      FIRTransaction *transaction = transactions[transactionId];

      [transaction setData:call.arguments[@"data"] forDocument:document];
      result(nil);
    });
  } else if ([@"Transaction#delete" isEqualToString:call.method]) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      NSNumber *transactionId = call.arguments[@"transactionId"];
      FIRDocumentReference *document = getDocumentReference(call.arguments);
      FIRTransaction *transaction = transactions[transactionId];

      [transaction deleteDocument:document];
      result(nil);
    });
  } else if ([@"DocumentReference#setData" isEqualToString:call.method]) {
    NSDictionary *options = call.arguments[@"options"];
    FIRDocumentReference *document = getDocumentReference(call.arguments);
    if (![options isEqual:[NSNull null]] &&
        [options[@"merge"] isEqual:[NSNumber numberWithBool:YES]]) {
      [document setData:call.arguments[@"data"] merge:YES completion:defaultCompletionBlock];
    } else {
      [document setData:call.arguments[@"data"] completion:defaultCompletionBlock];
    }
  } else if ([@"DocumentReference#updateData" isEqualToString:call.method]) {
    FIRDocumentReference *document = getDocumentReference(call.arguments);
    [document updateData:call.arguments[@"data"] completion:defaultCompletionBlock];
  } else if ([@"DocumentReference#delete" isEqualToString:call.method]) {
    FIRDocumentReference *document = getDocumentReference(call.arguments);
    [document deleteDocumentWithCompletion:defaultCompletionBlock];
  } else if ([@"DocumentReference#get" isEqualToString:call.method]) {
    FIRDocumentReference *document = getDocumentReference(call.arguments);
<<<<<<< HEAD
    [document getDocumentWithCompletion:^(FIRDocumentSnapshot *_Nullable snapshot,
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
=======
    FIRFirestoreSource source = getSource(call.arguments);
    [document
        getDocumentWithSource:source
                   completion:^(FIRDocumentSnapshot *_Nullable snapshot, NSError *_Nullable error) {
                     if (snapshot == nil) {
                       result(getFlutterError(error));
                     } else {
                       result(@{
                         @"path" : snapshot.reference.path,
                         @"data" : snapshot.exists ? snapshot.data : [NSNull null],
                         @"metadata" : @{
                           @"hasPendingWrites" : @(snapshot.metadata.hasPendingWrites),
                           @"isFromCache" : @(snapshot.metadata.isFromCache),
                         },
                       });
                     }
                   }];
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
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
          NSMutableDictionary *arguments = [parseQuerySnapshot(snapshot) mutableCopy];
          [arguments setObject:handle forKey:@"handle"];
          [weakSelf.channel invokeMethod:@"QuerySnapshot" arguments:arguments];
        }];
    _listeners[handle] = listener;
    result(handle);
  } else if ([@"Query#addDocumentListener" isEqualToString:call.method]) {
    __block NSNumber *handle = [NSNumber numberWithInt:_nextListenerHandle++];
    FIRDocumentReference *document = getDocumentReference(call.arguments);
    id<FIRListenerRegistration> listener =
        [document addSnapshotListener:^(FIRDocumentSnapshot *snapshot, NSError *_Nullable error) {
<<<<<<< HEAD
          if (error) result(error.flutterError);
          [self.channel invokeMethod:@"DocumentSnapshot"
                           arguments:@{
                             @"handle" : handle,
                             @"path" : snapshot.reference.path,
                             @"data" : snapshot.exists ? snapshot.data : [NSNull null],
                           }];
=======
          if (snapshot == nil) {
            result(getFlutterError(error));
            return;
          }
          [weakSelf.channel invokeMethod:@"DocumentSnapshot"
                               arguments:@{
                                 @"handle" : handle,
                                 @"path" : snapshot ? snapshot.reference.path : [NSNull null],
                                 @"data" : snapshot.exists ? snapshot.data : [NSNull null],
                                 @"metadata" : snapshot ? @{
                                   @"hasPendingWrites" : @(snapshot.metadata.hasPendingWrites),
                                   @"isFromCache" : @(snapshot.metadata.isFromCache),
                                 }
                                                        : [NSNull null],
                               }];
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
        }];
    _listeners[handle] = listener;
    result(handle);
  } else if ([@"Query#getDocuments" isEqualToString:call.method]) {
    FIRQuery *query;
    FIRFirestoreSource source = getSource(call.arguments);
    @try {
      query = getQuery(call.arguments);
    } @catch (NSException *exception) {
      result([FlutterError errorWithCode:@"invalid_query"
                                 message:[exception name]
                                 details:[exception reason]]);
    }
<<<<<<< HEAD
    [query getDocumentsWithCompletion:^(FIRQuerySnapshot *_Nullable snapshot,
                                        NSError *_Nullable error) {
      if (error) result(error.flutterError);
      result(parseQuerySnapshot(snapshot));
    }];
=======

    [query
        getDocumentsWithSource:source
                    completion:^(FIRQuerySnapshot *_Nullable snapshot, NSError *_Nullable error) {
                      if (snapshot == nil) {
                        result(getFlutterError(error));
                        return;
                      }
                      result(parseQuerySnapshot(snapshot));
                    }];
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
  } else if ([@"Query#removeListener" isEqualToString:call.method]) {
    NSNumber *handle = call.arguments[@"handle"];
    [[_listeners objectForKey:handle] remove];
    [_listeners removeObjectForKey:handle];
    result(nil);
  } else if ([@"WriteBatch#create" isEqualToString:call.method]) {
    __block NSNumber *handle = [NSNumber numberWithInt:_nextBatchHandle++];
    FIRWriteBatch *batch = [getFirestore(call.arguments) batch];
    _batches[handle] = batch;
    result(handle);
  } else if ([@"WriteBatch#setData" isEqualToString:call.method]) {
    NSNumber *handle = call.arguments[@"handle"];
    NSDictionary *options = call.arguments[@"options"];
    FIRDocumentReference *document = getDocumentReference(call.arguments);
    FIRWriteBatch *batch = [_batches objectForKey:handle];
    if (![options isEqual:[NSNull null]] &&
        [options[@"merge"] isEqual:[NSNumber numberWithBool:YES]]) {
      [batch setData:call.arguments[@"data"] forDocument:document merge:YES];
    } else {
      [batch setData:call.arguments[@"data"] forDocument:document];
    }
    result(nil);
  } else if ([@"WriteBatch#updateData" isEqualToString:call.method]) {
    NSNumber *handle = call.arguments[@"handle"];
    FIRDocumentReference *document = getDocumentReference(call.arguments);
    FIRWriteBatch *batch = [_batches objectForKey:handle];
    [batch updateData:call.arguments[@"data"] forDocument:document];
    result(nil);
  } else if ([@"WriteBatch#delete" isEqualToString:call.method]) {
    NSNumber *handle = call.arguments[@"handle"];
    FIRDocumentReference *document = getDocumentReference(call.arguments);
    FIRWriteBatch *batch = [_batches objectForKey:handle];
    [batch deleteDocument:document];
    result(nil);
  } else if ([@"WriteBatch#commit" isEqualToString:call.method]) {
    NSNumber *handle = call.arguments[@"handle"];
    FIRWriteBatch *batch = [_batches objectForKey:handle];
    [batch commitWithCompletion:defaultCompletionBlock];
    [_batches removeObjectForKey:handle];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
