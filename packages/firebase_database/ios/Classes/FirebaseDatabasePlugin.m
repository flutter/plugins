// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebaseDatabasePlugin.h"

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

FIRDatabaseReference *getReference(NSDictionary *arguments) {
  NSString *path = arguments[@"path"];
  FIRDatabaseReference *ref = [FIRDatabase database].reference;
  if ([path length] > 0) ref = [ref child:path];
  return ref;
}

FIRDatabaseQuery *getQuery(NSDictionary *arguments) {
  FIRDatabaseQuery *query = getReference(arguments);
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
    query = [query queryEqualToValue:equalTo];
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

@interface FirebaseDatabasePlugin ()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end

@implementation FirebaseDatabasePlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_database"
                                  binaryMessenger:[registrar messenger]];
  FirebaseDatabasePlugin *instance = [[FirebaseDatabasePlugin alloc] init];
  instance.channel = channel;
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
  void (^defaultCompletionBlock)(NSError *, FIRDatabaseReference *) =
      ^(NSError *error, FIRDatabaseReference *ref) {
        result(error.flutterError);
      };
  if ([@"FirebaseDatabase#goOnline" isEqualToString:call.method]) {
    [[FIRDatabase database] goOnline];
    result(nil);
  } else if ([@"FirebaseDatabase#goOffline" isEqualToString:call.method]) {
    [[FIRDatabase database] goOffline];
    result(nil);
  } else if ([@"FirebaseDatabase#purgeOutstandingWrites" isEqualToString:call.method]) {
    [[FIRDatabase database] purgeOutstandingWrites];
    result(nil);
  } else if ([@"FirebaseDatabase#setPersistenceEnabled" isEqualToString:call.method]) {
    NSNumber *value = call.arguments;
    @try {
      [FIRDatabase database].persistenceEnabled = value.boolValue;
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
    NSNumber *value = call.arguments;
    @try {
      [FIRDatabase database].persistenceCacheSizeBytes = value.unsignedIntegerValue;
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
    [getReference(call.arguments) setValue:call.arguments[@"value"]
                               andPriority:call.arguments[@"priority"]
                       withCompletionBlock:defaultCompletionBlock];
  } else if ([@"DatabaseReference#update" isEqualToString:call.method]) {
    [getReference(call.arguments) updateChildValues:call.arguments[@"value"]
                                withCompletionBlock:defaultCompletionBlock];
  } else if ([@"DatabaseReference#setPriority" isEqualToString:call.method]) {
    [getReference(call.arguments) setPriority:call.arguments[@"priority"]
                          withCompletionBlock:defaultCompletionBlock];
  } else if ([@"Query#observe" isEqualToString:call.method]) {
    FIRDataEventType eventType = parseEventType(call.arguments[@"eventType"]);
    __block FIRDatabaseHandle handle = [getQuery(call.arguments)
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
        }];
    result([NSNumber numberWithUnsignedInteger:handle]);
  } else if ([@"Query#removeObserver" isEqualToString:call.method]) {
    FIRDatabaseHandle handle = [call.arguments[@"handle"] unsignedIntegerValue];
    [getQuery(call.arguments) removeObserverWithHandle:handle];
    result(nil);
  } else if ([@"Query#keepSynced" isEqualToString:call.method]) {
    NSNumber *value = call.arguments[@"value"];
    [getQuery(call.arguments) keepSynced:value];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
