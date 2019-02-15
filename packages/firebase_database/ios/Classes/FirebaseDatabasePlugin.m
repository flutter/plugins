// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebaseDatabasePlugin.h"

#import <Firebase/Firebase.h>

static FlutterError *getFlutterError(NSError *error) {
  return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %d", (int)error.code]
                             message:error.domain
                             details:error.localizedDescription];
}

static NSDictionary *getDictionaryFromError(NSError *error) {
  return @{
    @"code" : @(error.code),
    @"message" : error.domain ?: [NSNull null],
    @"details" : error.localizedDescription ?: [NSNull null],
  };
}

@interface FLTFirebaseDatabasePlugin ()

@end

FIRDatabaseReference *getReference(FIRDatabase *database, NSDictionary *arguments) {
  NSString *path = arguments[@"path"];
  FIRDatabaseReference *ref = database.reference;
  if ([path length] > 0) ref = [ref child:path];
  return ref;
}

FIRDatabaseQuery *getDatabaseQuery(FIRDatabase *database, NSDictionary *arguments) {
  FIRDatabaseQuery *query = getReference(database, arguments);
  NSDictionary *parameters = arguments[@"parameters"];
  NSString *orderBy = parameters[@"orderBy"];
  if ([orderBy isEqualToString:@"child"]) {
    query = [query queryOrderedByChild:parameters[@"orderByChildKey"]];
  } else if ([orderBy isEqualToString:@"key"]) {
    query = [query queryOrderedByKey];
  } else if ([orderBy isEqualToString:@"value"]) {
    query = [query queryOrderedByValue];
  } else if ([orderBy isEqualToString:@"priority"]) {
    query = [query queryOrderedByPriority];
  }
  id startAt = parameters[@"startAt"];
  if (startAt) {
    id startAtKey = parameters[@"startAtKey"];
    if (startAtKey) {
      query = [query queryStartingAtValue:startAt childKey:startAtKey];
    } else {
      query = [query queryStartingAtValue:startAt];
    }
  }
  id endAt = parameters[@"endAt"];
  if (endAt) {
    id endAtKey = parameters[@"endAtKey"];
    if (endAtKey) {
      query = [query queryEndingAtValue:endAt childKey:endAtKey];
    } else {
      query = [query queryEndingAtValue:endAt];
    }
  }
  id equalTo = parameters[@"equalTo"];
  if (equalTo) {
    id equalToKey = parameters[@"equalToKey"];
    if (equalToKey) {
      query = [query queryEqualToValue:equalTo childKey:equalToKey];
    } else {
      query = [query queryEqualToValue:equalTo];
    }
  }
  NSNumber *limitToFirst = parameters[@"limitToFirst"];
  if (limitToFirst) {
    query = [query queryLimitedToFirst:limitToFirst.intValue];
  }
  NSNumber *limitToLast = parameters[@"limitToLast"];
  if (limitToLast) {
    query = [query queryLimitedToLast:limitToLast.intValue];
  }
  return query;
}

FIRDataEventType parseEventType(NSString *eventTypeString) {
  if ([@"_EventType.childAdded" isEqual:eventTypeString]) {
    return FIRDataEventTypeChildAdded;
  } else if ([@"_EventType.childRemoved" isEqual:eventTypeString]) {
    return FIRDataEventTypeChildRemoved;
  } else if ([@"_EventType.childChanged" isEqual:eventTypeString]) {
    return FIRDataEventTypeChildChanged;
  } else if ([@"_EventType.childMoved" isEqual:eventTypeString]) {
    return FIRDataEventTypeChildMoved;
  } else if ([@"_EventType.value" isEqual:eventTypeString]) {
    return FIRDataEventTypeValue;
  }
  assert(false);
  return 0;
}

id roundDoubles(id value) {
  // Workaround for https://github.com/firebase/firebase-ios-sdk/issues/91
  // The Firebase iOS SDK sometimes returns doubles when ints were stored.
  // We detect doubles that can be converted to ints without loss of precision
  // and convert them.
  if ([value isKindOfClass:[NSNumber class]]) {
    CFNumberType type = CFNumberGetType((CFNumberRef)value);
    if (type == kCFNumberDoubleType || type == kCFNumberFloatType) {
      if ((double)(long long)[value doubleValue] == [value doubleValue]) {
        return [NSNumber numberWithLongLong:(long long)[value doubleValue]];
      }
    }
  } else if ([value isKindOfClass:[NSArray class]]) {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[value count]];
    [value enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [result addObject:roundDoubles(obj)];
    }];
    return result;
  } else if ([value isKindOfClass:[NSDictionary class]]) {
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:[value count]];
    [value enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
      result[key] = roundDoubles(obj);
    }];
    return result;
  }
  return value;
}

@interface FLTFirebaseDatabasePlugin ()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end

@implementation FLTFirebaseDatabasePlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_database"
                                  binaryMessenger:[registrar messenger]];
  FLTFirebaseDatabasePlugin *instance = [[FLTFirebaseDatabasePlugin alloc] init];
  instance.channel = channel;
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    if (![FIRApp defaultApp]) {
      [FIRApp configure];
    }
    self.updatedSnapshots = [NSMutableDictionary new];
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  FIRDatabase *database;
  NSString *appName = call.arguments[@"app"];
  NSString *databaseURL = call.arguments[@"databaseURL"];
  if (![appName isEqual:[NSNull null]] && ![databaseURL isEqual:[NSNull null]]) {
    database = [FIRDatabase databaseForApp:[FIRApp appNamed:appName] URL:databaseURL];
  } else if (![appName isEqual:[NSNull null]]) {
    database = [FIRDatabase databaseForApp:[FIRApp appNamed:appName]];
  } else if (![databaseURL isEqual:[NSNull null]]) {
    database = [FIRDatabase databaseWithURL:databaseURL];
  } else {
    database = [FIRDatabase database];
  }
  void (^defaultCompletionBlock)(NSError *, FIRDatabaseReference *) =
      ^(NSError *error, FIRDatabaseReference *ref) {
        result(getFlutterError(error));
      };
  if ([@"FirebaseDatabase#goOnline" isEqualToString:call.method]) {
    [database goOnline];
    result(nil);
  } else if ([@"FirebaseDatabase#goOffline" isEqualToString:call.method]) {
    [database goOffline];
    result(nil);
  } else if ([@"FirebaseDatabase#purgeOutstandingWrites" isEqualToString:call.method]) {
    [database purgeOutstandingWrites];
    result(nil);
  } else if ([@"FirebaseDatabase#setPersistenceEnabled" isEqualToString:call.method]) {
    NSNumber *value = call.arguments[@"enabled"];
    @try {
      database.persistenceEnabled = value.boolValue;
      result([NSNumber numberWithBool:YES]);
    } @catch (NSException *exception) {
      if ([@"FIRDatabaseAlreadyInUse" isEqualToString:exception.name]) {
        // Database is already in use, e.g. after hot reload/restart.
        result([NSNumber numberWithBool:NO]);
      } else {
        @throw;
      }
    }
  } else if ([@"FirebaseDatabase#setPersistenceCacheSizeBytes" isEqualToString:call.method]) {
    NSNumber *value = call.arguments[@"cacheSize"];
    @try {
      database.persistenceCacheSizeBytes = value.unsignedIntegerValue;
      result([NSNumber numberWithBool:YES]);
    } @catch (NSException *exception) {
      if ([@"FIRDatabaseAlreadyInUse" isEqualToString:exception.name]) {
        // Database is already in use, e.g. after hot reload/restart.
        result([NSNumber numberWithBool:NO]);
      } else {
        @throw;
      }
    }
  } else if ([@"DatabaseReference#set" isEqualToString:call.method]) {
    [getReference(database, call.arguments) setValue:call.arguments[@"value"]
                                         andPriority:call.arguments[@"priority"]
                                 withCompletionBlock:defaultCompletionBlock];
  } else if ([@"DatabaseReference#update" isEqualToString:call.method]) {
    [getReference(database, call.arguments) updateChildValues:call.arguments[@"value"]
                                          withCompletionBlock:defaultCompletionBlock];
  } else if ([@"DatabaseReference#setPriority" isEqualToString:call.method]) {
    [getReference(database, call.arguments) setPriority:call.arguments[@"priority"]
                                    withCompletionBlock:defaultCompletionBlock];
  } else if ([@"DatabaseReference#runTransaction" isEqualToString:call.method]) {
    [getReference(database, call.arguments)
        runTransactionBlock:^FIRTransactionResult *_Nonnull(FIRMutableData *_Nonnull currentData) {
          // Create semaphore to allow native side to wait while snapshot
          // updates occur on the Dart side.
          dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

          NSObject *snapshot =
              @{@"key" : currentData.key ?: [NSNull null], @"value" : currentData.value};

          __block bool shouldAbort = false;

          [self.channel invokeMethod:@"DoTransaction"
                           arguments:@{
                             @"transactionKey" : call.arguments[@"transactionKey"],
                             @"snapshot" : snapshot
                           }
                              result:^(id _Nullable result) {
                                if ([result isKindOfClass:[FlutterError class]]) {
                                  FlutterError *flutterError = ((FlutterError *)result);
                                  NSLog(@"Error code: %@", flutterError.code);
                                  NSLog(@"Error message: %@", flutterError.message);
                                  NSLog(@"Error details: %@", flutterError.details);
                                  shouldAbort = true;
                                } else if ([result isEqual:FlutterMethodNotImplemented]) {
                                  NSLog(@"DoTransaction not implemented on the Dart side.");
                                  shouldAbort = true;
                                } else {
                                  [self.updatedSnapshots
                                      setObject:result
                                         forKey:call.arguments[@"transactionKey"]];
                                }
                                dispatch_semaphore_signal(semaphore);
                              }];

          // Wait while Dart side updates the snapshot. Incoming transactionTimeout is in
          // milliseconds so converting to nanoseconds for use with dispatch_semaphore_wait.
          long result = dispatch_semaphore_wait(
              semaphore,
              dispatch_time(DISPATCH_TIME_NOW,
                            [call.arguments[@"transactionTimeout"] integerValue] * 1000000));

          if (result == 0 && !shouldAbort) {
            // Set FIRMutableData value to value returned from the Dart side.
            currentData.value =
                [self.updatedSnapshots objectForKey:call.arguments[@"transactionKey"]][@"value"];
          } else {
            if (result != 0) {
              NSLog(@"Transaction at %@ timed out.", [getReference(database, call.arguments) URL]);
            }
            return [FIRTransactionResult abort];
          }

          return [FIRTransactionResult successWithValue:currentData];
        }
        andCompletionBlock:^(NSError *_Nullable error, BOOL committed,
                             FIRDataSnapshot *_Nullable snapshot) {
          // Invoke transaction completion on the Dart side.
          result(@{
            @"transactionKey" : call.arguments[@"transactionKey"],
            @"error" : getDictionaryFromError(error) ?: [NSNull null],
            @"committed" : [NSNumber numberWithBool:committed],
            @"snapshot" : @{@"key" : snapshot.key ?: [NSNull null], @"value" : snapshot.value}
          });
        }];
  } else if ([@"OnDisconnect#set" isEqualToString:call.method]) {
    [getReference(database, call.arguments) onDisconnectSetValue:call.arguments[@"value"]
                                                     andPriority:call.arguments[@"priority"]
                                             withCompletionBlock:defaultCompletionBlock];
  } else if ([@"OnDisconnect#update" isEqualToString:call.method]) {
    [getReference(database, call.arguments) onDisconnectUpdateChildValues:call.arguments[@"value"]
                                                      withCompletionBlock:defaultCompletionBlock];
  } else if ([@"OnDisconnect#cancel" isEqualToString:call.method]) {
    [getReference(database, call.arguments)
        cancelDisconnectOperationsWithCompletionBlock:defaultCompletionBlock];
  } else if ([@"Query#observe" isEqualToString:call.method]) {
    FIRDataEventType eventType = parseEventType(call.arguments[@"eventType"]);
    __block FIRDatabaseHandle handle = [getDatabaseQuery(database, call.arguments)
        observeEventType:eventType
        andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot *snapshot, NSString *previousSiblingKey) {
          [self.channel invokeMethod:@"Event"
                           arguments:@{
                             @"handle" : [NSNumber numberWithUnsignedInteger:handle],
                             @"snapshot" : @{
                               @"key" : snapshot.key ?: [NSNull null],
                               @"value" : roundDoubles(snapshot.value) ?: [NSNull null],
                             },
                             @"previousSiblingKey" : previousSiblingKey ?: [NSNull null],
                           }];
        }
        withCancelBlock:^(NSError *error) {
          [self.channel invokeMethod:@"Error"
                           arguments:@{
                             @"handle" : [NSNumber numberWithUnsignedInteger:handle],
                             @"error" : getDictionaryFromError(error),
                           }];
        }];
    result([NSNumber numberWithUnsignedInteger:handle]);
  } else if ([@"Query#removeObserver" isEqualToString:call.method]) {
    FIRDatabaseHandle handle = [call.arguments[@"handle"] unsignedIntegerValue];
    [getDatabaseQuery(database, call.arguments) removeObserverWithHandle:handle];
    result(nil);
  } else if ([@"Query#keepSynced" isEqualToString:call.method]) {
    NSNumber *value = call.arguments[@"value"];
    [getDatabaseQuery(database, call.arguments) keepSynced:value.boolValue];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
