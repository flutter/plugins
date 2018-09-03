// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/src/utils/stream_subscriber_mixin.dart';
import 'package:meta/meta.dart';

import '../../cloud_firestore.dart';

typedef void DocumentCallback(int index, DocumentSnapshot snapshot);
typedef void ValueCallback(DocumentSnapshot snapshot);
typedef void ErrorCallback(Error error);

/// Handles [DocumentChange] events, errors and streaming
class FirestoreList extends ListBase<DocumentSnapshot>
    with StreamSubscriberMixin<QuerySnapshot> {
  FirestoreList({
    @required this.query,
    this.onDocumentAdded,
    this.onDocumentRemoved,
    this.onDocumentChanged,
    this.onValue,
    this.onError,
    this.debug = false,
  }) {
    assert(query != null);
    listen(query, _onData, onError: _onError);
  }

  /// Database query used to populate the list
  final Stream<QuerySnapshot> query;

  // Whether or not to show debug logs
  final bool debug;

  static const String TAG = "FIRESTORE_LIST";

  /// Called when the Document has been added
  final DocumentCallback onDocumentAdded;

  /// Called when the Document has been removed
  final DocumentCallback onDocumentRemoved;

  /// Called when the Document has changed
  final DocumentCallback onDocumentChanged;

  /// Called when the data of the list has finished loading
  final ValueCallback onValue;

  /// Called when an error is reported (e.g. permission denied)
  final ErrorCallback onError;

  // ListBase implementation
  final List<DocumentSnapshot> _snapshots = <DocumentSnapshot>[];

  @override
  int get length => _snapshots.length;

  @override
  set length(int value) {
    throw new UnsupportedError("List cannot be modified.");
  }

  @override
  DocumentSnapshot operator [](int index) => _snapshots[index];

  @override
  void operator []=(int index, DocumentSnapshot value) {
    throw new UnsupportedError("List cannot be modified.");
  }

  @override
  void clear() {
    cancelSubscriptions();

    // Do not call super.clear(), it will set the length, it's unsupported.
  }

  void _log(String message) {
    if (debug) print("[$TAG] $message");
  }

  int _indexForKey(String key) {
    assert(key != null);
    for (int index = 0; index < _snapshots.length; index++) {
      if (key == _snapshots[index].documentID) {
        _log("Returning $index from _indexForKey($key)");
        return index;
      }
    }
    return null;
  }

  void _onData(QuerySnapshot snapshot) {
    if (_snapshots.isEmpty) {
      _log("Adding all values from query");
      _snapshots.addAll(snapshot.documents.map(_onValue));
    } else if (snapshot.documentChanges.isNotEmpty) {
      for (DocumentChange change in snapshot.documentChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            _onDocumentAdded(change);
            break;
          case DocumentChangeType.modified:
            _onDocumentChanged(change);
            break;
          case DocumentChangeType.removed:
            _onDocumentRemoved(change);
            break;
        }
      }
    }
  }

  void _onDocumentAdded(DocumentChange event) {
    int index = 0;
    if (event.oldIndex != null) {
      index = event.oldIndex + 1;
    }
    _log("Calling _onDocumentAdded for document ${event.document.documentID}");
    _snapshots.insert(index, event.document);
    onDocumentAdded(index, event.document);
  }

  void _onDocumentRemoved(DocumentChange event) {
    final int index = _indexForKey(event.document.documentID);
    _log(
        "Calling _onDocumentRemoved for document ${event.document.documentID}");
    _snapshots.removeAt(index);
    onDocumentRemoved(index, event.document);
  }

  void _onDocumentChanged(DocumentChange event) {
    final int index = _indexForKey(event.document.documentID);
    _log("Calling onDocumentChanged for document ${event.document.documentID}");
    _snapshots[index] = event.document;
    onDocumentChanged(index, event.document);
  }

  DocumentSnapshot _onValue(DocumentSnapshot document) {
    _log("Calling onValue for document ${document.documentID}");
    onValue(document);
    return document;
  }

  void _onError(Object o) {
    final Error error = o;
    onError?.call(error);
  }
}
