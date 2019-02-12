import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$Crashlytics', () {
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/firebase_crashlytics');

    final List<MethodCall> log = <MethodCall>[];

    final Crashlytics crashlytics = Crashlytics.instance;

    setUp(() async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'Crashlytics#isDebuggable':
            return true;
          case 'Crashlytics#setUserEmail':
            return true;
          case 'Crashlytics#setUserIdentifier':
            return true;
          case 'Crashlytics#setUserName':
            return true;
          case 'Crashlytics#log':
            return null;
        }
      });
      log.clear();
    });

    test('isDebuggable', () async {
      expect(await crashlytics.isDebuggable(), true);
      expect(log, <Matcher>[isMethodCall('Crashlytics#isDebuggable')]);
    });

    test('log', () {
      crashlytics.log('foo');
      expect(crashlytics.logs.length, 1);
      crashlytics.log('bar');
      expect(crashlytics.logs.length, 2);
    });

    test('isInDebugMode', () {
      crashlytics.reportInDevMode = true;
      expect(crashlytics.isInDebugMode, false);
      crashlytics.reportInDevMode = false;
      expect(crashlytics.isInDebugMode, true);
    });

    test('crash', () {
      expect(() => crashlytics.crash(), throwsStateError);
    });

    test('getVersion', () async {
      crashlytics.getVersion();
      expect(log, <Matcher>[isMethodCall('Crashlytics#getVersion')]);
    });

    test('setKey', () {
      crashlytics.setKey('foo', 'bar');
      expect(crashlytics.keys.length, 1);
      expect(crashlytics.keys['foo'], 'bar');
    });

    test('setUserEmail', () async {
      await crashlytics.setUserEmail('foo');
      expect(log, <Matcher>[isMethodCall('Crashlytics#setUserEmail',
          arguments: <String, dynamic> {
        'email': 'foo'
      })]);
    });

    test('setUserIdentifier', () async {
      await crashlytics.setUserIdentifier('foo');
      expect(log, <Matcher>[isMethodCall('Crashlytics#setUserIdentifier',
          arguments: <String, dynamic> {
            'identifier': 'foo'
          })]);
    });

    test('setUserName', () async {
      await crashlytics.setUserName('foo');
      expect(log, <Matcher>[isMethodCall('Crashlytics#setUserName',
          arguments: <String, dynamic> {
            'name': 'foo'
          })]);
    });

    test('sendLogs', () async {
      crashlytics.log('foo');
      await crashlytics.sendLogs();
      expect(log, <Matcher>[
        isMethodCall('Crashlytics#log',
            arguments: <String, dynamic> {
              'msg': 'foo'
            }),
        isMethodCall('Crashlytics#log',
            arguments: <String, dynamic> {
              'msg': 'bar'
            }),
        isMethodCall('Crashlytics#log',
            arguments: <String, dynamic> {
              'msg': 'foo'
            }),
      ]);
    });

    test('sendKeys', () async {
      crashlytics.setKey('baz', 'qux');
      crashlytics.setKey('quux', 1);
      crashlytics.setKey('quuz', false);
      await crashlytics.sendKeys();
      expect(log, <Matcher>[
        isMethodCall('Crashlytics#setString',
            arguments: <String, dynamic> {
              'key': 'foo',
              'value': 'bar'
            }),
        isMethodCall('Crashlytics#setString',
            arguments: <String, dynamic> {
              'key': 'baz',
              'value': 'qux'
            }),
        isMethodCall('Crashlytics#setInt',
            arguments: <String, dynamic> {
              'key': 'quux',
              'value': 1
            }),
        isMethodCall('Crashlytics#setBool',
            arguments: <String, dynamic> {
              'key': 'quuz',
              'value': false
            }),
      ]);
    });
  });
}
