// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firestore;

/// Represents a query over the data at a particular location.
class Query {
  Query._({
    @required Firestore firestore,
    @required List<String> pathComponents,
    Map<String, dynamic> parameters
  }): _firestore = firestore,
    _pathComponents = pathComponents,
    _parameters = parameters ?? new Map<String, dynamic>.unmodifiable(<String, dynamic>{}),
    assert(firestore != null);

  final Firestore _firestore;
  final List<String> _pathComponents;
  final Map<String, dynamic> _parameters;

  /// Slash-delimited path representing the database location of this query.
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
    return new Map<String, dynamic>.from(_parameters)..addAll(<String, dynamic>{
      'path': path,
    });
  }

  Stream<QuerySnapshot> get snapshots {
    Future<int> _handle;
    // It's fine to let the StreamController be garbage collected once all the
    // subscribers have cancelled; this analyzer warning is safe to ignore.
    StreamController<QuerySnapshot> controller; // ignore: close_sinks
    controller = new StreamController<QuerySnapshot>.broadcast(
      onListen: () {
        _handle = _firestore._channel.invokeMethod(
          'Query#addSnapshotListener', <String, dynamic>{
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
          await _firestore._channel.invokeMethod(
            'Query#removeListener',
            <String, dynamic>{ 'handle': handle },
          );
          Firestore._queryObservers.remove(handle);
        });
      },
    );
    return controller.stream;
  }

  /// Create a query constrained to only return child nodes with a value greater
  /// than or equal to the given value, using the given orderBy directive or
  /// priority as default, and optionally only child nodes with a key greater
  /// than or equal to the given key.
  Query startAt(dynamic value, { String key }) {
    assert(!_parameters.containsKey('startAt'));
    assert(value is String || value is bool || value is double || value is int);
    final Map<String, dynamic> parameters = <String, dynamic>{ 'startAt': value };
    if (key != null) parameters['startAtKey'] = key;
    return _copyWithParameters(parameters);
  }

  /// Create a query constrained to only return child nodes with a value less
  /// than or equal to the given value, using the given orderBy directive or
  /// priority as default, and optionally only child nodes with a key less
  /// than or equal to the given key.
  Query endAt(dynamic value, { String key }) {
    assert(!_parameters.containsKey('endAt'));
    assert(value is String || value is bool || value is double || value is int);
    final Map<String, dynamic> parameters = <String, dynamic>{ 'endAt': value };
    if (key != null) parameters['endAtKey'] = key;
    return _copyWithParameters(parameters);
  }

  /// Create a query constrained to only return child nodes with the given
  /// `value` (and `key`, if provided).
  ///
  /// If a key is provided, there is at most one such child as names are unique.
  Query equalTo(dynamic value, { String key }) {
    assert(!_parameters.containsKey('equalTo'));
    assert(value is String || value is bool || value is double || value is int);
    return _copyWithParameters(
      <String, dynamic>{ 'equalTo': value, 'equalToKey': key },
    );
  }

  /// Create a query with limit and anchor it to the start of the window.
  Query limitToFirst(int limit) {
    assert(!_parameters.containsKey('limitToFirst'));
    return _copyWithParameters(<String, dynamic>{ 'limitToFirst': limit });
  }

  /// Create a query with limit and anchor it to the end of the window.
  Query limitToLast(int limit) {
    assert(!_parameters.containsKey('limitToLast'));
    return _copyWithParameters(<String, dynamic>{ 'limitToLast': limit });
  }

  /// Generate a view of the data sorted by values of a particular child key.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByChild(String key) {
    assert(key != null);
    assert(!_parameters.containsKey('orderBy'));
    return _copyWithParameters(
      <String, dynamic>{ 'orderBy': 'child', 'orderByChildKey': key },
    );
  }

  /// Generate a view of the data sorted by key.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByKey() {
    assert(!_parameters.containsKey('orderBy'));
    return _copyWithParameters(<String, dynamic>{ 'orderBy': 'key' });
  }

  /// Generate a view of the data sorted by value.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByValue() {
    assert(!_parameters.containsKey('orderBy'));
    return _copyWithParameters(<String, dynamic>{ 'orderBy': 'value' });
  }

  /// Generate a view of the data sorted by priority.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByPriority() {
    assert(!_parameters.containsKey('orderBy'));
    return _copyWithParameters(<String, dynamic>{ 'orderBy': 'priority' });
  }

  /// Obtains a CollectionReference corresponding to this query's location.
  CollectionReference reference() => new CollectionReference._(_firestore, _pathComponents);
}
