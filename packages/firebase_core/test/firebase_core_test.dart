// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$FirebaseApp', () {
    final List<MethodCall> log = <MethodCall>[];
    const FirebaseApp testApp = const FirebaseApp(
      name: 'testApp',
    );

    setUp(() async {
      FirebaseApp.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'FirebaseApp#appNamed':
            if (methodCall.arguments != testApp.name) return null;
            return <String, dynamic>{
              'name': testApp.name,
              'options': <String, dynamic>{
                'googleAppID': '12345',
              },
            };
          case 'FirebaseApp#allApps':
            return <Map<String, dynamic>>[
              <String, dynamic>{
                'name': testApp.name,
              },
            ];
          default:
            break;
        }
      });
      log.clear();
    });

    test('configure', () async {
      final String name = 'configuredApp';
      const FirebaseOptions options = const FirebaseOptions(
        apiKey: 'testAPIKey',
        bundleID: 'testBundleID',
        clientID: 'testClientID',
        trackingID: 'testTrackingID',
        gcmSenderID: 'testGCMSenderID',
        projectID: 'testProjectID',
        androidClientID: 'testAndroidClientID',
        googleAppID: 'testGoogleAppID',
        databaseURL: 'testDatabaseURL',
        deepLinkURLScheme: 'testDeepLinkURLScheme',
        storageBucket: 'testStorageBucket',
      );
      await FirebaseApp.configure(
        name: name,
        options: options,
      );
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'FirebaseApp#configure',
            arguments: <String, dynamic>{
              'name': name,
              'options': options.asMap,
            },
          ),
        ],
      );
    });

    test('appNamed', () async {
      final FirebaseApp existingApp = await FirebaseApp.appNamed(testApp.name);
      expect(existingApp.name, equals(testApp.name));
      expect((await existingApp.options).googleAppID, equals('12345'));
      final FirebaseApp missingApp = await FirebaseApp.appNamed('missing');
      expect(missingApp, isNull);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'FirebaseApp#appNamed',
            arguments: testApp.name,
          ),
          isMethodCall(
            'FirebaseApp#appNamed',
            arguments: 'missing',
          ),
        ],
      );
    });

    test('allApps', () async {
      final List<FirebaseApp> allApps = await FirebaseApp.allApps();
      expect(allApps, equals(<FirebaseApp>[testApp]));
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'FirebaseApp#allApps',
            arguments: null,
          ),
        ],
      );
    });
  });
}
