// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firestore;

/// The entry point for accessing a Firestore.
///
/// You can get an instance by calling [Firestore.instance].
class Firestore {
  @visibleForTesting
  static const MethodChannel channel = const MethodChannel(
    'firestore',
  );

  static final Map<int, StreamController<QuerySnapshot>> _queryObservers =
      <int, StreamController<QuerySnapshot>>{};

  static final Map<int, StreamController<DocumentSnapshot>> _documentObservers =
      <int, StreamController<DocumentSnapshot>>{};

  Firestore._() {
    channel.setMethodCallHandler((MethodCall call) {
      if (call.method == 'QuerySnapshot') {
        final QuerySnapshot snapshot = new QuerySnapshot._(call.arguments);
        _queryObservers[call.arguments['handle']].add(snapshot);
      } else if (call.method == 'DocumentSnapshot') {
        final DocumentSnapshot snapshot = new DocumentSnapshot._(
          call.arguments,
        );
        _documentObservers[call.arguments['handle']].add(snapshot);
      }
    });
  }

  static Firestore _instance = new Firestore._();

  /// Gets the instance of Firestore for the default Firebase app.
  static Firestore get instance => _instance;

  static void setPersistenceEnabled(bool enabled) {
    Firestore.channel.invokeMethod(
      'Firestore#setPersistenceEnabled',
      <String, dynamic>{'enabled': enabled},
    );
  }

  /// Gets a [CollectionReference] for the specified Firestore path.
  CollectionReference collection(String path,
      {Map<String, dynamic> parameters}) {
    assert(path != null);
    return new CollectionReference._(this, path.split('/'),
        parameters: parameters);
  }

  /// Gets a [DocumentReference] for the specified Firestore path.
  DocumentReference document(String path) {
    assert(path != null);
    return new DocumentReference._(this, path.split('/'));
  }

  Query query(String path,
      {String orderBy,
      int limit,
      bool descending,
      String startAtId,
      String startAfterId,
      String endAtId,
      String endBeforeId}) {
    assert(path != null);
    if ((startAtId != null) ||
        startAfterId != null ||
        endAtId != null ||
        endBeforeId != null ||
        limit != null) {
      assert(orderBy != null);
    }

    Map<String, dynamic> parameters = <String, dynamic>{
      'orderBy': orderBy,
      'limit': limit,
      'descending': descending,
      'startAtId': startAtId,
      'startAfterId': startAfterId,
      'endAtId' : endAtId,
      'endBeforeId' : endBeforeId
    };
    return new Query._(
        firestore: this,
        pathComponents: path.split('/'),
        parameters: parameters);
  }
}
