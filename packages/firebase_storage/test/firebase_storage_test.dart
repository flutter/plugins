// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StorageReference', () {
    group('getData', () {
      final List<MethodCall> log = <MethodCall>[];

      StorageReference ref;

      setUp(() {
        FirebaseStorage.channel
            .setMockMethodCallHandler((MethodCall methodCall) {
          log.add(methodCall);
          return new Future<Uint8List>.value(
              new Uint8List.fromList(<int>[1, 2, 3, 4]));
        });
        ref = FirebaseStorage.instance
            .ref()
            .child('avatars')
            .child('large')
            .child('image.jpg');
      });

      test('invokes correct method', () async {
        await ref.getData(10);

        expect(log, <Matcher>[
          isMethodCall(
            'StorageReference#getData',
            arguments: <String, dynamic>{
              'maxSize': 10,
              'path': 'avatars/large/image.jpg',
            },
          ),
        ]);
      });

      test('returns correct result', () async {
        expect(await ref.getData(10),
            equals(new Uint8List.fromList(<int>[1, 2, 3, 4])));
      });
    });

    group('getMetadata', () {
      final List<MethodCall> log = <MethodCall>[];

      StorageReference ref;

      setUp(() {
        FirebaseStorage.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          log.add(methodCall);
          return <String, String>{'name': 'image.jpg'};
        });
        ref = FirebaseStorage.instance
            .ref()
            .child('avatars')
            .child('large')
            .child('image.jpg');
      });

      test('invokes correct method', () async {
        await ref.getMetadata();

        expect(log, <Matcher>[
          isMethodCall(
            'StorageReference#getMetadata',
            arguments: <String, dynamic>{
              'path': 'avatars/large/image.jpg',
            },
          ),
        ]);
      });

      test('returns correct result', () async {
        expect((await ref.getMetadata()).name, 'image.jpg');
      });
    });

    group('updateMetadata', () {
      final List<MethodCall> log = <MethodCall>[];

      StorageReference ref;

      setUp(() {
        FirebaseStorage.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          log.add(methodCall);
          switch (methodCall.method) {
            case 'StorageReference#getMetadata':
              return <String, String>{
                'name': 'image.jpg',
              };
              break;
            case 'StorageReference#updateMetadata':
              return <String, String>{
                'name': 'image.jpg',
                'contentLanguage': 'en'
              };
              break;
            default:
              break;
          }
        });
        ref = FirebaseStorage.instance
            .ref()
            .child('avatars')
            .child('large')
            .child('image.jpg');
      });

      test('invokes correct method', () async {
        await ref.updateMetadata(const StorageMetadata(contentLanguage: 'en'));

        expect(log, <Matcher>[
          isMethodCall(
            'StorageReference#updateMetadata',
            arguments: <String, dynamic>{
              'path': 'avatars/large/image.jpg',
              'metadata': <String, String>{
                'cacheControl': null,
                'contentDisposition': null,
                'contentLanguage': 'en',
                'contentType': null,
                'contentEncoding': null
              },
            },
          ),
        ]);
      });

      test('returns correct result', () async {
        expect((await ref.getMetadata()).contentLanguage, null);
        expect(
            (await ref.updateMetadata(
                    const StorageMetadata(contentLanguage: 'en')))
                .contentLanguage,
            'en');
      });
    });

    group('getDownloadUrl', () {
      final List<MethodCall> log = <MethodCall>[];

      StorageReference ref;

      setUp(() {
        FirebaseStorage.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          log.add(methodCall);
          return 'https://path/to/file';
        });
        ref = FirebaseStorage.instance
            .ref()
            .child('avatars')
            .child('large')
            .child('image.jpg');
      });

      test('invokes correct method', () async {
        await ref.getDownloadURL();

        expect(log, <Matcher>[
          isMethodCall(
            'StorageReference#getDownloadUrl',
            arguments: <String, dynamic>{
              'path': 'avatars/large/image.jpg',
            },
          ),
        ]);
      });

      test('returns correct result', () async {
        expect(await ref.getDownloadURL(), 'https://path/to/file');
      });
    });

    group('delete', () {
      final List<MethodCall> log = <MethodCall>[];

      StorageReference ref;

      setUp(() {
        FirebaseStorage.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        });
        ref = FirebaseStorage.instance.ref().child('image.jpg');
      });

      test('invokes correct method', () async {
        await ref.delete();

        expect(
          log,
          <Matcher>[
            isMethodCall(
              'StorageReference#delete',
              arguments: <String, dynamic>{
                'path': 'image.jpg',
              },
            ),
          ],
        );
      });
    });

    group('getBucket', () {
      final List<MethodCall> log = <MethodCall>[];

      StorageReference ref;

      setUp(() {
        FirebaseStorage.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          log.add(methodCall);
          return 'foo';
        });
        ref = FirebaseStorage.instance
            .ref()
            .child('avatars')
            .child('large')
            .child('image.jpg');
      });

      test('invokes correct method', () async {
        await ref.getBucket();

        expect(log, <Matcher>[
          isMethodCall(
            'StorageReference#getBucket',
            arguments: <String, dynamic>{
              'path': 'avatars/large/image.jpg',
            },
          ),
        ]);
      });

      test('returns correct result', () async {
        expect(await ref.getBucket(), 'foo');
      });
    });

    group('getName', () {
      final List<MethodCall> log = <MethodCall>[];

      StorageReference ref;

      setUp(() {
        FirebaseStorage.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          log.add(methodCall);
          return 'image.jpg';
        });
        ref = FirebaseStorage.instance
            .ref()
            .child('avatars')
            .child('large')
            .child('image.jpg');
      });

      test('invokes correct method', () async {
        await ref.getName();

        expect(log, <Matcher>[
          isMethodCall(
            'StorageReference#getName',
            arguments: <String, dynamic>{
              'path': 'avatars/large/image.jpg',
            },
          ),
        ]);
      });

      test('returns correct result', () async {
        expect(await ref.getName(), 'image.jpg');
      });
    });
  });

  group('getPath', () {
    final List<MethodCall> log = <MethodCall>[];

    StorageReference ref;

    setUp(() {
      FirebaseStorage.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return 'avatars/large/image.jpg';
      });
      ref = FirebaseStorage.instance
          .ref()
          .child('avatars')
          .child('large')
          .child('image.jpg');
    });

    test('invokes correct method', () async {
      await ref.getPath();

      expect(log, <Matcher>[
        isMethodCall(
          'StorageReference#getPath',
          arguments: <String, dynamic>{
            'path': 'avatars/large/image.jpg',
          },
        ),
      ]);
    });

    test('returns correct result', () async {
      expect(await ref.getPath(), 'avatars/large/image.jpg');
    });
  });
}
