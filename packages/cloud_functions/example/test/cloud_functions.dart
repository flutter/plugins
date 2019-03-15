// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_functions/cloud_functions.dart';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  group('$CloudFunctions', () {
    test('call', () async {
      final dynamic response = await CloudFunctions.instance.call(
        functionName: 'repeat',
        parameters: <String, dynamic>{
          'foo': 'bar',
          'baz': 1,
        },
      );
      expect(response['foo'], 'bar');
      expect(response['baz'], 1);
      final dynamic response2 = await CloudFunctions.instance.call(
        functionName: 'repeat',
        parameters: <String, dynamic>{
          'foo': 'quox',
          'baz': 42,
        },
      );
      expect(response2['foo'], 'quox');
      expect(response2['baz'], 42);
    });
  });
}