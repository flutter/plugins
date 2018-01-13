// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// A [WriteBatch] is a series of write operations to be performed as one unit.
///
/// Operations done on a [WriteBatch] do not take effect until you [commit].
///
/// Once committed, no further operations can be performed on the [WriteBatch],
/// nor can it be committed again.
class WriteBatch {
  WriteBatch()
      : _handle = Firestore.channel.invokeMethod(
          'WriteBatch#create',
        );

  Future<int> _handle;
  final List<Future<Null>> _actions = <Future<Null>>[];

  /// Indicator to whether or not this [WriteBatch] has been committed.
  bool _committed = false;

  /// Processes all operations in this [WriteBatch] and prevents any future
  /// operations from being added.
  Future<Null> commit() async {
    if (!_committed) {
      _committed = true;
      await Future.wait(_actions);
      return await Firestore.channel.invokeMethod(
          'WriteBatch#commit', <String, dynamic>{'handle': await _handle});
    } else {
      throw new StateError("This batch has already been committed.");
    }
  }

  /// Adds a delete operation for the given [DocumentReference].
  void delete(DocumentReference reference) {
    if (!_committed) {
      _handle.then((int handle) {
        _actions.add(
          Firestore.channel.invokeMethod(
            'WriteBatch#delete',
            <String, dynamic>{'handle': handle, 'path': reference.path},
          ),
        );
      });
    } else {
      throw new StateError(
          "This batch has been committed and can no longer be changed.");
    }
  }

  /// Adds a write operation for the given [DocumentReference]. If the document
  /// does not yet exist, it will be created. If you pass [SetOptions], the
  /// provided data will be merged into an existing document.
  void setData(DocumentReference reference, Map<String, dynamic> data,
      [SetOptions options]) {
    if (!_committed) {
      _handle.then((int handle) {
        _actions.add(
          Firestore.channel.invokeMethod(
            'WriteBatch#setData',
            <String, dynamic>{
              'handle': handle,
              'path': reference.path,
              'data': data,
              'options': options?._data,
            },
          ),
        );
      });
    } else {
      throw new StateError(
          "This batch has been committed and can no longer be changed.");
    }
  }

  /// Adds an update operation for the given [DocumentReference].
  ///
  /// If the document doesn't exist yet, the operation will fail.
  void updateData(DocumentReference reference, Map<String, dynamic> data) {
    if (!_committed) {
      _handle.then((int handle) {
        _actions.add(
          Firestore.channel.invokeMethod(
            'WriteBatch#updateData',
            <String, dynamic>{
              'handle': handle,
              'path': reference.path,
              'data': data,
            },
          ),
        );
      });
    } else {
      throw new StateError(
          "This batch has been committed and can no longer be changed.");
    }
  }
}
