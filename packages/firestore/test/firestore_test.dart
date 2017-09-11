// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:test/test.dart';

import 'package:flutter/services.dart';

import 'package:firebase_firestore/firestore.dart';

void main() {
  group('$Firestore', () {
    const MethodChannel channel = const MethodChannel(
      'plugins.flutter.io/firebase_firestore',
    );

    int mockHandleId = 0;
    final Firestore firestore = Firestore.instance;
    final List<MethodCall> log = <MethodCall>[];
    final CollectionReference collectionReference = firestore.collection('foo');

    setUp(() async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch(methodCall.method) {
          case 'Query#addQueryObserver':
            return mockHandleId++;
          case 'DocumentReference#setData':
            return true;
          default:
            return null;
        }
      });
      log.clear();
    });

    // TODO(arthurthompson): make group for CollectionsReference
    test('listen', () async {
      final StreamSubscription<QuerySnapshot> subscription =
          collectionReference.snapshots.listen((QuerySnapshot querySnapshot) {});
      subscription.cancel();
      await new Future.delayed(Duration.ZERO);
      expect(
        log,
        equals(<MethodCall>[
          new MethodCall(
              'Query#addQueryObserver',
              <String, dynamic> {
                'path': 'foo',
                'parameters': {}
              }
          ),
          new MethodCall(
              'Query#removeQueryObserver',
              <String, dynamic> {
                'handle': 0
              }
          )
        ])
      );
    });

    test('set', () async {
      await collectionReference.document('bar').setData(<String, String>{'bazKey': 'quxValue'});
      expect(
        log,
        equals(<MethodCall>[
          new MethodCall(
            'DocumentReference#setData',
            <String, dynamic> {
              'path': 'foo/bar',
              'data': {
                'bazKey': 'quxValue'
              }
            }
          )
        ])
      );
    });
  });
}
