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
@interface FWFInstanceManager : NSObject
// TODO(bparrishMines): Pairs should not be able to be overwritten and this feature
// should be replaced with a call to clear the manager in the event of a hot restart
// instead.
/**
 * Adds a new instance to the manager that was instantiated by Dart.
 *
 * If an instance or identifier has already been added, it will be replaced by the new values. The
 * Dart InstanceManager is considered the source of truth and has the capability to overwrite stored
 * pairs in response to hot restarts.
 *
 * @param instance The instance to be stored.
 * @param instanceIdentifier The identifier to be paired with instance. This value must be >= 0.
 */
- (void)addDartCreatedInstance:(NSObject *)instance withIdentifier:(long)instanceIdentifier;

/**
 * Removes the instance paired with a given identifier from the manager.
 *
 * @param instanceIdentifier The identifier paired to an instance.
 *
 * @return The removed instance if the manager contains the given instanceIdentifier, otherwise
 * nil.
 */
- (nullable NSObject *)removeInstanceWithIdentifier:(long)instanceIdentifier;

/**
 * Removes the instance from the manager.
 *
 * @param instance The instance to be removed from the manager.
 *
 * @return The identifier of the removed instance if the manager contains the given instance,
 * otherwise NSNotFound.
 */
- (long)removeInstance:(NSObject *)instance;

/**
 * Retrieves the instance paired with identifier.
 *
 * @param instanceIdentifier  The identifier paired to an instance.
 *
 * @return The paired instance if the manager contains the given instanceIdentifier,
 * otherwise nil.
 */
- (nullable NSObject *)instanceForIdentifier:(long)instanceIdentifier;

/**
 * Retrieves the identifier paired with an instance.
 *
 * @param instance An instance that may be stored in the manager.
 *
 * @return The paired identifer if the manager contains the given instance, otherwise NSNotFound.
 */
- (long)identifierForInstance:(NSObject *)instance;
@end

NS_ASSUME_NONNULL_END
