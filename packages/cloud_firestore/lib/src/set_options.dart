// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// An options object that configures the behavior of [setData()] calls.
///
/// By providing the [SetOptions] objects returned by [merge], the [setData()]
/// calls on [DocumentReference] can be configured to perform granular merges
/// instead of overwriting the target documents in their entirety.
class SetOptions {
  const SetOptions._(this._data);
  final Map<String, dynamic> _data;

  /// Changes the behavior of set() calls to only replace the values specified
  /// in its data argument.
  static const SetOptions merge = const SetOptions._(
    const <String, dynamic>{'merge': true},
  );

  // TODO(jackson): The Android Firestore SDK supports `mergeFieldPaths` and
  // `mergeFields`, but these options don't seem to be available yet on iOS.
}
