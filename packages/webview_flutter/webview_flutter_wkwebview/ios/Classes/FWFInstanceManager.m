// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFInstanceManager.h"
#import <objc/runtime.h>

// Attaches to an object to receive a callback when the object is deallocated.
@interface FWFFinalizer : NSObject
@property(nonatomic) long identifier;
// Callbacks are no longer made once FWFInstanceManager is inaccessible.
@property(nonatomic, weak) FWFOnDeallocCallback callback;
+ (void)attachToInstance:(NSObject *)instance
          withIdentifier:(long)identifier
                callback:(FWFOnDeallocCallback)callback;
+ (void)detachFromInstance:(NSObject *)instance;
@end

@implementation FWFFinalizer
- (instancetype)initWithIdentifier:(long)identifier callback:(FWFOnDeallocCallback)callback {
  self = [self init];
  if (self) {
    _identifier = identifier;
    _callback = callback;
  }
  return self;
}

+ (void)attachToInstance:(NSObject *)instance
          withIdentifier:(long)identifier
                callback:(FWFOnDeallocCallback)callback {
  FWFFinalizer *finalizer = [[FWFFinalizer alloc] initWithIdentifier:identifier callback:callback];
  objc_setAssociatedObject(instance, _cmd, finalizer, OBJC_ASSOCIATION_RETAIN);
}

+ (void)detachFromInstance:(NSObject *)instance {
  objc_setAssociatedObject(instance, @selector(attachToInstance:withIdentifier:callback:), nil,
                           OBJC_ASSOCIATION_ASSIGN);
}

- (void)dealloc {
  self.callback(self.identifier);
}
@end

@interface FWFInstanceManager ()
@property dispatch_queue_t lockQueue;
@property NSMapTable<NSObject *, NSNumber *> *identifiers;
@property NSMapTable<NSNumber *, NSObject *> *weakInstances;
@property NSMapTable<NSNumber *, NSObject *> *strongInstances;
@property long nextIdentifier;
@end

@implementation FWFInstanceManager
// Identifiers are locked to a specific range to avoid collisions with objects
// created simultaneously by Dart.
// Host uses identifiers >= 2^16 and Dart is expected to use values n where,
// 0 <= n < 2^16.
long const FWFMinHostCreatedIdentifier = 65536;

- (instancetype)initWithDeallocCallback:(FWFOnDeallocCallback)callback {
  self = [self init];
  if (self) {
    _deallocCallback = callback;
    _lockQueue = dispatch_queue_create("FWFInstanceManager", DISPATCH_QUEUE_SERIAL);
    _identifiers = [NSMapTable weakToStrongObjectsMapTable];
    _weakInstances = [NSMapTable strongToWeakObjectsMapTable];
    _strongInstances = [NSMapTable strongToStrongObjectsMapTable];
    _nextIdentifier = FWFMinHostCreatedIdentifier;
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

- (long)addHostCreatedInstance:(nonnull NSObject *)instance {
  NSParameterAssert(instance);
  long __block identifier = -1;
  dispatch_sync(_lockQueue, ^{
    identifier = self.nextIdentifier++;
    [self addInstance:instance withIdentifier:identifier];
  });
  return identifier;
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

- (long)identifierForInstance:(nonnull NSObject *)instance
    identifierWillBePassedToFlutter:(BOOL)willBePassed {
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
  [FWFFinalizer attachToInstance:instance
                  withIdentifier:instanceIdentifier
                        callback:self.deallocCallback];
}

- (NSUInteger)strongInstanceCount {
  NSUInteger __block count = -1;
  dispatch_sync(_lockQueue, ^{
    count = self.strongInstances.count;
  });
  return count;
}

- (NSUInteger)weakInstanceCount {
  NSUInteger __block count = -1;
  dispatch_sync(_lockQueue, ^{
    count = self.weakInstances.count;
  });
  return count;
}
@end
