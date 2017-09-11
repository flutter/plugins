// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firestore;

/// A FIRDocumentSnapshot contains data read from a document in your Firestore
/// database.
///
/// The data can be extracted with the data property or by using subscript
/// syntax to access a specific field.
class DocumentSnapshot {

  /// Gets a list of all the documents included in this snapshot
  final Map<String, dynamic> data;

  DocumentSnapshot._(this.data);

  dynamic operator[](String key) => data[key];
}
