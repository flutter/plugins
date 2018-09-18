import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final int lastFetchTime = 1520618753782;
  Map<String, dynamic> getDefaultInstance() {
    return <String, dynamic>{
      'lastFetchTime': lastFetchTime,
      'lastFetchStatus': 'success',
      'inDebugMode': true,
      'parameters': <String, dynamic>{
        'param1': <String, dynamic>{
          'source': 'static',
          'value': <int>[118, 97, 108, 49], // UTF-8 encoded 'val1'
        },
      },
    };
  }

  group('$RemoteConfig', () {
    final List<MethodCall> log = <MethodCall>[];

    setUp(() async {
      RemoteConfig.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'RemoteConfig#instance':
            return getDefaultInstance();
          default:
            return true;
        }
      });
    });

    test('instance', () async {
      final RemoteConfig remoteConfig = await RemoteConfig.instance;
      expect(
        log,
        <Matcher>[
          isMethodCall('RemoteConfig#instance', arguments: null),
        ],
      );
      expect(remoteConfig.remoteConfigSettings.debugMode, true);
      expect(remoteConfig.lastFetchTime,
          DateTime.fromMillisecondsSinceEpoch(lastFetchTime));
      expect(remoteConfig.lastFetchStatus, LastFetchStatus.values[0]);
    });

    test('doubleInstance', () async {
      final List<Future<RemoteConfig>> futures = <Future<RemoteConfig>>[
        RemoteConfig.instance,
        RemoteConfig.instance,
      ];
      Future.wait(futures).then((List<RemoteConfig> remoteConfigs) {
        // Check that both returned Remote Config instances are the same.
        expect(remoteConfigs[0], remoteConfigs[1]);
      });
    });
  });

  group('$RemoteConfig', () {
    final List<MethodCall> log = <MethodCall>[];

    final int lastFetchTime = 1520618753782;
    RemoteConfig remoteConfig;

    setUp(() async {
      RemoteConfig.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'RemoteConfig#setDefaults':
            return null;
          case 'RemoteConfig#fetch':
            return <String, dynamic>{
              'lastFetchTime': lastFetchTime,
              'lastFetchStatus': 'success',
            };
          case 'RemoteConfig#instance':
            return getDefaultInstance();
          case 'RemoteConfig#activate':
            return <String, dynamic>{
              'parameters': <String, dynamic>{
                'param1': <String, dynamic>{
                  'source': 'static',
                  'value': <int>[118, 97, 108, 49], // UTF-8 encoded 'val1'
                },
                'param2': <String, dynamic>{
                  'source': 'static',
                  'value': <int>[49, 50, 51, 52, 53], // UTF-8 encoded '12345'
                },
                'param3': <String, dynamic>{
                  'source': 'default',
                  'value': <int>[51, 46, 49, 52], // UTF-8 encoded '3.14'
                },
                'param4': <String, dynamic>{
                  'source': 'static',
                  'value': <int>[116, 114, 117, 101] // UTF-8 encoded 'true'
                }
              },
              'newConfig': true,
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

    test('setDefaults', () async {
      await remoteConfig.setDefaults(<String, dynamic>{
        'foo': 'bar',
      });
      expect(log, <Matcher>[
        isMethodCall(
          'RemoteConfig#setDefaults',
          arguments: <String, dynamic>{
            'defaults': <String, dynamic>{
              'foo': 'bar',
            },
          },
        ),
      ]);
    });

    test('fetch', () async {
      await remoteConfig.fetch(expiration: const Duration(hours: 1));
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
      final bool newConfig = await remoteConfig.activateFetched();
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'RemoteConfig#activate',
            arguments: null,
          ),
        ],
      );
      expect(newConfig, true);
      expect(remoteConfig.getString('param1'), 'val1');
      expect(remoteConfig.getInt('param2'), 12345);
      expect(remoteConfig.getDouble('param3'), 3.14);
      expect(remoteConfig.getBool('param4'), true);
    });

    test('setConfigSettings', () async {
      expect(remoteConfig.remoteConfigSettings.debugMode, true);
      final RemoteConfigSettings remoteConfigSettings =
          RemoteConfigSettings(debugMode: false);
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
