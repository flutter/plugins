// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTWFInstanceManager.h"

@interface FLTThreadSafeMapTable<KeyType, ObjectType> : NSObject
+ (nonnull FLTThreadSafeMapTable *)strongToStrongMapTable;
- (void)setObject:(nonnull ObjectType)object forKey:(nonnull KeyType)key;
- (void)removeObjectForKey:(nonnull KeyType)key;
- (nullable ObjectType)objectForKey:(nonnull KeyType)key;
@end

@implementation FLTThreadSafeMapTable {
  NSMapTable<id, id> *_table;
  dispatch_queue_t _lockQueue;
}

+ (FLTThreadSafeMapTable *)strongToStrongMapTable {
  return [[FLTThreadSafeMapTable alloc] initWithTable:[NSMapTable strongToStrongObjectsMapTable]];
}

- (nonnull instancetype)initWithTable:(NSMapTable *)table {
  self = [super init];
  if (self) {
    _lockQueue = dispatch_queue_create("FLTThreadSafeMapTable", DISPATCH_QUEUE_SERIAL);
    _table = table;
  }
  return self;
}

- (void)setObject:(nonnull id)object forKey:(nonnull id)key {
  if (key && object) {
    dispatch_async(_lockQueue, ^{
      [self->_table setObject:object forKey:key];
    });
  }
}

- (void)removeObjectForKey:(nonnull id)key {
  if (key != nil) {
    dispatch_async(_lockQueue, ^{
      [self->_table removeObjectForKey:key];
    });
  }
}

- (nullable id)objectForKey:(nonnull id)key {
  id __block object = nil;
  dispatch_sync(_lockQueue, ^{
    object = [self->_table objectForKey:key];
  });
  return object;
}
@end

@implementation FLTWFInstanceManager {
  FLTThreadSafeMapTable<NSNumber *, NSObject *> *_instanceIDsToInstances;
  FLTThreadSafeMapTable<NSObject *, NSNumber *> *_instancesToInstanceIDs;
}

- (instancetype)init {
  if (self) {
    _instanceIDsToInstances = [FLTThreadSafeMapTable strongToStrongMapTable];
    _instancesToInstanceIDs = [FLTThreadSafeMapTable strongToStrongMapTable];
  }
  return self;
}

- (void)addInstance:(nonnull NSObject *)instance instanceID:(long)instanceID {
  [_instancesToInstanceIDs setObject:@(instanceID) forKey:instance];
  [_instanceIDsToInstances setObject:instance forKey:@(instanceID)];
}

- (nullable NSObject *)removeInstanceWithID:(long)instanceId {
  NSObject *instance = [_instanceIDsToInstances objectForKey:@(instanceId)];
  if (instance) {
    [_instanceIDsToInstances removeObjectForKey:@(instanceId)];
    [_instancesToInstanceIDs removeObjectForKey:instance];
  }
  return instance;
}

- (nullable NSNumber *)removeInstance:(NSObject *)instance {
  NSNumber *instanceID = [_instancesToInstanceIDs objectForKey:instance];
  if (instanceID) {
    [_instanceIDsToInstances removeObjectForKey:instanceID];
    [_instancesToInstanceIDs removeObjectForKey:instance];
  }
  return instanceID;
}

- (nullable NSObject *)instanceForID:(long)instanceID {
  return [_instanceIDsToInstances objectForKey:@(instanceID)];
}

- (nullable NSNumber *)instanceIDForInstance:(nonnull NSObject *)instance {
  return [_instancesToInstanceIDs objectForKey:instance];
}
@end
