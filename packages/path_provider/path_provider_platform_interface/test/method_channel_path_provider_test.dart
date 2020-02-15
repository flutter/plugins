import 'package:mockito/mockito.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:path_provider_platform_interface/method_channel_path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$PathProviderPlatform', () {
    test('$MethodChannelPathProvider() is the default instance', () {
      expect(PathProviderPlatform.instance, isInstanceOf<MethodChannelPathProvider>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        PathProviderPlatform.instance = ImplementsPathProviderPlatform();
      }, throwsA(isInstanceOf<AssertionError>()));
    });

    test('Can be mocked with `implements`', () {
      final PathProviderPlatformMock mock = PathProviderPlatformMock();
      PathProviderPlatform.instance = mock;
    });

    test('Can be extended', () {
      PathProviderPlatform.instance = ExtendsPathProviderPlatform();
    });
  });

  group('$MethodChannelPathProvider', () {
    const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
    final List<MethodCall> log = <MethodCall>[];
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
    });

    final MethodChannelPathProvider pathProvider = MethodChannelPathProvider();

    tearDown(() {
      log.clear();
    });
    test('getTemporaryDirectory', () async {
      await pathProvider.getTemporaryDirectory();
      expect(
        log,
        <Matcher>[isMethodCall('getTemporaryDirectory', arguments: null)],
      );
    });

    test('getApplicationSupportDirectory', () async {
      await pathProvider.getApplicationSupportDirectory();
      expect(
        log,
        <Matcher>[isMethodCall('getApplicationSupportDirectory', arguments: null)],
      );
    });

    test('getLibraryDirectory', () async {
      await pathProvider.getLibraryDirectory();
      expect(
        log,
        <Matcher>[isMethodCall('getLibraryDirectory', arguments: null)],
      );
    });

    test('getApplicationDocumentsDirectory', () async {
      await pathProvider.getApplicationDocumentsDirectory();
      expect(
        log,
        <Matcher>[isMethodCall('getApplicationDocumentsDirectory', arguments: null)],
      );
    });

    test('getExternalStorageDirectory', () async {
      await pathProvider.getExternalStorageDirectory();
      expect(
        log,
        <Matcher>[isMethodCall('getStorageDirectory', arguments: null)],
      );
    });

    test('getExternalCacheDirectories', () async {
      await pathProvider.getExternalCacheDirectories();
      expect(
        log,
        <Matcher>[isMethodCall('getExternalCacheDirectories', arguments: null)],
      );
    });

    test('getExternalStorageDirectories', () async {
      await pathProvider.getExternalStorageDirectories();
      expect(
        log,
        <Matcher>[
          isMethodCall('getExternalStorageDirectories', arguments: <String, Object>{'type': null})
        ],
      );
    });

    test('getExternalStorageDirectories with types', () async {
      for (final type in StorageDirectory.values) {
        await pathProvider.getExternalStorageDirectories(type: type);
        expect(
          log,
          <Matcher>[
            isMethodCall('getExternalStorageDirectories', arguments: <String, Object>{'type': type.index})
          ],
        );
        log.clear();
      }
    });

    test('getDownloadsDirectory', () async {
      await pathProvider.getDownloadsDirectory();
      expect(
        log,
        <Matcher>[isMethodCall('getDownloadsDirectory', arguments: null)],
      );
    });
  });
}

class PathProviderPlatformMock extends Mock with MockPlatformInterfaceMixin implements PathProviderPlatform {}

class ImplementsPathProviderPlatform extends Mock implements PathProviderPlatform {}

class ExtendsPathProviderPlatform extends PathProviderPlatform {}
