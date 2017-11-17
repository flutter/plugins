// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firestore;

/// A DocumentSnapshot contains data read from a document in your Firestore
/// database.
///
/// The data can be extracted with the data property or by using subscript
/// syntax to access a specific field.
class DocumentSnapshot {
  /// Contains all the data of this snapshot
  final Map<String, dynamic> data;
  final String id;

  DocumentSnapshot._(Map<String, dynamic> map)
      : this.data = map["data"],
        this.id = map["id"];

  bool get hasData => data != null;

  /// Reads individual values from the snapshot
  dynamic operator [](String key) => data[key];
}
