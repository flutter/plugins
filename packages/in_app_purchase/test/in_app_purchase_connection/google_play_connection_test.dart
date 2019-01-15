import 'package:test/test.dart';

import 'package:flutter/widgets.dart';
import 'package:in_app_purchase/billing_client_wrappers.dart';
import 'package:in_app_purchase/src/in_app_purchase_connection/google_play_connection.dart';
import 'package:in_app_purchase/src/channel.dart';
import '../fake_in_app_purchase_platform.dart';

void main() {
  final FakeInAppPurchasePlatform fakePlatform = FakeInAppPurchasePlatform();
  GooglePlayConnection connection;
  const String startConnectionCall =
      'BillingClient#startConnection(BillingClientStateListener)';
  const String endConnectionCall = 'BillingClient#endConnection()';

  setUpAll(() =>
      channel.setMockMethodCallHandler(fakePlatform.fakeMethodCallHandler));

  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
    fakePlatform.addResponse(
        name: startConnectionCall,
        value: int.parse(BillingResponse.OK.toString()));
    fakePlatform.addResponse(name: endConnectionCall, value: null);
    connection = GooglePlayConnection.instance;
  });

  tearDown(() {
    fakePlatform.reset();
    GooglePlayConnection.reset();
  });

  group('connection management', () {
    test('connects on initialization', () {
      expect(fakePlatform.countPreviousCalls(startConnectionCall), equals(1));
    });

    test('disconnects on app pause', () {
      expect(fakePlatform.countPreviousCalls(endConnectionCall), equals(0));
      connection.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(fakePlatform.countPreviousCalls(endConnectionCall), equals(1));
    });

    test('reconnects on app resume', () {
      expect(fakePlatform.countPreviousCalls(startConnectionCall), equals(1));
      connection.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(fakePlatform.countPreviousCalls(startConnectionCall), equals(2));
    });
  });

  group('isAvailable', () {
    test('true', () async {
      fakePlatform.addResponse(name: 'BillingClient#isReady()', value: true);
      expect(await connection.isAvailable(), isTrue);
    });

    test('false', () async {
      fakePlatform.addResponse(name: 'BillingClient#isReady()', value: false);
      expect(await connection.isAvailable(), isFalse);
    });
  });
}
