// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  group('$ImagePicker', () {
    const MethodChannel channel = const MethodChannel('image_picker');

    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return '';
      });

      log.clear();
    });

    group('#pickImage', () {
      test('passes the width and height arguments correctly', () async {
        await ImagePicker.pickImage();
        await ImagePicker.pickImage(maxWidth: 10.0);
        await ImagePicker.pickImage(maxHeight: 10.0);
        await ImagePicker.pickImage(
          maxWidth: 10.0,
          maxHeight: 20.0,
        );

        expect(
          log,
          <Matcher>[
            isMethodCall('pickImage', arguments: <String, double>{
              'maxWidth': null,
              'maxHeight': null,
            }),
            isMethodCall('pickImage', arguments: <String, double>{
              'maxWidth': 10.0,
              'maxHeight': null,
            }),
            isMethodCall('pickImage', arguments: <String, double>{
              'maxWidth': null,
              'maxHeight': 10.0,
            }),
            isMethodCall('pickImage', arguments: <String, double>{
              'maxWidth': 10.0,
              'maxHeight': 20.0,
            }),
          ],
        );
      });

      test('does not accept a negative width or height argument', () {
        expect(ImagePicker.pickImage(maxWidth: -1.0), throwsArgumentError);
        expect(ImagePicker.pickImage(maxHeight: -1.0), throwsArgumentError);
      });
    });
  });
}
