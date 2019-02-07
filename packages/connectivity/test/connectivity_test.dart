import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$Connectivity', () {
    final List<MethodCall> log = <MethodCall>[];

    setUp(() async {
      Connectivity.methodChannel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'check':
            return 'wifi';
          case 'wifiName':
            return '1337wifi';
          default:
            return null;
        }
      });
      log.clear();
      MethodChannel(Connectivity.eventChannel.name)
          .setMockMethodCallHandler((MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'listen':
            await BinaryMessages.handlePlatformMessage(
              Connectivity.eventChannel.name,
              Connectivity.eventChannel.codec.encodeSuccessEnvelope('wifi'),
              (_) {},
            );
            break;
          case 'cancel':
          default:
            return null;
        }
      });
    });

    test('onConnectivityChanged', () async {
      ConnectivityResult result =
          await Connectivity().onConnectivityChanged.first;
      expect(result, ConnectivityResult.wifi);
    });

    test('getWifiName', () async {
      String result = await Connectivity().getWifiName();
      expect(result, '1337wifi');
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'wifiName',
          ),
        ],
      );
    });

    test('checkConnectivity', () async {
      ConnectivityResult result = await Connectivity().checkConnectivity();
      expect(result, ConnectivityResult.wifi);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'check',
          ),
        ],
      );
    });
  });
}
