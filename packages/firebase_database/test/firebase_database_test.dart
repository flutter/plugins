// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$FirebaseDatabase', () {
    const MethodChannel channel = MethodChannel(
      'plugins.flutter.io/firebase_database',
    );

    int mockHandleId = 0;
    final List<MethodCall> log = <MethodCall>[];
    final FirebaseApp app = const FirebaseApp(
      name: 'testApp',
    );
    final String databaseURL = 'https://fake-database-url2.firebaseio.com';
    final FirebaseDatabase database =
        FirebaseDatabase(app: app, databaseURL: databaseURL);

    setUp(() async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'Query#observe':
            return mockHandleId++;
          case 'FirebaseDatabase#setPersistenceEnabled':
            return true;
          case 'FirebaseDatabase#setPersistenceCacheSizeBytes':
            return true;
          case 'DatabaseReference#runTransaction':
            Map<String, dynamic> updatedValue;
            Future<void> simulateEvent(
                int transactionKey, final MutableData mutableData) async {
              await BinaryMessages.handlePlatformMessage(
                channel.name,
                channel.codec.encodeMethodCall(
                  MethodCall(
                    'DoTransaction',
                    <String, dynamic>{
                      'transactionKey': transactionKey,
                      'snapshot': <String, dynamic>{
                        'key': mutableData.key,
                        'value': mutableData.value,
                      },
                    },
                  ),
                ),
                (_) {
                  updatedValue = channel.codec
                      .decodeEnvelope(_)['value']
                      .cast<String, dynamic>();
                },
              );
            }

            await simulateEvent(
                0,
                MutableData.private(<String, dynamic>{
                  'key': 'fakeKey',
                  'value': <String, dynamic>{'fakeKey': 'fakeValue'},
                }));

            return <String, dynamic>{
              'error': null,
              'committed': true,
              'snapshot': <String, dynamic>{
                'key': 'fakeKey',
                'value': updatedValue,
              }
            };
          default:
            return null;
        }
      });
      log.clear();
    });

    test('setPersistenceEnabled', () async {
      expect(await database.setPersistenceEnabled(false), true);
      expect(await database.setPersistenceEnabled(true), true);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'FirebaseDatabase#setPersistenceEnabled',
            arguments: <String, dynamic>{
              'app': app.name,
              'databaseURL': databaseURL,
              'enabled': false,
            },
          ),
          isMethodCall(
            'FirebaseDatabase#setPersistenceEnabled',
            arguments: <String, dynamic>{
              'app': app.name,
              'databaseURL': databaseURL,
              'enabled': true,
            },
          ),
        ],
      );
    });

    test('setPersistentCacheSizeBytes', () async {
      expect(await database.setPersistenceCacheSizeBytes(42), true);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'FirebaseDatabase#setPersistenceCacheSizeBytes',
            arguments: <String, dynamic>{
              'app': app.name,
              'databaseURL': databaseURL,
              'cacheSize': 42,
            },
          ),
        ],
      );
    });

    test('goOnline', () async {
      await database.goOnline();
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'FirebaseDatabase#goOnline',
            arguments: <String, dynamic>{
              'app': app.name,
              'databaseURL': databaseURL,
            },
          ),
        ],
      );
    });

    test('goOffline', () async {
      await database.goOffline();
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'FirebaseDatabase#goOffline',
            arguments: <String, dynamic>{
              'app': app.name,
              'databaseURL': databaseURL,
            },
          ),
        ],
      );
    });

    test('purgeOutstandingWrites', () async {
      await database.purgeOutstandingWrites();
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'FirebaseDatabase#purgeOutstandingWrites',
            arguments: <String, dynamic>{
              'app': app.name,
              'databaseURL': databaseURL,
            },
          ),
        ],
      );
    });

    group('$DatabaseReference', () {
      test('set', () async {
        final dynamic value = <String, dynamic>{'hello': 'world'};
        final int priority = 42;
        await database.reference().child('foo').set(value);
        await database.reference().child('bar').set(value, priority: priority);
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'DatabaseReference#set',
              arguments: <String, dynamic>{
                'app': app.name,
                'databaseURL': databaseURL,
                'path': 'foo',
                'value': value,
                'priority': null,
              },
            ),
            isMethodCall(
              'DatabaseReference#set',
              arguments: <String, dynamic>{
                'app': app.name,
                'databaseURL': databaseURL,
                'path': 'bar',
                'value': value,
                'priority': priority,
              },
            ),
          ],
        );
      });
      test('update', () async {
        final dynamic value = <String, dynamic>{'hello': 'world'};
        await database.reference().child("foo").update(value);
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'DatabaseReference#update',
              arguments: <String, dynamic>{
                'app': app.name,
                'databaseURL': databaseURL,
                'path': 'foo',
                'value': value,
              },
            ),
          ],
        );
      });

      test('setPriority', () async {
        final int priority = 42;
        await database.reference().child('foo').setPriority(priority);
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'DatabaseReference#setPriority',
              arguments: <String, dynamic>{
                'app': app.name,
                'databaseURL': databaseURL,
                'path': 'foo',
                'priority': priority,
              },
            ),
          ],
        );
      });

      test('runTransaction', () async {
        final TransactionResult transactionResult = await database
            .reference()
            .child('foo')
            .runTransaction((MutableData mutableData) {
          return Future<MutableData>(() {
            mutableData.value['fakeKey'] =
                'updated ' + mutableData.value['fakeKey'];
            return mutableData;
          });
        });
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'DatabaseReference#runTransaction',
              arguments: <String, dynamic>{
                'app': app.name,
                'databaseURL': databaseURL,
                'path': 'foo',
                'transactionKey': 0,
                'transactionTimeout': 5000,
              },
            ),
          ],
        );
        expect(transactionResult.committed, equals(true));
        expect(transactionResult.dataSnapshot.value,
            equals(<String, dynamic>{'fakeKey': 'updated fakeValue'}));
        expect(
          database.reference().child('foo').runTransaction(
                (MutableData mutableData) async => null,
                timeout: const Duration(milliseconds: 0),
              ),
          throwsA(isInstanceOf<AssertionError>()),
        );
      });
    });

    group('$OnDisconnect', () {
      test('set', () async {
        final dynamic value = <String, dynamic>{'hello': 'world'};
        final int priority = 42;
        final DatabaseReference ref = database.reference();
        await ref.child('foo').onDisconnect().set(value);
        await ref.child('bar').onDisconnect().set(value, priority: priority);
        await ref.child('psi').onDisconnect().set(value, priority: 'priority');
        await ref.child('por').onDisconnect().set(value, priority: value);
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'OnDisconnect#set',
              arguments: <String, dynamic>{
                'app': app.name,
                'databaseURL': databaseURL,
                'path': 'foo',
                'value': value,
                'priority': null,
              },
            ),
            isMethodCall(
              'OnDisconnect#set',
              arguments: <String, dynamic>{
                'app': app.name,
                'databaseURL': databaseURL,
                'path': 'bar',
                'value': value,
                'priority': priority,
              },
            ),
            isMethodCall(
              'OnDisconnect#set',
              arguments: <String, dynamic>{
                'app': app.name,
                'databaseURL': databaseURL,
                'path': 'psi',
                'value': value,
                'priority': 'priority',
              },
            ),
            isMethodCall(
              'OnDisconnect#set',
              arguments: <String, dynamic>{
                'app': app.name,
                'databaseURL': databaseURL,
                'path': 'por',
                'value': value,
                'priority': value,
              },
            ),
          ],
        );
      });
      test('update', () async {
        final dynamic value = <String, dynamic>{'hello': 'world'};
        await database.reference().child("foo").onDisconnect().update(value);
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'OnDisconnect#update',
              arguments: <String, dynamic>{
                'app': app.name,
                'databaseURL': databaseURL,
                'path': 'foo',
                'value': value,
              },
            ),
          ],
        );
      });
      test('cancel', () async {
        await database.reference().child("foo").onDisconnect().cancel();
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'OnDisconnect#cancel',
              arguments: <String, dynamic>{
                'app': app.name,
                'databaseURL': databaseURL,
                'path': 'foo',
              },
            ),
          ],
        );
      });
      test('remove', () async {
        await database.reference().child("foo").onDisconnect().remove();
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'OnDisconnect#set',
              arguments: <String, dynamic>{
                'app': app.name,
                'databaseURL': databaseURL,
                'path': 'foo',
                'value': null,
                'priority': null,
              },
            ),
          ],
        );
      });
    });

    group('$Query', () {
      // TODO(jackson): Write more tests for queries
      test('keepSynced, simple query', () async {
        final String path = 'foo';
        final Query query = database.reference().child(path);
        await query.keepSynced(true);
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'Query#keepSynced',
              arguments: <String, dynamic>{
                'app': app.name,
                'databaseURL': databaseURL,
                'path': path,
                'parameters': <String, dynamic>{},
                'value': true,
              },
            ),
          ],
        );
      });
      test('keepSynced, complex query', () async {
        final int startAt = 42;
        final String path = 'foo';
        final String childKey = 'bar';
        final bool endAt = true;
        final String endAtKey = 'baz';
        final Query query = database
            .reference()
            .child(path)
            .orderByChild(childKey)
            .startAt(startAt)
            .endAt(endAt, key: endAtKey);
        await query.keepSynced(false);
        final Map<String, dynamic> expectedParameters = <String, dynamic>{
          'orderBy': 'child',
          'orderByChildKey': childKey,
          'startAt': startAt,
          'endAt': endAt,
          'endAtKey': endAtKey,
        };
        expect(
          log,
          <Matcher>[
            isMethodCall(
              'Query#keepSynced',
              arguments: <String, dynamic>{
                'app': app.name,
                'databaseURL': databaseURL,
                'path': path,
                'parameters': expectedParameters,
                'value': false
              },
            ),
          ],
        );
      });
      test('observing error events', () async {
        mockHandleId = 99;
        const int errorCode = 12;
        const String errorDetails = 'Some details';
        final Query query = database.reference().child('some path');
        Future<void> simulateError(String errorMessage) async {
          await BinaryMessages.handlePlatformMessage(
            channel.name,
            channel.codec.encodeMethodCall(
              MethodCall('Error', <String, dynamic>{
                'handle': 99,
                'error': <String, dynamic>{
                  'code': errorCode,
                  'message': errorMessage,
                  'details': errorDetails,
                },
              }),
            ),
            (_) {},
          );
        }

        final AsyncQueue<DatabaseError> errors = AsyncQueue<DatabaseError>();

        // Subscribe and allow subscription to complete.
        final StreamSubscription<Event> subscription =
            query.onValue.listen((_) {}, onError: errors.add);
        await Future<void>.delayed(const Duration(seconds: 0));

        await simulateError('Bad foo');
        await simulateError('Bad bar');
        final DatabaseError error1 = await errors.remove();
        final DatabaseError error2 = await errors.remove();
        subscription.cancel();
        expect(error1.toString(), 'DatabaseError(12, Bad foo, Some details)');
        expect(error1.code, errorCode);
        expect(error1.message, 'Bad foo');
        expect(error1.details, errorDetails);
        expect(error2.code, errorCode);
        expect(error2.message, 'Bad bar');
        expect(error2.details, errorDetails);
      });
      test('observing value events', () async {
        mockHandleId = 87;
        final String path = 'foo';
        final Query query = database.reference().child(path);
        Future<void> simulateEvent(String value) async {
          await BinaryMessages.handlePlatformMessage(
            channel.name,
            channel.codec.encodeMethodCall(
              MethodCall('Event', <String, dynamic>{
                'handle': 87,
                'snapshot': <String, dynamic>{
                  'key': path,
                  'value': value,
                },
              }),
            ),
            (_) {},
          );
        }

        final AsyncQueue<Event> events = AsyncQueue<Event>();

        // Subscribe and allow subscription to complete.
        final StreamSubscription<Event> subscription =
            query.onValue.listen(events.add);
        await Future<void>.delayed(const Duration(seconds: 0));

        await simulateEvent('1');
        await simulateEvent('2');
        final Event event1 = await events.remove();
        final Event event2 = await events.remove();
        expect(event1.snapshot.key, path);
        expect(event1.snapshot.value, '1');
        expect(event2.snapshot.key, path);
        expect(event2.snapshot.value, '2');

        // Cancel subscription and allow cancellation to complete.
        subscription.cancel();
        await Future<void>.delayed(const Duration(seconds: 0));

        expect(
          log,
          <Matcher>[
            isMethodCall(
              'Query#observe',
              arguments: <String, dynamic>{
                'app': app.name,
                'databaseURL': databaseURL,
                'path': path,
                'parameters': <String, dynamic>{},
                'eventType': '_EventType.value',
              },
            ),
            isMethodCall(
              'Query#removeObserver',
              arguments: <String, dynamic>{
                'app': app.name,
                'databaseURL': databaseURL,
                'path': path,
                'parameters': <String, dynamic>{},
                'handle': 87,
              },
            ),
          ],
        );
      });
    });
  });
}

/// Queue whose remove operation is asynchronous, awaiting a corresponding add.
class AsyncQueue<T> {
  Map<int, Completer<T>> _completers = <int, Completer<T>>{};
  int _nextToRemove = 0;
  int _nextToAdd = 0;

  void add(T element) {
    _completer(_nextToAdd++).complete(element);
  }

  Future<T> remove() {
    return _completer(_nextToRemove++).future;
  }

  Completer<T> _completer(int index) {
    if (_completers.containsKey(index)) {
      return _completers.remove(index);
    } else {
      return _completers[index] = Completer<T>();
    }
  }
}
