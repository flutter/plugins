// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// The entry point for accessing a Firestore.
///
/// You can get an instance by calling [Firestore.instance].
class Firestore {
  @visibleForTesting
  static const MethodChannel channel = const MethodChannel(
    'plugins.flutter.io/cloud_firestore',
    const FirestoreMethodCodec(),
  );

  static final Map<int, StreamController<QuerySnapshot>> _queryObservers =
      <int, StreamController<QuerySnapshot>>{};

  static final Map<int, StreamController<DocumentSnapshot>> _documentObservers =
      <int, StreamController<DocumentSnapshot>>{};

  Firestore._() {
    channel.setMethodCallHandler((MethodCall call) {
      if (call.method == 'QuerySnapshot') {
        final QuerySnapshot snapshot =
            new QuerySnapshot._(call.arguments, this);
        _queryObservers[call.arguments['handle']].add(snapshot);
      } else if (call.method == 'DocumentSnapshot') {
        final DocumentSnapshot snapshot = new DocumentSnapshot._(
          call.arguments['path'],
          call.arguments['data'],
          this,
        );
        _documentObservers[call.arguments['handle']].add(snapshot);
      }
    });
  }

  static Firestore _instance = new Firestore._();

  /// Gets the instance of Firestore for the default Firebase app.
  static Firestore get instance => _instance;

  /// Gets a [CollectionReference] for the specified Firestore path.
  CollectionReference collection(String path) {
    assert(path != null);
    return new CollectionReference._(this, path.split('/'));
  }

  /// Gets a [DocumentReference] for the specified Firestore path.
  DocumentReference document(String path) {
    assert(path != null);
    return new DocumentReference._(this, path.split('/'));
  }
}

class FieldValue {
  final int type;

  const FieldValue._(this.type);

  @override
  bool operator ==(dynamic o) => o is FieldValue && o.type == type;

  @override
  int get hashCode => type;

  static FieldValue get delete => const FieldValue._(0);

  static FieldValue get serverTimestamp => const FieldValue._(1);
}

class GeoPoint {
  final double latitude;
  final double longitude;
  const GeoPoint(this.latitude, this.longitude);
  
  @override
  bool operator ==(dynamic o) => o is GeoPoint && o.latitude == latitude && o.longitude == longitude;
  
  @override
  int get hashCode => hashValues(latitude, longitude);
}
