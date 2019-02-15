// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  group('$ImagePicker', () {
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/image_picker');

    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return '';
      });

      log.clear();
    });

    group('#pickImage', () {
      test('passes the image source argument correctly', () async {
        await ImagePicker.pickImage(source: ImageSource.camera);
        await ImagePicker.pickImage(source: ImageSource.gallery);

        expect(
          log,
          <Matcher>[
            isMethodCall('pickImage', arguments: <String, dynamic>{
              'source': 0,
              'maxWidth': null,
              'maxHeight': null,
              'crop': false,
            }),
            isMethodCall('pickImage', arguments: <String, dynamic>{
              'source': 1,
              'maxWidth': null,
              'maxHeight': null,
              'crop': false,
            }),
          ],
        );
      });

      test('passes the width and height arguments correctly', () async {
        await ImagePicker.pickImage(source: ImageSource.camera);
        await ImagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: 10.0,
        );
        await ImagePicker.pickImage(
          source: ImageSource.camera,
          maxHeight: 10.0,
        );
        await ImagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: 10.0,
          maxHeight: 20.0,
        );

        expect(
          log,
          <Matcher>[
            isMethodCall('pickImage', arguments: <String, dynamic>{
              'source': 0,
              'maxWidth': null,
              'maxHeight': null,
              'crop': false,
            }),
            isMethodCall('pickImage', arguments: <String, dynamic>{
              'source': 0,
              'maxWidth': 10.0,
              'maxHeight': null,
              'crop': false,
            }),
            isMethodCall('pickImage', arguments: <String, dynamic>{
              'source': 0,
              'maxWidth': null,
              'maxHeight': 10.0,
              'crop': false,
            }),
            isMethodCall('pickImage', arguments: <String, dynamic>{
              'source': 0,
              'maxWidth': 10.0,
              'maxHeight': 20.0,
              'crop': false,
            }),
          ],
        );
      });

      test('passes the crop argument correctly', () async {
        await ImagePicker.pickImage(source: ImageSource.camera, crop: true);
        await ImagePicker.pickImage(source: ImageSource.camera, crop: false);

        expect(
          log,
          <Matcher>[
            isMethodCall('pickImage', arguments: <String, dynamic>{
              'source': 0,
              'maxWidth': null,
              'maxHeight': null,
              'crop': true,
            }),
            isMethodCall('pickImage', arguments: <String, dynamic>{
              'source': 0,
              'maxWidth': null,
              'maxHeight': null,
              'crop': false,
            }),
          ],
        );
      });

      test('does not accept a negative width or height argument', () {
        expect(
          ImagePicker.pickImage(source: ImageSource.camera, maxWidth: -1.0),
          throwsArgumentError,
        );

        expect(
          ImagePicker.pickImage(source: ImageSource.camera, maxHeight: -1.0),
          throwsArgumentError,
        );
      });

      test('does not accept a zero width or height argument', () {
        expect(
          ImagePicker.pickImage(source: ImageSource.camera, maxWidth: 0.0),
          throwsArgumentError,
        );

        expect(
          ImagePicker.pickImage(source: ImageSource.camera, maxHeight: 0.0),
          throwsArgumentError,
        );
      });

      test('handles a null image path response gracefully', () async {
        channel.setMockMethodCallHandler((MethodCall methodCall) => null);

        expect(
            await ImagePicker.pickImage(source: ImageSource.gallery), isNull);
        expect(await ImagePicker.pickImage(source: ImageSource.camera), isNull);
      });
    });
  });
}
