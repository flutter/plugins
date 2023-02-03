// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/src/channel.dart';

import '../stub_in_app_purchase_platform.dart';
import 'purchase_wrapper_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final StubInAppPurchasePlatform stubPlatform = StubInAppPurchasePlatform();
  late BillingClientManager manager;
  late Completer<void> connectedCompleter;

  const String startConnectionCall =
      'BillingClient#startConnection(BillingClientStateListener)';
  const String endConnectionCall = 'BillingClient#endConnection()';
  const String onBillingServiceDisconnectedCallback =
      'BillingClientStateListener#onBillingServiceDisconnected()';

  setUpAll(() =>
      channel.setMockMethodCallHandler(stubPlatform.fakeMethodCallHandler));

  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
    connectedCompleter = Completer<void>.sync();
    stubPlatform.addResponse(
      name: startConnectionCall,
      value: buildBillingResultMap(
        const BillingResultWrapper(responseCode: BillingResponse.ok),
      ),
      additionalStepBeforeReturn: (dynamic _) => connectedCompleter.future,
    );
    stubPlatform.addResponse(name: endConnectionCall);
    manager = BillingClientManager();
  });

  tearDown(() => stubPlatform.reset());

  group('BillingClientWrapper', () {
    test('connects on initialization', () {
      expect(stubPlatform.countPreviousCalls(startConnectionCall), equals(1));
    });

    test('waits for connection before executing the operations', () {
      bool runCalled = false;
      bool runRawCalled = false;
      manager.run((BillingClient _) async {
        runCalled = true;
        return const BillingResultWrapper(responseCode: BillingResponse.ok);
      });
      manager.runRaw((BillingClient _) async => runRawCalled = true);
      expect(runCalled, equals(false));
      expect(runRawCalled, equals(false));
      connectedCompleter.complete();
      expect(runCalled, equals(true));
      expect(runRawCalled, equals(true));
    });

    test('re-connects when client sends onBillingServiceDisconnected', () {
      connectedCompleter.complete();
      manager.client.callHandler(
        const MethodCall(onBillingServiceDisconnectedCallback,
            <String, dynamic>{'handle': 0}),
      );
      expect(stubPlatform.countPreviousCalls(startConnectionCall), equals(2));
    });

    test(
      're-connects when operation returns BillingResponse.serviceDisconnected',
      () async {
        connectedCompleter.complete();
        int timesCalled = 0;
        final BillingResultWrapper result = await manager.run(
          (BillingClient _) async {
            timesCalled++;
            return BillingResultWrapper(
              responseCode: timesCalled == 1
                  ? BillingResponse.serviceDisconnected
                  : BillingResponse.ok,
            );
          },
        );
        expect(stubPlatform.countPreviousCalls(startConnectionCall), equals(2));
        expect(timesCalled, equals(2));
        expect(result.responseCode, equals(BillingResponse.ok));
      },
    );

    test('does not re-connect when disposed', () {
      connectedCompleter.complete();
      manager.dispose();
      expect(stubPlatform.countPreviousCalls(startConnectionCall), equals(1));
      expect(stubPlatform.countPreviousCalls(endConnectionCall), equals(1));
    });
  });
}
