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
    throw UnsupportedError("List cannot be modified.");
  }

  @override
  DocumentSnapshot operator [](int index) =>
      _snapshots.isEmpty ? null : _snapshots[index];

  @override
  void operator []=(int index, DocumentSnapshot value) {
    throw UnsupportedError("List cannot be modified.");
  }

  @override
  void clear() {
    cancelSubscriptions();
    // Do not call super.clear(), it will set the length, it's unsupported.
  }

  void log(String message) {
    if (debug) print("[$TAG] $message");
  }

  int _indexForKey(String key) {
    assert(key != null && key.isNotEmpty);
    return _snapshots
        .indexWhere((DocumentSnapshot item) => item.documentID == key);
  }

  void _onChange(List<DocumentChange> documentChanges) {
    if (documentChanges != null && documentChanges.isNotEmpty) {
      for (DocumentChange change in documentChanges) {
        _onValue(change.document);
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

  void _onData(QuerySnapshot snapshot) {
    if (snapshot != null) {
      _onChange(snapshot.documentChanges);
    }
  }

  void _onDocumentAdded(DocumentChange event) {
    log("Calling _onDocumentAdded for document on index ${event?.newIndex}");
    _snapshots.insert(event.newIndex, event.document);
    onDocumentAdded?.call(event.newIndex, event.document);
  }

  void _onDocumentRemoved(DocumentChange event) {
    try {
      log("Calling _onDocumentRemoved for document on index ${event?.newIndex}");
      _snapshots.removeAt(event.oldIndex);
      onDocumentRemoved?.call(event.oldIndex, event.document);
    } catch (error) {
      log("Failed on removing item on index ${event?.oldIndex}");
    }
  }

  void _onDocumentChanged(DocumentChange event) {
    final int index = _indexForKey(event.document.documentID);
    if (index > -1) {
      log("Calling _onDocumentChanged for document on index ${event?.newIndex}");
      _snapshots[index] = event.document;
      onDocumentChanged?.call(index, event.document);
    }
  }

  DocumentSnapshot _onValue(DocumentSnapshot document) {
    log("Calling onValue for document ${document?.documentID}");
    onValue?.call(document);
    return document;
  }

  void _onError(Object o) {
    final Error error = o;
    onError?.call(error);
  }
}
