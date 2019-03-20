// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// Represents a query over the data at a particular location.
class Query {
  Query._(
      {@required this.firestore,
      @required List<String> pathComponents,
      Map<String, dynamic> parameters})
      : _pathComponents = pathComponents,
        _parameters = parameters ??
            Map<String, dynamic>.unmodifiable(<String, dynamic>{
              'where': List<List<dynamic>>.unmodifiable(<List<dynamic>>[]),
              'orderBy': List<List<dynamic>>.unmodifiable(<List<dynamic>>[]),
            }),
        assert(firestore != null),
        assert(pathComponents != null);

  /// The Firestore instance associated with this query
  final Firestore firestore;

  final List<String> _pathComponents;
  final Map<String, dynamic> _parameters;

  String get _path => _pathComponents.join('/');

  Query _copyWithParameters(Map<String, dynamic> parameters) {
    return Query._(
      firestore: firestore,
      pathComponents: _pathComponents,
      parameters: Map<String, dynamic>.unmodifiable(
        Map<String, dynamic>.from(_parameters)..addAll(parameters),
      ),
    );
  }

  Map<String, dynamic> buildArguments() {
    return Map<String, dynamic>.from(_parameters)
      ..addAll(<String, dynamic>{
        'path': _path,
      });
  }

  /// Notifies of query results at this location
  // TODO(jackson): Reduce code duplication with [DocumentReference]
  Stream<QuerySnapshot> snapshots() {
    Future<int> _handle;
    // It's fine to let the StreamController be garbage collected once all the
    // subscribers have cancelled; this analyzer warning is safe to ignore.
    StreamController<QuerySnapshot> controller; // ignore: close_sinks
    controller = StreamController<QuerySnapshot>.broadcast(
      onListen: () {
        _handle = Firestore.channel.invokeMethod<int>(
          'Query#addSnapshotListener',
          <String, dynamic>{
            'app': firestore.app.name,
            'path': _path,
            'parameters': _parameters,
          },
        ).then<int>((dynamic result) => result);
        _handle.then((int handle) {
          Firestore._queryObservers[handle] = controller;
        });
      },
      onCancel: () {
        _handle.then((int handle) async {
          await Firestore.channel.invokeMethod<void>(
            'Query#removeListener',
            <String, dynamic>{'handle': handle},
          );
          Firestore._queryObservers.remove(handle);
        });
      },
    );
    return controller.stream;
  }

  /// Fetch the documents for this query
  Future<QuerySnapshot> getDocuments() async {
    final Map<String, dynamic> data =
        await Firestore.channel.invokeMapMethod<String, dynamic>(
      'Query#getDocuments',
      <String, dynamic>{
        'app': firestore.app.name,
        'path': _path,
        'parameters': _parameters,
      },
    );
    return QuerySnapshot._(data, firestore);
  }

  /// Obtains a CollectionReference corresponding to this query's location.
  CollectionReference reference() =>
      CollectionReference._(firestore, _pathComponents);

  /// Creates and returns a new [Query] with additional filter on specified
  /// [field]. [field] refers to a field in a document.
  ///
  /// The [field] may consist of a single field name (referring to a top level
  /// field in the document), or a series of field names seperated by dots '.'
  /// (referring to a nested field in the document).
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
    dynamic arrayContains,
    bool isNull,
  }) {
    final ListEquality<dynamic> equality = const ListEquality<dynamic>();
    final List<List<dynamic>> conditions =
        List<List<dynamic>>.from(_parameters['where']);

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
    if (arrayContains != null)
      addCondition(field, 'array-contains', arrayContains);
    if (isNull != null) {
      assert(
          isNull,
          'isNull can only be set to true. '
          'Use isEqualTo to filter on non-null values.');
      addCondition(field, '==', null);
    }

    return _copyWithParameters(<String, dynamic>{'where': conditions});
  }

  /// Creates and returns a new [Query] that's additionally sorted by the specified
  /// [field].
  Query orderBy(String field, {bool descending = false}) {
    final List<List<dynamic>> orders =
        List<List<dynamic>>.from(_parameters['orderBy']);

    final List<dynamic> order = <dynamic>[field, descending];
    assert(orders.where((List<dynamic> item) => field == item[0]).isEmpty,
        'OrderBy $field already exists in this query');
    orders.add(order);
    return _copyWithParameters(<String, dynamic>{'orderBy': orders});
  }

  /// Takes a list of [values], creates and returns a new [Query] that starts after
  /// the provided fields relative to the order of the query.
  ///
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [startAt].
  Query startAfter(List<dynamic> values) {
    assert(values != null);
    assert(!_parameters.containsKey('startAfter'));
    assert(!_parameters.containsKey('startAt'));
    return _copyWithParameters(<String, dynamic>{'startAfter': values});
  }

  /// Takes a list of [values], creates and returns a new [Query] that starts at
  /// the provided fields relative to the order of the query.
  ///
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [startAfter].
  Query startAt(List<dynamic> values) {
    assert(values != null);
    assert(!_parameters.containsKey('startAfter'));
    assert(!_parameters.containsKey('startAt'));
    return _copyWithParameters(<String, dynamic>{'startAt': values});
  }

  /// Takes a list of [values], creates and returns a new [Query] that ends at the
  /// provided fields relative to the order of the query.
  ///
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [endBefore].
  Query endAt(List<dynamic> values) {
    assert(values != null);
    assert(!_parameters.containsKey('endBefore'));
    assert(!_parameters.containsKey('endAt'));
    return _copyWithParameters(<String, dynamic>{'endAt': values});
  }

  /// Takes a list of [values], creates and returns a new [Query] that ends before
  /// the provided fields relative to the order of the query.
  ///
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [endAt].
  Query endBefore(List<dynamic> values) {
    assert(values != null);
    assert(!_parameters.containsKey('endBefore'));
    assert(!_parameters.containsKey('endAt'));
    return _copyWithParameters(<String, dynamic>{'endBefore': values});
  }

  /// Creates and returns a new Query that's additionally limited to only return up
  /// to the specified number of documents.
  Query limit(int length) {
    assert(!_parameters.containsKey('limit'));
    return _copyWithParameters(<String, dynamic>{'limit': length});
  }
}
