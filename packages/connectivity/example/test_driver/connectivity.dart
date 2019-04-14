import 'dart:async';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity/connectivity.dart';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  group('Connectivity test driver', () {
    Connectivity _connectivity;

    setUpAll(() async {
      _connectivity = Connectivity();
    });

    test('test connectivity result', () async {
      final ConnectivityResult result = await _connectivity.checkConnectivity();
      expect(result, isNotNull);
      switch (result) {
        case ConnectivityResult.wifi:
          expect((_connectivity.getWifiName()), completes);
          expect((await _connectivity.getWifiIP()), isNotNull);
          // Returns null on emulators so we just check that it doesn't throw
          await _connectivity.getWifiBSSID();
          break;
        default:
          break;
      }
    });
  });
}
