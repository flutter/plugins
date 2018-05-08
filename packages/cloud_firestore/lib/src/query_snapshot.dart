// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// A QuerySnapshot contains zero or more DocumentSnapshot objects.
class QuerySnapshot {
  /// All the documents included in this snapshot.
  final List<DocumentSnapshot> documents;

  /// An array of the documents that changed since the last snapshot.
  ///
  /// If this is the first snapshot, all documents will be in the list as Added
  /// changes.
  final List<DocumentChange> documentChanges;

  /// Metadata about this snapshot, concerning its source and if it has local
  /// modifications.
  final SnapshotMetadata metadata;

  /// The number of documents.
  int get size => documents.length;

  /// The [Query] you used to get this.
  final Query query;

  QuerySnapshot._(Map<dynamic, dynamic> data, this.query)
      : documents = new List<DocumentSnapshot>.generate(
            data['documents'].length, (int index) {
          final Map<dynamic, dynamic> document = data['documents'][index];
          return new DocumentSnapshot._(document, query.firestore);
        }),
        documentChanges = new List<DocumentChange>.generate(
            data['documentChanges'].length, (int index) {
          return new DocumentChange._(
            data['documentChanges'][index],
            query,
          );
        }),
        metadata = new SnapshotMetadata._(data['metadata']);
}
