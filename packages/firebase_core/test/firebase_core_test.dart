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
      options: const FirebaseOptions(googleAppID: '12345'),
    );

    setUp(() async {
      FirebaseApp.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'FirebaseApp#allApps':
            return <Map<String, dynamic>>[
              <String, dynamic>{
                'name': testApp.name,
                'options': testApp.options.asMap,
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
      final FirebaseApp app = await FirebaseApp.configure(
        name: name,
        options: options,
      );
      expect(app.name, equals(name));
      expect(app.options, equals(options));
      expect(app, equals(new FirebaseApp.named(app.name)));
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
