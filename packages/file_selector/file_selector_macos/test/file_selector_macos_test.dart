// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_macos/file_selector_macos.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final FileSelectorMacOS plugin = FileSelectorMacOS();

  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    plugin.channel.setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
      return null;
    });

    log.clear();
  });

  test('registered instance', () {
    FileSelectorMacOS.registerWith();
    expect(FileSelectorPlatform.instance, isA<FileSelectorMacOS>());
  });

  group('openFile', () {
    test('passes the accepted type groups correctly', () async {
      // TODO(stuartmorgan): https://github.com/flutter/flutter/issues/111906
      // ignore: prefer_const_constructors
      final XTypeGroup group = XTypeGroup(
        label: 'text',
        extensions: <String>['txt'],
        mimeTypes: <String>['text/plain'],
        macUTIs: <String>['public.text'],
      );

      // TODO(stuartmorgan): https://github.com/flutter/flutter/issues/111906
      // ignore: prefer_const_constructors
      final XTypeGroup groupTwo = XTypeGroup(
          label: 'image',
          extensions: <String>['jpg'],
          mimeTypes: <String>['image/jpg'],
          macUTIs: <String>['public.image'],
          webWildCards: <String>['image/*']);

      await plugin.openFile(acceptedTypeGroups: <XTypeGroup>[group, groupTwo]);

      expect(
        log,
        <Matcher>[
          isMethodCall('openFile', arguments: <String, dynamic>{
            'acceptedTypes': <String, dynamic>{
              'extensions': <String>['txt', 'jpg'],
              'mimeTypes': <String>['text/plain', 'image/jpg'],
              'UTIs': <String>['public.text', 'public.image'],
            },
            'initialDirectory': null,
            'confirmButtonText': null,
            'multiple': false,
          }),
        ],
      );
    });

    test('passes initialDirectory correctly', () async {
      await plugin.openFile(initialDirectory: '/example/directory');

      expect(
        log,
        <Matcher>[
          isMethodCall('openFile', arguments: <String, dynamic>{
            'acceptedTypes': null,
            'initialDirectory': '/example/directory',
            'confirmButtonText': null,
            'multiple': false,
          }),
        ],
      );
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.openFile(confirmButtonText: 'Open File');

      expect(
        log,
        <Matcher>[
          isMethodCall('openFile', arguments: <String, dynamic>{
            'acceptedTypes': null,
            'initialDirectory': null,
            'confirmButtonText': 'Open File',
            'multiple': false,
          }),
        ],
      );
    });

    test('throws for a type group that does not support macOS', () async {
      // TODO(stuartmorgan): https://github.com/flutter/flutter/issues/111906
      // ignore: prefer_const_constructors
      final XTypeGroup group = XTypeGroup(
        label: 'images',
        webWildCards: <String>['images/*'],
      );

      await expectLater(
          plugin.openFile(acceptedTypeGroups: <XTypeGroup>[group]),
          throwsArgumentError);
    });

    test('allows a wildcard group', () async {
      // TODO(stuartmorgan): https://github.com/flutter/flutter/issues/111906
      // ignore: prefer_const_constructors
      final XTypeGroup group = XTypeGroup(
        label: 'text',
      );

      await expectLater(
          plugin.openFile(acceptedTypeGroups: <XTypeGroup>[group]), completes);
    });
  });

  group('openFiles', () {
    test('passes the accepted type groups correctly', () async {
      // TODO(stuartmorgan): https://github.com/flutter/flutter/issues/111906
      // ignore: prefer_const_constructors
      final XTypeGroup group = XTypeGroup(
        label: 'text',
        extensions: <String>['txt'],
        mimeTypes: <String>['text/plain'],
        macUTIs: <String>['public.text'],
      );

      // TODO(stuartmorgan): https://github.com/flutter/flutter/issues/111906
      // ignore: prefer_const_constructors
      final XTypeGroup groupTwo = XTypeGroup(
          label: 'image',
          extensions: <String>['jpg'],
          mimeTypes: <String>['image/jpg'],
          macUTIs: <String>['public.image'],
          webWildCards: <String>['image/*']);

      await plugin.openFiles(acceptedTypeGroups: <XTypeGroup>[group, groupTwo]);

      expect(
        log,
        <Matcher>[
          isMethodCall('openFile', arguments: <String, dynamic>{
            'acceptedTypes': <String, List<dynamic>>{
              'extensions': <String>['txt', 'jpg'],
              'mimeTypes': <String>['text/plain', 'image/jpg'],
              'UTIs': <String>['public.text', 'public.image'],
            },
            'initialDirectory': null,
            'confirmButtonText': null,
            'multiple': true,
          }),
        ],
      );
    });

    test('passes initialDirectory correctly', () async {
      await plugin.openFiles(initialDirectory: '/example/directory');

      expect(
        log,
        <Matcher>[
          isMethodCall('openFile', arguments: <String, dynamic>{
            'acceptedTypes': null,
            'initialDirectory': '/example/directory',
            'confirmButtonText': null,
            'multiple': true,
          }),
        ],
      );
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.openFiles(confirmButtonText: 'Open File');

      expect(
        log,
        <Matcher>[
          isMethodCall('openFile', arguments: <String, dynamic>{
            'acceptedTypes': null,
            'initialDirectory': null,
            'confirmButtonText': 'Open File',
            'multiple': true,
          }),
        ],
      );
    });

    test('throws for a type group that does not support macOS', () async {
      // TODO(stuartmorgan): https://github.com/flutter/flutter/issues/111906
      // ignore: prefer_const_constructors
      final XTypeGroup group = XTypeGroup(
        label: 'images',
        webWildCards: <String>['images/*'],
      );

      await expectLater(
          plugin.openFiles(acceptedTypeGroups: <XTypeGroup>[group]),
          throwsArgumentError);
    });

    test('allows a wildcard group', () async {
      // TODO(stuartmorgan): https://github.com/flutter/flutter/issues/111906
      // ignore: prefer_const_constructors
      final XTypeGroup group = XTypeGroup(
        label: 'text',
      );

      await expectLater(
          plugin.openFiles(acceptedTypeGroups: <XTypeGroup>[group]), completes);
    });
  });

  group('getSavePath', () {
    test('passes the accepted type groups correctly', () async {
      // TODO(stuartmorgan): https://github.com/flutter/flutter/issues/111906
      // ignore: prefer_const_constructors
      final XTypeGroup group = XTypeGroup(
        label: 'text',
        extensions: <String>['txt'],
        mimeTypes: <String>['text/plain'],
        macUTIs: <String>['public.text'],
      );

      // TODO(stuartmorgan): https://github.com/flutter/flutter/issues/111906
      // ignore: prefer_const_constructors
      final XTypeGroup groupTwo = XTypeGroup(
          label: 'image',
          extensions: <String>['jpg'],
          mimeTypes: <String>['image/jpg'],
          macUTIs: <String>['public.image'],
          webWildCards: <String>['image/*']);

      await plugin
          .getSavePath(acceptedTypeGroups: <XTypeGroup>[group, groupTwo]);

      expect(
        log,
        <Matcher>[
          isMethodCall('getSavePath', arguments: <String, dynamic>{
            'acceptedTypes': <String, List<dynamic>>{
              'extensions': <String>['txt', 'jpg'],
              'mimeTypes': <String>['text/plain', 'image/jpg'],
              'UTIs': <String>['public.text', 'public.image'],
            },
            'initialDirectory': null,
            'suggestedName': null,
            'confirmButtonText': null,
          }),
        ],
      );
    });

    test('passes initialDirectory correctly', () async {
      await plugin.getSavePath(initialDirectory: '/example/directory');

      expect(
        log,
        <Matcher>[
          isMethodCall('getSavePath', arguments: <String, dynamic>{
            'acceptedTypes': null,
            'initialDirectory': '/example/directory',
            'suggestedName': null,
            'confirmButtonText': null,
          }),
        ],
      );
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.getSavePath(confirmButtonText: 'Open File');

      expect(
        log,
        <Matcher>[
          isMethodCall('getSavePath', arguments: <String, dynamic>{
            'acceptedTypes': null,
            'initialDirectory': null,
            'suggestedName': null,
            'confirmButtonText': 'Open File',
          }),
        ],
      );
    });

    test('throws for a type group that does not support macOS', () async {
      // TODO(stuartmorgan): https://github.com/flutter/flutter/issues/111906
      // ignore: prefer_const_constructors
      final XTypeGroup group = XTypeGroup(
        label: 'images',
        webWildCards: <String>['images/*'],
      );

      await expectLater(
          plugin.getSavePath(acceptedTypeGroups: <XTypeGroup>[group]),
          throwsArgumentError);
    });

    test('allows a wildcard group', () async {
      // TODO(stuartmorgan): https://github.com/flutter/flutter/issues/111906
      // ignore: prefer_const_constructors
      final XTypeGroup group = XTypeGroup(
        label: 'text',
      );

      await expectLater(
          plugin.getSavePath(acceptedTypeGroups: <XTypeGroup>[group]),
          completes);
    });
  });

  group('getDirectoryPath', () {
    test('passes initialDirectory correctly', () async {
      await plugin.getDirectoryPath(initialDirectory: '/example/directory');

      expect(
        log,
        <Matcher>[
          isMethodCall('getDirectoryPath', arguments: <String, dynamic>{
            'initialDirectory': '/example/directory',
            'confirmButtonText': null,
          }),
        ],
      );
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.getDirectoryPath(confirmButtonText: 'Open File');

      expect(
        log,
        <Matcher>[
          isMethodCall('getDirectoryPath', arguments: <String, dynamic>{
            'initialDirectory': null,
            'confirmButtonText': 'Open File',
          }),
        ],
      );
    });
  });

  test('ignores all type groups if any of them is a wildcard', () async {
    await plugin.getSavePath(acceptedTypeGroups: <XTypeGroup>[
      // TODO(stuartmorgan): https://github.com/flutter/flutter/issues/111906
      // ignore: prefer_const_constructors
      XTypeGroup(
        label: 'text',
        extensions: <String>['txt'],
        mimeTypes: <String>['text/plain'],
        macUTIs: <String>['public.text'],
      ),
      // TODO(stuartmorgan): https://github.com/flutter/flutter/issues/111906
      // ignore: prefer_const_constructors
      XTypeGroup(
        label: 'image',
        extensions: <String>['jpg'],
        mimeTypes: <String>['image/jpg'],
        macUTIs: <String>['public.image'],
      ),
      // TODO(stuartmorgan): https://github.com/flutter/flutter/issues/111906
      // ignore: prefer_const_constructors
      XTypeGroup(
        label: 'any',
      ),
    ]);

    expect(
      log,
      <Matcher>[
        isMethodCall('getSavePath', arguments: <String, dynamic>{
          'acceptedTypes': null,
          'initialDirectory': null,
          'suggestedName': null,
          'confirmButtonText': null,
        }),
      ],
    );
  });
}
