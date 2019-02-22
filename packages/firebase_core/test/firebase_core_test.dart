// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$FirebaseApp', () {
    final List<MethodCall> log = <MethodCall>[];
    const FirebaseApp testApp = FirebaseApp(
      name: 'testApp',
    );
    const FirebaseOptions testOptions = FirebaseOptions(
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

    setUp(() async {
      FirebaseApp.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'FirebaseApp#appNamed':
            if (methodCall.arguments != 'testApp') return null;
            return <dynamic, dynamic>{
              'name': 'testApp',
              'options': <dynamic, dynamic>{
                'APIKey': 'testAPIKey',
                'bundleID': 'testBundleID',
                'clientID': 'testClientID',
                'trackingID': 'testTrackingID',
                'GCMSenderID': 'testGCMSenderID',
                'projectID': 'testProjectID',
                'androidClientID': 'testAndroidClientID',
                'googleAppID': 'testGoogleAppID',
                'databaseURL': 'testDatabaseURL',
                'deepLinkURLScheme': 'testDeepLinkURLScheme',
                'storageBucket': 'testStorageBucket',
              },
            };
          case 'FirebaseApp#allApps':
            return <Map<dynamic, dynamic>>[
              <dynamic, dynamic>{
                'name': 'testApp',
              },
            ];
          default:
            return null;
        }
      });
      log.clear();
    });

    test('configure', () async {
      final FirebaseApp reconfiguredApp = await FirebaseApp.configure(
        name: 'testApp',
        options: testOptions,
      );
      expect(reconfiguredApp, equals(testApp));
      final FirebaseApp newApp = await FirebaseApp.configure(
        name: 'newApp',
        options: testOptions,
      );
      expect(newApp.name, equals('newApp'));
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'FirebaseApp#appNamed',
            arguments: 'testApp',
          ),
          isMethodCall(
            'FirebaseApp#appNamed',
            arguments: 'newApp',
          ),
          isMethodCall(
            'FirebaseApp#configure',
            arguments: <String, dynamic>{
              'name': 'newApp',
              'options': testOptions.asMap,
            },
          ),
        ],
      );
    });

    test('appNamed', () async {
      final FirebaseApp existingApp = await FirebaseApp.appNamed('testApp');
      expect(existingApp.name, equals('testApp'));
      expect((await existingApp.options), equals(testOptions));
      final FirebaseApp missingApp = await FirebaseApp.appNamed('missingApp');
      expect(missingApp, isNull);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'FirebaseApp#appNamed',
            arguments: 'testApp',
          ),
          isMethodCall(
            'FirebaseApp#appNamed',
            arguments: 'testApp',
          ),
          isMethodCall(
            'FirebaseApp#appNamed',
            arguments: 'missingApp',
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
