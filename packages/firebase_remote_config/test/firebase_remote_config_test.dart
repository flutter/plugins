import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$RemoteConfig', () {
    const MethodChannel channel = const MethodChannel(
      'plugins.flutter.io/firebase_remote_config',
    );

    final List<MethodCall> log = <MethodCall>[];

    final int lastFetchTime = 1520618753782;
    RemoteConfig remoteConfig;

    setUp(() async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'RemoteConfig#fetch':
            return <String, dynamic>{
              'LAST_FETCH_TIME': lastFetchTime,
              'LAST_FETCH_STATUS': 0,
            };
          case 'RemoteConfig#instance':
            return <String, dynamic>{
              'LAST_FETCH_TIME': lastFetchTime,
              'LAST_FETCH_STATUS': 0,
              'IN_DEBUG_MODE': true,
              'PARAMETERS': <String, dynamic>{
                'param1': <String, dynamic>{
                  'source': 0,
                  'value': <int>[118, 97, 108, 49], // UTF-8 encoded 'val1'
                },
              },
            };
          case 'RemoteConfig#activate':
            return <String, dynamic>{
              'param1': <String, dynamic>{
                'source': 0,
                'value': <int>[118, 97, 108, 49], // UTF-8 encoded 'val1'
              },
              'param2': <String, dynamic>{
                'source': 0,
                'value': <int>[49, 50, 51, 52, 53], // UTF-8 encoded '12345'
              },
              'param3': <String, dynamic>{
                'source': 1,
                'value': <int>[51, 46, 49, 52], // UTF-8 encoded '3.14'
              },
              'param4': <String, dynamic>{
                'source': 0,
                'value': <int>[116, 114, 117, 101] // UTF-8 encoded 'true'
              }
            };
          case 'RemoteConfig#setConfigSettings':
            return null;
          default:
            return true;
        }
      });
      remoteConfig = await RemoteConfig.instance;
      log.clear();
    });

    test('instance', () async {
      remoteConfig = await RemoteConfig.instance;
      expect(
        log,
        <Matcher>[
          isMethodCall('RemoteConfig#instance', arguments: null),
        ],
      );
      expect(remoteConfig.remoteConfigSettings.debugMode, true);
      expect(remoteConfig.lastFetchTime,
          new DateTime.fromMillisecondsSinceEpoch(lastFetchTime));
      expect(remoteConfig.lastFetchStatus, LastFetchStatus.values[0]);
    });

    test('fetch', () async {
      await remoteConfig.fetch(expiration: new Duration(hours: 1));
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'RemoteConfig#fetch',
            arguments: <String, dynamic>{
              'expiration': 3600,
            },
          ),
        ],
      );
    });

    test('activate', () async {
      await remoteConfig.activateFetched();
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'RemoteConfig#activate',
            arguments: null,
          ),
        ],
      );
      expect(remoteConfig.getString('param1'), 'val1');
      expect(remoteConfig.getInt('param2'), 12345);
      expect(remoteConfig.getDouble('param3'), 3.14);
      expect(remoteConfig.getBool('param4'), true);
    });

    test('setConfigSettings', () async {
      expect(remoteConfig.remoteConfigSettings.debugMode, true);
      final RemoteConfigSettings remoteConfigSettings =
          new RemoteConfigSettings();
      remoteConfigSettings.debugMode = false;
      await remoteConfig.setConfigSettings(remoteConfigSettings);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'RemoteConfig#setConfigSettings',
            arguments: <String, dynamic>{
              'debugMode': false,
            },
          ),
        ],
      );
      expect(remoteConfig.remoteConfigSettings.debugMode, false);
    });
  });
}
