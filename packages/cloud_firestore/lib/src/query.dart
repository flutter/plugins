// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// Represents a query over the data at a particular location.
class Query {
  Query._(
      {@required Firestore firestore,
      @required List<String> pathComponents,
      Map<String, dynamic> parameters})
      : _firestore = firestore,
        _pathComponents = pathComponents,
        _parameters = parameters ??
            new Map<String, dynamic>.unmodifiable(<String, dynamic>{
              'where': new List<List<dynamic>>.unmodifiable(<List<dynamic>>[]),
            }),
        assert(firestore != null),
        assert(pathComponents != null);

  final Firestore _firestore;
  final List<String> _pathComponents;
  final Map<String, dynamic> _parameters;

  /// A string containing the slash-separated path to this Query (relative to
  /// the root of the database).
  String get path => _pathComponents.join('/');

  Query _copyWithParameters(Map<String, dynamic> parameters) {
    return new Query._(
      firestore: _firestore,
      pathComponents: _pathComponents,
      parameters: new Map<String, dynamic>.unmodifiable(
        new Map<String, dynamic>.from(_parameters)..addAll(parameters),
      ),
    );
  }

  Map<String, dynamic> buildArguments() {
    return new Map<String, dynamic>.from(_parameters)
      ..addAll(<String, dynamic>{
        'path': path,
      });
  }

  /// Notifies of query results at this location
  // TODO(jackson): Reduce code duplication with [DocumentReference]
  Stream<QuerySnapshot> get snapshots {
    Future<int> _handle;
    // It's fine to let the StreamController be garbage collected once all the
    // subscribers have cancelled; this analyzer warning is safe to ignore.
    StreamController<QuerySnapshot> controller; // ignore: close_sinks
    controller = new StreamController<QuerySnapshot>.broadcast(
      onListen: () {
        _handle = Firestore.channel.invokeMethod(
          'Query#addSnapshotListener',
          <String, dynamic>{
            'path': path,
            'parameters': _parameters,
          },
        );
        _handle.then((int handle) {
          Firestore._queryObservers[handle] = controller;
        });
      },
      onCancel: () {
        _handle.then((int handle) async {
          await Firestore.channel.invokeMethod(
            'Query#removeListener',
            <String, dynamic>{'handle': handle},
          );
          Firestore._queryObservers.remove(handle);
        });
      },
    );
    return controller.stream;
  }

  /// Obtains a CollectionReference corresponding to this query's location.
  CollectionReference reference() =>
      new CollectionReference._(_firestore, _pathComponents);

  /// Creates and returns a new [Query] with additional filter on specified
  /// [field].
  ///
  /// Only documents satisfying provided condition are included in the result
  /// set.
  Query where(
    String field, {
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
  }) {
    final ListEquality<dynamic> equality = const ListEquality<dynamic>();
    final List<List<dynamic>> conditions =
        new List<List<dynamic>>.from(_parameters['where']);

    void addCondition(String field, String operator, dynamic value) {
      final List<dynamic> condition = <dynamic>[field, operator, value];
      assert(
          conditions
              .where((List<dynamic> item) => equality.equals(condition, item))
              .isEmpty,
          'Condition $condition already exists in this query.');
      conditions.add(condition);
    }

    if (isEqualTo != null) addCondition(field, '==', isEqualTo);
    if (isLessThan != null) addCondition(field, '<', isLessThan);
    if (isLessThanOrEqualTo != null)
      addCondition(field, '<=', isLessThanOrEqualTo);
    if (isGreaterThan != null) addCondition(field, '>', isGreaterThan);
    if (isGreaterThanOrEqualTo != null)
      addCondition(field, '>=', isGreaterThanOrEqualTo);

    return _copyWithParameters(<String, dynamic>{'where': conditions});
  }

  /// Creates and returns a new [Query] that's additionally sorted by the specified
  /// [field].
  Query orderBy(String field, {bool descending: false}) {
    assert(!_parameters.containsKey('orderBy'));
    return _copyWithParameters(<String, dynamic>{
      'orderBy': <dynamic>[field, descending]
    });
  }
}
