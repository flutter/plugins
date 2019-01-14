import 'package:test/test.dart';
import 'package:flutter/services.dart';

import 'package:flutter/widgets.dart';
import 'package:in_app_purchase/billing_client_wrappers.dart';
import 'package:in_app_purchase/src/in_app_purchase_connection/google_play_connection.dart';
import 'package:in_app_purchase/src/channel.dart';
import '../fake_platform_views_controller.dart';

void main() {
  final FakePlatformViewsController controller = FakePlatformViewsController();
  GooglePlayConnection connection;
  const String startConnectionCall =
      'BillingClient#startConnection(BillingClientStateListener)';
  const String endConnectionCall = 'BillingClient#endConnection()';

  setUpAll(() {
    Channel.override = SystemChannels.platform_views;
    SystemChannels.platform_views
        .setMockMethodCallHandler(controller.fakePlatformViewsMethodHandler);
  });

  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
    controller.addCall(
        name: startConnectionCall,
        value: int.parse(BillingResponse.OK.toString()));
    controller.addCall(name: endConnectionCall, value: null);
    connection = GooglePlayConnection.instance;
  });

  tearDown(() {
    controller.reset();
    GooglePlayConnection.reset();
  });

  group('connection management', () {
    test('connects on initialization', () {
      expect(controller.countPreviousCalls(startConnectionCall), equals(1));
    });

    test('disconnects on app pause', () {
      expect(controller.countPreviousCalls(endConnectionCall), equals(0));
      connection.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(controller.countPreviousCalls(endConnectionCall), equals(1));
    });

    test('reconnects on app resume', () {
      expect(controller.countPreviousCalls(startConnectionCall), equals(1));
      connection.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(controller.countPreviousCalls(startConnectionCall), equals(2));
    });
  });

  group('isAvailable', () {
    test('true', () async {
      controller.addCall(name: 'BillingClient#isReady()', value: true);
      expect(await connection.isAvailable(), isTrue);
    });

    test('false', () async {
      controller.addCall(name: 'BillingClient#isReady()', value: false);
      expect(await connection.isAvailable(), isFalse);
    });
  });
}
