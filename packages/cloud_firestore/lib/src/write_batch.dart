// Copyright 2018, the Chromium project authors.  Please see the AUTHORS file
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
  WriteBatch._(this._firestore)
      : _handle = Firestore.channel.invokeMethod(
            'WriteBatch#create', <String, dynamic>{'app': _firestore.app.name});

  final Firestore _firestore;
  Future<dynamic> _handle;
  final List<Future<dynamic>> _actions = <Future<dynamic>>[];

  /// Indicator to whether or not this [WriteBatch] has been committed.
  bool _committed = false;

  /// Commits all of the writes in this write batch as a single atomic unit.
  ///
  /// Calling this method prevents any future operations from being added.
  Future<Null> commit() async {
    if (!_committed) {
      _committed = true;
      await Future.wait<dynamic>(_actions);
      return await Firestore.channel.invokeMethod(
          'WriteBatch#commit', <String, dynamic>{'handle': await _handle});
    } else {
      throw StateError("This batch has already been committed.");
    }
  }

  /// Deletes the document referred to by [document].
  void delete(DocumentReference document) {
    if (!_committed) {
      _handle.then((dynamic handle) {
        _actions.add(
          Firestore.channel.invokeMethod(
            'WriteBatch#delete',
            <String, dynamic>{
              'app': _firestore.app.name,
              'handle': handle,
              'path': document.path,
            },
          ),
        );
      });
    } else {
      throw StateError(
          "This batch has been committed and can no longer be changed.");
    }
  }

  /// Writes to the document referred to by [document].
  ///
  /// If the document does not yet exist, it will be created.
  ///
  /// If [merge] is true, the provided data will be merged into an
  /// existing document instead of overwriting.
  void setData(DocumentReference document, Map<String, dynamic> data,
      {bool merge = false}) {
    if (!_committed) {
      _handle.then((dynamic handle) {
        _actions.add(
          Firestore.channel.invokeMethod(
            'WriteBatch#setData',
            <String, dynamic>{
              'app': _firestore.app.name,
              'handle': handle,
              'path': document.path,
              'data': data,
              'options': <String, bool>{'merge': merge},
            },
          ),
        );
      });
    } else {
      throw StateError(
          "This batch has been committed and can no longer be changed.");
    }
  }

  /// Updates fields in the document referred to by [document].
  ///
  /// If the document does not exist, the operation will fail.
  void updateData(DocumentReference document, Map<String, dynamic> data) {
    if (!_committed) {
      _handle.then((dynamic handle) {
        _actions.add(
          Firestore.channel.invokeMethod(
            'WriteBatch#updateData',
            <String, dynamic>{
              'app': _firestore.app.name,
              'handle': handle,
              'path': document.path,
              'data': data,
            },
          ),
        );
      });
    } else {
      throw StateError(
          "This batch has been committed and can no longer be changed.");
    }
  }
}
