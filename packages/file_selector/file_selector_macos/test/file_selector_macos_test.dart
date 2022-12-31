// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_macos/file_selector_macos.dart';
import 'package:file_selector_macos/src/messages.g.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'file_selector_macos_test.mocks.dart';
import 'messages_test.g.dart';

@GenerateMocks(<Type>[TestFileSelectorApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FileSelectorMacOS plugin;
  late MockTestFileSelectorApi mockApi;

  setUp(() {
    plugin = FileSelectorMacOS();
    mockApi = MockTestFileSelectorApi();
    TestFileSelectorApi.setup(mockApi);

    // Set default stubs for tests that don't expect a specific return value,
    // so calls don't throw. Tests that `expect` return values should override
    // these locally.
    when(mockApi.displayOpenPanel(any)).thenAnswer((_) async => <String?>[]);
    when(mockApi.displaySavePanel(any)).thenAnswer((_) async => null);
  });

  test('registered instance', () {
    FileSelectorMacOS.registerWith();
    expect(FileSelectorPlatform.instance, isA<FileSelectorMacOS>());
  });

  group('openFile', () {
    test('works as expected with no arguments', () async {
      when(mockApi.displayOpenPanel(any))
          .thenAnswer((_) async => <String?>['foo']);

      final XFile? file = await plugin.openFile();

      expect(file!.path, 'foo');
      final VerificationResult result =
          verify(mockApi.displayOpenPanel(captureAny));
      final OpenPanelOptions options = result.captured[0] as OpenPanelOptions;
      expect(options.allowsMultipleSelection, false);
      expect(options.canChooseFiles, true);
      expect(options.canChooseDirectories, false);
      expect(options.baseOptions.allowedFileTypes, null);
      expect(options.baseOptions.directoryPath, null);
      expect(options.baseOptions.nameFieldStringValue, null);
      expect(options.baseOptions.prompt, null);
    });

    test('handles cancel', () async {
      when(mockApi.displayOpenPanel(any)).thenAnswer((_) async => <String?>[]);

      final XFile? file = await plugin.openFile();

      expect(file, null);
    });

    test('passes the accepted type groups correctly', () async {
      const XTypeGroup group = XTypeGroup(
        label: 'text',
        extensions: <String>['txt'],
        mimeTypes: <String>['text/plain'],
        macUTIs: <String>['public.text'],
      );

      const XTypeGroup groupTwo = XTypeGroup(
          label: 'image',
          extensions: <String>['jpg'],
          mimeTypes: <String>['image/jpg'],
          macUTIs: <String>['public.image'],
          webWildCards: <String>['image/*']);

      await plugin.openFile(acceptedTypeGroups: <XTypeGroup>[group, groupTwo]);

      final VerificationResult result =
          verify(mockApi.displayOpenPanel(captureAny));
      final OpenPanelOptions options = result.captured[0] as OpenPanelOptions;
      expect(options.baseOptions.allowedFileTypes!.extensions,
          <String>['txt', 'jpg']);
      expect(options.baseOptions.allowedFileTypes!.mimeTypes,
          <String>['text/plain', 'image/jpg']);
      expect(options.baseOptions.allowedFileTypes!.utis,
          <String>['public.text', 'public.image']);
    });

    test('passes initialDirectory correctly', () async {
      await plugin.openFile(initialDirectory: '/example/directory');

      final VerificationResult result =
          verify(mockApi.displayOpenPanel(captureAny));
      final OpenPanelOptions options = result.captured[0] as OpenPanelOptions;
      expect(options.baseOptions.directoryPath, '/example/directory');
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.openFile(confirmButtonText: 'Open File');

      final VerificationResult result =
          verify(mockApi.displayOpenPanel(captureAny));
      final OpenPanelOptions options = result.captured[0] as OpenPanelOptions;
      expect(options.baseOptions.prompt, 'Open File');
    });

    test('throws for a type group that does not support macOS', () async {
      const XTypeGroup group = XTypeGroup(
        label: 'images',
        webWildCards: <String>['images/*'],
      );

      await expectLater(
          plugin.openFile(acceptedTypeGroups: <XTypeGroup>[group]),
          throwsArgumentError);
    });

    test('allows a wildcard group', () async {
      const XTypeGroup group = XTypeGroup(
        label: 'text',
      );

      await expectLater(
          plugin.openFile(acceptedTypeGroups: <XTypeGroup>[group]), completes);
    });
  });

  group('openFiles', () {
    test('works as expected with no arguments', () async {
      when(mockApi.displayOpenPanel(any))
          .thenAnswer((_) async => <String?>['foo', 'bar']);

      final List<XFile> files = await plugin.openFiles();

      expect(files[0].path, 'foo');
      expect(files[1].path, 'bar');
      final VerificationResult result =
          verify(mockApi.displayOpenPanel(captureAny));
      final OpenPanelOptions options = result.captured[0] as OpenPanelOptions;
      expect(options.allowsMultipleSelection, true);
      expect(options.canChooseFiles, true);
      expect(options.canChooseDirectories, false);
      expect(options.baseOptions.allowedFileTypes, null);
      expect(options.baseOptions.directoryPath, null);
      expect(options.baseOptions.nameFieldStringValue, null);
      expect(options.baseOptions.prompt, null);
    });

    test('handles cancel', () async {
      when(mockApi.displayOpenPanel(any)).thenAnswer((_) async => <String?>[]);

      final List<XFile> files = await plugin.openFiles();

      expect(files, isEmpty);
    });

    test('passes the accepted type groups correctly', () async {
      const XTypeGroup group = XTypeGroup(
        label: 'text',
        extensions: <String>['txt'],
        mimeTypes: <String>['text/plain'],
        macUTIs: <String>['public.text'],
      );

      const XTypeGroup groupTwo = XTypeGroup(
          label: 'image',
          extensions: <String>['jpg'],
          mimeTypes: <String>['image/jpg'],
          macUTIs: <String>['public.image'],
          webWildCards: <String>['image/*']);

      await plugin.openFiles(acceptedTypeGroups: <XTypeGroup>[group, groupTwo]);

      final VerificationResult result =
          verify(mockApi.displayOpenPanel(captureAny));
      final OpenPanelOptions options = result.captured[0] as OpenPanelOptions;
      expect(options.baseOptions.allowedFileTypes!.extensions,
          <String>['txt', 'jpg']);
      expect(options.baseOptions.allowedFileTypes!.mimeTypes,
          <String>['text/plain', 'image/jpg']);
      expect(options.baseOptions.allowedFileTypes!.utis,
          <String>['public.text', 'public.image']);
    });

    test('passes initialDirectory correctly', () async {
      await plugin.openFiles(initialDirectory: '/example/directory');

      final VerificationResult result =
          verify(mockApi.displayOpenPanel(captureAny));
      final OpenPanelOptions options = result.captured[0] as OpenPanelOptions;
      expect(options.baseOptions.directoryPath, '/example/directory');
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.openFiles(confirmButtonText: 'Open File');

      final VerificationResult result =
          verify(mockApi.displayOpenPanel(captureAny));
      final OpenPanelOptions options = result.captured[0] as OpenPanelOptions;
      expect(options.baseOptions.prompt, 'Open File');
    });

    test('throws for a type group that does not support macOS', () async {
      const XTypeGroup group = XTypeGroup(
        label: 'images',
        webWildCards: <String>['images/*'],
      );

      await expectLater(
          plugin.openFiles(acceptedTypeGroups: <XTypeGroup>[group]),
          throwsArgumentError);
    });

    test('allows a wildcard group', () async {
      const XTypeGroup group = XTypeGroup(
        label: 'text',
      );

      await expectLater(
          plugin.openFiles(acceptedTypeGroups: <XTypeGroup>[group]), completes);
    });
  });

  group('getSavePath', () {
    test('works as expected with no arguments', () async {
      when(mockApi.displaySavePanel(any)).thenAnswer((_) async => 'foo');

      final String? path = await plugin.getSavePath();

      expect(path, 'foo');
      final VerificationResult result =
          verify(mockApi.displaySavePanel(captureAny));
      final SavePanelOptions options = result.captured[0] as SavePanelOptions;
      expect(options.allowedFileTypes, null);
      expect(options.directoryPath, null);
      expect(options.nameFieldStringValue, null);
      expect(options.prompt, null);
    });

    test('handles cancel', () async {
      when(mockApi.displaySavePanel(any)).thenAnswer((_) async => null);

      final String? path = await plugin.getSavePath();

      expect(path, null);
    });

    test('passes the accepted type groups correctly', () async {
      const XTypeGroup group = XTypeGroup(
        label: 'text',
        extensions: <String>['txt'],
        mimeTypes: <String>['text/plain'],
        macUTIs: <String>['public.text'],
      );

      const XTypeGroup groupTwo = XTypeGroup(
          label: 'image',
          extensions: <String>['jpg'],
          mimeTypes: <String>['image/jpg'],
          macUTIs: <String>['public.image'],
          webWildCards: <String>['image/*']);

      await plugin
          .getSavePath(acceptedTypeGroups: <XTypeGroup>[group, groupTwo]);

      final VerificationResult result =
          verify(mockApi.displaySavePanel(captureAny));
      final SavePanelOptions options = result.captured[0] as SavePanelOptions;
      expect(options.allowedFileTypes!.extensions, <String>['txt', 'jpg']);
      expect(options.allowedFileTypes!.mimeTypes,
          <String>['text/plain', 'image/jpg']);
      expect(options.allowedFileTypes!.utis,
          <String>['public.text', 'public.image']);
    });

    test('passes initialDirectory correctly', () async {
      await plugin.getSavePath(initialDirectory: '/example/directory');

      final VerificationResult result =
          verify(mockApi.displaySavePanel(captureAny));
      final SavePanelOptions options = result.captured[0] as SavePanelOptions;
      expect(options.directoryPath, '/example/directory');
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.getSavePath(confirmButtonText: 'Open File');

      final VerificationResult result =
          verify(mockApi.displaySavePanel(captureAny));
      final SavePanelOptions options = result.captured[0] as SavePanelOptions;
      expect(options.prompt, 'Open File');
    });

    test('throws for a type group that does not support macOS', () async {
      const XTypeGroup group = XTypeGroup(
        label: 'images',
        webWildCards: <String>['images/*'],
      );

      await expectLater(
          plugin.getSavePath(acceptedTypeGroups: <XTypeGroup>[group]),
          throwsArgumentError);
    });

    test('allows a wildcard group', () async {
      const XTypeGroup group = XTypeGroup(
        label: 'text',
      );

      await expectLater(
          plugin.getSavePath(acceptedTypeGroups: <XTypeGroup>[group]),
          completes);
    });
  });

  group('getDirectoryPath', () {
    test('works as expected with no arguments', () async {
      when(mockApi.displayOpenPanel(any))
          .thenAnswer((_) async => <String?>['foo']);

      final String? path = await plugin.getDirectoryPath();

      expect(path, 'foo');
      final VerificationResult result =
          verify(mockApi.displayOpenPanel(captureAny));
      final OpenPanelOptions options = result.captured[0] as OpenPanelOptions;
      expect(options.allowsMultipleSelection, false);
      expect(options.canChooseFiles, false);
      expect(options.canChooseDirectories, true);
      expect(options.baseOptions.allowedFileTypes, null);
      expect(options.baseOptions.directoryPath, null);
      expect(options.baseOptions.nameFieldStringValue, null);
      expect(options.baseOptions.prompt, null);
    });

    test('handles cancel', () async {
      when(mockApi.displayOpenPanel(any)).thenAnswer((_) async => <String?>[]);

      final String? path = await plugin.getDirectoryPath();

      expect(path, null);
    });

    test('passes initialDirectory correctly', () async {
      await plugin.getDirectoryPath(initialDirectory: '/example/directory');

      final VerificationResult result =
          verify(mockApi.displayOpenPanel(captureAny));
      final OpenPanelOptions options = result.captured[0] as OpenPanelOptions;
      expect(options.baseOptions.directoryPath, '/example/directory');
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.getDirectoryPath(confirmButtonText: 'Open File');

      final VerificationResult result =
          verify(mockApi.displayOpenPanel(captureAny));
      final OpenPanelOptions options = result.captured[0] as OpenPanelOptions;
      expect(options.baseOptions.prompt, 'Open File');
    });
  });

  test('ignores all type groups if any of them is a wildcard', () async {
    await plugin.getSavePath(acceptedTypeGroups: <XTypeGroup>[
      const XTypeGroup(
        label: 'text',
        extensions: <String>['txt'],
        mimeTypes: <String>['text/plain'],
        macUTIs: <String>['public.text'],
      ),
      const XTypeGroup(
        label: 'image',
        extensions: <String>['jpg'],
        mimeTypes: <String>['image/jpg'],
        macUTIs: <String>['public.image'],
      ),
      const XTypeGroup(
        label: 'any',
      ),
    ]);

    final VerificationResult result =
        verify(mockApi.displaySavePanel(captureAny));
    final SavePanelOptions options = result.captured[0] as SavePanelOptions;
    expect(options.allowedFileTypes, null);
  });
}
