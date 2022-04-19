// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Maintains instances to intercommunicate with Dart objects.
 *
 * When an instance is added with an identifier, either can be used to retrieve the other.
 */
@interface FLTWebViewFlutterInstanceManager : NSObject
// TODO(bparrishMines): Pairs should not be able to be overwritten and this feature
// should be replaced with a call to clear the manager in the event of a hot restart
// instead.
/**
 * Adds a new instance to the manager.
 *
 * If an instance or identifier has already been added, it will be replaced by the new values. The
 * Dart InstanceManager is considered the source of truth and has the capability to overwrite stores
 * pairs in response to hot restarts.
 */
- (void)addInstance:(nonnull NSObject *)instance withIdentifier:(long)instanceIdentifier;

/**
 * Removes the instance with identifier from the manager.
 *
 * @returns the removed instance if the manager contains the given instanceIdentifier, otherwise
 * nil.
 */
- (nullable NSObject *)removeInstanceWithIdentifier:(long)instanceIdentifier;

/**
 * Removes the instance from the manager.
 *
 * @returns the identifier of the removed instance if the manager contains the given instance,
 * otherwise -1.
 */
- (long)removeInstance:(NSObject *)instance;

/**
 * Retrieves the instance paired with identifier.
 *
 * @returns the instance paired with instanceIdentifier if the manager contains the given instance,
 * otherwise nil.
 */
- (nullable NSObject *)instanceForIdentifier:(long)instanceIdentifier;

/**
 * Retrieves the identifier paired with an instance.
 *
 * @returns the identifier paired with instance if the manager contains the given identifer,
 * otherwise -1.
 */
- (long)identifierForInstance:(nonnull NSObject *)instance;
@end

NS_ASSUME_NONNULL_END
