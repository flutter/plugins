// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// An enumeration of firestore source types.
enum Source {
  /// Causes Firestore to try to retrieve an up-to-date (server-retrieved) snapshot, but fall back to
  /// returning cached data if the server can't be reached.
  serverAndCache,

  /// Causes Firestore to avoid the cache, generating an error if the server cannot be reached. Note
  /// that the cache will still be updated if the server request succeeds. Also note that
  /// latency-compensation still takes effect, so any pending write operations will be visible in the
  /// returned data (merged into the server-provided data).
  server,

  /// Causes Firestore to immediately return a value from the cache, ignoring the server completely
  /// (implying that the returned value may be stale with respect to the value on the server). If
  /// there is no data in the cache to satisfy the [get()] or [getDocuments()] call,
  /// [DocumentReference.get()] will return an error and [Query.getDocuments()] will return an empty
  /// [QuerySnapshot] with no documents.
  cache,
}

/// Converts [Source] to [String]
String _getSourceString(Source source) {
  assert(source != null);
  if (source == Source.server) {
    return 'server';
  }
  if (source == Source.cache) {
    return 'cache';
  }
  return 'default';
}
