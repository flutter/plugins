// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_list.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group('FirebaseList', () {
    StreamController<Event> onChildAddedStreamController;
    StreamController<Event> onChildRemovedStreamController;
    StreamController<Event> onChildChangedStreamController;
    StreamController<Event> onChildMovedStreamController;
    MockQuery query;
    FirebaseList list;
    Completer<ListChange> callbackCompleter;

    setUp(() {
      onChildAddedStreamController = StreamController<Event>();
      onChildRemovedStreamController = StreamController<Event>();
      onChildChangedStreamController = StreamController<Event>();
      onChildMovedStreamController = StreamController<Event>();
      query = MockQuery(
        onChildAddedStreamController.stream,
        onChildRemovedStreamController.stream,
        onChildChangedStreamController.stream,
        onChildMovedStreamController.stream,
      );
      callbackCompleter = Completer<ListChange>();

      void completeWithChange(int index, DataSnapshot snapshot) {
        callbackCompleter.complete(ListChange.at(index, snapshot));
      }

      void completeWithMove(int from, int to, DataSnapshot snapshot) {
        callbackCompleter.complete(ListChange.move(from, to, snapshot));
      }

      list = FirebaseList(
        query: query,
        onChildAdded: completeWithChange,
        onChildRemoved: completeWithChange,
        onChildChanged: completeWithChange,
        onChildMoved: completeWithMove,
      );
    });

    Future<ListChange> resetCompleterOnCallback() async {
      final ListChange result = await callbackCompleter.future;
      callbackCompleter = Completer<ListChange>();
      return result;
    }

    Future<ListChange> processChildAddedEvent(Event event) {
      onChildAddedStreamController.add(event);
      return resetCompleterOnCallback();
    }

    Future<ListChange> processChildRemovedEvent(Event event) {
      onChildRemovedStreamController.add(event);
      return resetCompleterOnCallback();
    }

    Future<ListChange> processChildChangedEvent(Event event) {
      onChildChangedStreamController.add(event);
      return resetCompleterOnCallback();
    }

    Future<ListChange> processChildMovedEvent(Event event) {
      onChildMovedStreamController.add(event);
      return resetCompleterOnCallback();
    }

    test('can add to empty list', () async {
      final DataSnapshot snapshot = MockDataSnapshot('key10', 10);
      expect(
        await processChildAddedEvent(MockEvent(null, snapshot)),
        ListChange.at(0, snapshot),
      );
      expect(list, <DataSnapshot>[snapshot]);
    });

    test('can add before first element', () async {
      final DataSnapshot snapshot1 = MockDataSnapshot('key10', 10);
      final DataSnapshot snapshot2 = MockDataSnapshot('key20', 20);
      await processChildAddedEvent(MockEvent(null, snapshot2));
      expect(
        await processChildAddedEvent(MockEvent(null, snapshot1)),
        ListChange.at(0, snapshot1),
      );
      expect(list, <DataSnapshot>[snapshot1, snapshot2]);
    });

    test('can add after last element', () async {
      final DataSnapshot snapshot1 = MockDataSnapshot('key10', 10);
      final DataSnapshot snapshot2 = MockDataSnapshot('key20', 20);
      await processChildAddedEvent(MockEvent(null, snapshot1));
      expect(
        await processChildAddedEvent(MockEvent('key10', snapshot2)),
        ListChange.at(1, snapshot2),
      );
      expect(list, <DataSnapshot>[snapshot1, snapshot2]);
    });

    test('can remove from singleton list', () async {
      final DataSnapshot snapshot = MockDataSnapshot('key10', 10);
      await processChildAddedEvent(MockEvent(null, snapshot));
      expect(
        await processChildRemovedEvent(MockEvent(null, snapshot)),
        ListChange.at(0, snapshot),
      );
      expect(list, isEmpty);
    });

    test('can remove former of two elements', () async {
      final DataSnapshot snapshot1 = MockDataSnapshot('key10', 10);
      final DataSnapshot snapshot2 = MockDataSnapshot('key20', 20);
      await processChildAddedEvent(MockEvent(null, snapshot2));
      await processChildAddedEvent(MockEvent(null, snapshot1));
      expect(
        await processChildRemovedEvent(MockEvent(null, snapshot1)),
        ListChange.at(0, snapshot1),
      );
      expect(list, <DataSnapshot>[snapshot2]);
    });

    test('can remove latter of two elements', () async {
      final DataSnapshot snapshot1 = MockDataSnapshot('key10', 10);
      final DataSnapshot snapshot2 = MockDataSnapshot('key20', 20);
      await processChildAddedEvent(MockEvent(null, snapshot2));
      await processChildAddedEvent(MockEvent(null, snapshot1));
      expect(
        await processChildRemovedEvent(MockEvent('key10', snapshot2)),
        ListChange.at(1, snapshot2),
      );
      expect(list, <DataSnapshot>[snapshot1]);
    });

    test('can change child', () async {
      final DataSnapshot snapshot1 = MockDataSnapshot('key10', 10);
      final DataSnapshot snapshot2a = MockDataSnapshot('key20', 20);
      final DataSnapshot snapshot2b = MockDataSnapshot('key20', 25);
      final DataSnapshot snapshot3 = MockDataSnapshot('key30', 30);
      await processChildAddedEvent(MockEvent(null, snapshot3));
      await processChildAddedEvent(MockEvent(null, snapshot2a));
      await processChildAddedEvent(MockEvent(null, snapshot1));
      expect(
        await processChildChangedEvent(MockEvent('key10', snapshot2b)),
        ListChange.at(1, snapshot2b),
      );
      expect(list, <DataSnapshot>[snapshot1, snapshot2b, snapshot3]);
    });
    test('can move child', () async {
      final DataSnapshot snapshot1 = MockDataSnapshot('key10', 10);
      final DataSnapshot snapshot2 = MockDataSnapshot('key20', 20);
      final DataSnapshot snapshot3 = MockDataSnapshot('key30', 30);
      await processChildAddedEvent(MockEvent(null, snapshot3));
      await processChildAddedEvent(MockEvent(null, snapshot2));
      await processChildAddedEvent(MockEvent(null, snapshot1));
      expect(
        await processChildMovedEvent(MockEvent('key30', snapshot1)),
        ListChange.move(0, 2, snapshot1),
      );
      expect(list, <DataSnapshot>[snapshot2, snapshot3, snapshot1]);
    });
  });
}

class MockQuery extends Mock implements Query {
  MockQuery(
    this.onChildAdded,
    this.onChildRemoved,
    this.onChildChanged,
    this.onChildMoved,
  );

  @override
  final Stream<Event> onChildAdded;

  @override
  final Stream<Event> onChildRemoved;

  @override
  final Stream<Event> onChildChanged;

  @override
  final Stream<Event> onChildMoved;
}

class ListChange {
  ListChange.at(int index, DataSnapshot snapshot)
      : this._(index, null, snapshot);

  ListChange.move(int from, int to, DataSnapshot snapshot)
      : this._(from, to, snapshot);

  ListChange._(this.index, this.index2, this.snapshot);

  final int index;
  final int index2;
  final DataSnapshot snapshot;

  @override
  String toString() => '$runtimeType[$index, $index2, $snapshot]';

  @override
  bool operator ==(Object o) {
    return o is ListChange &&
        index == o.index &&
        index2 == o.index2 &&
        snapshot == o.snapshot;
  }

  @override
  int get hashCode => index;
}

class MockEvent implements Event {
  MockEvent(this.previousSiblingKey, this.snapshot);

  @override
  final String previousSiblingKey;

  @override
  final DataSnapshot snapshot;

  @override
  String toString() => '$runtimeType[$previousSiblingKey, $snapshot]';

  @override
  bool operator ==(Object o) {
    return o is MockEvent &&
        previousSiblingKey == o.previousSiblingKey &&
        snapshot == o.snapshot;
  }

  @override
  int get hashCode => previousSiblingKey.hashCode;
}

class MockDataSnapshot implements DataSnapshot {
  MockDataSnapshot(this.key, this.value);

  @override
  final String key;

  @override
  final dynamic value;

  @override
  String toString() => '$runtimeType[$key, $value]';

  @override
  bool operator ==(Object o) {
    return o is MockDataSnapshot && key == o.key && value == o.value;
  }

  @override
  int get hashCode => key.hashCode;
}
