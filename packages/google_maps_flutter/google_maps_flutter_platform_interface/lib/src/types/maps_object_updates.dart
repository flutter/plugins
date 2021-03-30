// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show hashValues, hashList;

import 'package:flutter/foundation.dart' show objectRuntimeType, setEquals;

import 'maps_object.dart';
import 'utils/maps_object.dart';

/// Update specification for a set of objects.
class MapsObjectUpdates<T extends MapsObject> {
  /// Computes updates given previous and current object sets.
  ///
  /// [objectName] is the prefix to use when serializing the updates into a JSON
  /// dictionary. E.g., 'circle' will give 'circlesToAdd', 'circlesToUpdate',
  /// 'circleIdsToRemove'.
  MapsObjectUpdates.from(
    Set<T> previous,
    Set<T> current, {
    required this.objectName,
  }) {
    final Map<MapsObjectId<T>, T> previousObjects = keyByMapsObjectId(previous);
    final Map<MapsObjectId<T>, T> currentObjects = keyByMapsObjectId(current);

    final Set<MapsObjectId<T>> previousObjectIds = previousObjects.keys.toSet();
    final Set<MapsObjectId<T>> currentObjectIds = currentObjects.keys.toSet();

    /// Maps an ID back to a [T] in [currentObjects].
    ///
    /// It is a programming error to call this with an ID that is not guaranteed
    /// to be in [currentObjects].
    T _idToCurrentObject(MapsObjectId<T> id) {
      return currentObjects[id]!;
    }

    _objectIdsToRemove = previousObjectIds.difference(currentObjectIds);

    _objectsToAdd = currentObjectIds
        .difference(previousObjectIds)
        .map(_idToCurrentObject)
        .toSet();

    // Returns `true` if [current] is not equals to previous one with the
    // same id.
    bool hasChanged(T current) {
      final T? previous = previousObjects[current.mapsId as MapsObjectId<T>];
      return current != previous;
    }

    _objectsToChange = currentObjectIds
        .intersection(previousObjectIds)
        .map(_idToCurrentObject)
        .where(hasChanged)
        .toSet();
  }

  /// The name of the objects being updated, for use in serialization.
  final String objectName;

  /// Set of objects to be added in this update.
  Set<T> get objectsToAdd {
    return _objectsToAdd;
  }

  late Set<T> _objectsToAdd;

  /// Set of objects to be removed in this update.
  Set<MapsObjectId<T>> get objectIdsToRemove {
    return _objectIdsToRemove;
  }

  late Set<MapsObjectId<T>> _objectIdsToRemove;

  /// Set of objects to be changed in this update.
  Set<T> get objectsToChange {
    return _objectsToChange;
  }

  late Set<T> _objectsToChange;

  /// Converts this object to JSON.
  Object toJson() {
    final Map<String, Object> updateMap = <String, Object>{};

    void addIfNonNull(String fieldName, Object? value) {
      if (value != null) {
        updateMap[fieldName] = value;
      }
    }

    addIfNonNull('${objectName}sToAdd', serializeMapsObjectSet(_objectsToAdd));
    addIfNonNull(
        '${objectName}sToChange', serializeMapsObjectSet(_objectsToChange));
    addIfNonNull(
        '${objectName}IdsToRemove',
        _objectIdsToRemove
            .map<String>((MapsObjectId<T> m) => m.value)
            .toList());

    return updateMap;
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is MapsObjectUpdates &&
        setEquals(_objectsToAdd, other._objectsToAdd) &&
        setEquals(_objectIdsToRemove, other._objectIdsToRemove) &&
        setEquals(_objectsToChange, other._objectsToChange);
  }

  @override
  int get hashCode => hashValues(hashList(_objectsToAdd),
      hashList(_objectIdsToRemove), hashList(_objectsToChange));

  @override
  String toString() {
    return '${objectRuntimeType(this, 'MapsObjectUpdates')}(add: $objectsToAdd, '
        'remove: $objectIdsToRemove, '
        'change: $objectsToChange)';
  }
}
