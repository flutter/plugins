// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFInstanceManager.h"

@interface FWFInstanceManager ()
@property dispatch_queue_t lockQueue;
@property NSMapTable<NSObject *, NSNumber *> *identifiers;
@property NSMapTable<NSNumber *, NSObject *> *weakInstances;
@property NSMapTable<NSNumber *, NSObject *> *strongInstances;
@end

@implementation FWFInstanceManager
- (instancetype)init {
  if (self) {
    _lockQueue = dispatch_queue_create("FWFInstanceManager", DISPATCH_QUEUE_SERIAL);
    _identifiers = [NSMapTable weakToStrongObjectsMapTable];
    _weakInstances = [NSMapTable strongToWeakObjectsMapTable];
    _strongInstances = [NSMapTable strongToStrongObjectsMapTable];
  }
  return self;
}

- (void)addFlutterCreatedInstance:(NSObject *)instance withIdentifier:(long)instanceIdentifier {
  NSParameterAssert(instance);
  NSParameterAssert(instanceIdentifier >= 0);
  dispatch_async(_lockQueue, ^{
   [self addInstance:instance withIdentifier:instanceIdentifier];
  });
}

- (void)addHostCreatedInstance:(nonnull NSObject *)instance {
  NSParameterAssert(instance);
  dispatch_async(_lockQueue, ^{
    long identifier;
    do {
      identifier = arc4random_uniform(65536) + 65536;
      // TODO: dfg
    } while (YES);
    [self addInstance:instance withIdentifier:identifier];
  });
}

- (nullable NSObject *)removeStrongReferenceWithIdentifier:(long)instanceIdentifier {
  NSObject *__block instance = nil;
  dispatch_sync(_lockQueue, ^{
    instance = [self.strongInstances objectForKey:@(instanceIdentifier)];
    if (instance) {
      [self.strongInstances removeObjectForKey:@(instanceIdentifier)];
    }
  });
  return instance;
}

- (nullable NSObject *)instanceForIdentifier:(long)instanceIdentifier {
  NSObject *__block instance = nil;
  dispatch_sync(_lockQueue, ^{
    instance = [self.weakInstances objectForKey:@(instanceIdentifier)];
  });
  return instance;
}

- (long)identifierForInstance:(nonnull NSObject *)instance identifierWillBePassedToFlutter:(BOOL)willBePassed {
  NSNumber *__block identifierNumber = nil;
  dispatch_sync(_lockQueue, ^{
    identifierNumber = [self.identifiers objectForKey:instance];
    if (identifierNumber && willBePassed) {
      [self.strongInstances setObject:instance forKey:identifierNumber];
    }
  });
  return identifierNumber ? identifierNumber.longValue : NSNotFound;
}

- (void)addInstance:(nonnull NSObject *)instance withIdentifier:(long)instanceIdentifier {
  [self.identifiers setObject:@(instanceIdentifier) forKey:instance];
  [self.weakInstances setObject:instance forKey:@(instanceIdentifier)];
  [self.strongInstances setObject:instance forKey:@(instanceIdentifier)];
  // TODO: Attach associated object.
}
@end
