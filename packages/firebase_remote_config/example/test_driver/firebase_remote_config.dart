import 'dart:async';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  group('$RemoteConfig', () {
    RemoteConfig remoteConfig;

    setUp(() async {
      remoteConfig = await RemoteConfig.instance;
      remoteConfig.setConfigSettings(RemoteConfigSettings(debugMode: true));
      remoteConfig.setDefaults(<String, dynamic>{
        'welcome': 'default welcome',
        'hello': 'default hello',
      });
    });

    test('fetch', () async {
      final DateTime lastFetchTime = remoteConfig.lastFetchTime;
      expect(lastFetchTime.isBefore(DateTime.now()), true);
      await remoteConfig.fetch(expiration: const Duration(seconds: 0));
      expect(remoteConfig.lastFetchTime.isAfter(lastFetchTime), true);
      expect(remoteConfig.lastFetchStatus, LastFetchStatus.success);
      await remoteConfig.activateFetched();
      expect(remoteConfig.getString('welcome'), 'Earth, welcome! Hello!');
      expect(remoteConfig.getString('hello'), 'default hello');
    });
  });
}
