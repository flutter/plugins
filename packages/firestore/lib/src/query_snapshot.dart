// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firestore;

/// A QuerySnapshot contains zero or more DocumentSnapshot objects.
class QuerySnapshot {

  /// Gets a list of all the documents included in this snapshot
  final List<DocumentSnapshot> documents;

  QuerySnapshot._(List<Map<String, dynamic>> data)
    : documents = new List.generate(data.length, (int index) {
    return new DocumentSnapshot._(data[index]);
  });
}
