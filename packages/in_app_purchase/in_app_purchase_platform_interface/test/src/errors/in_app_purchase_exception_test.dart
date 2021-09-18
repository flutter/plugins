// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_platform_interface/src/errors/in_app_purchase_exception.dart';

void main() {
  test('toString: Should return a description of the exception', () {
    final InAppPurchaseException exception = InAppPurchaseException(
      code: 'error_code',
      message: 'dummy message',
      source: 'dummy_source',
    );

    // Act
    final String actual = exception.toString();

    // Assert
    expect(actual,
        'InAppPurchaseException(error_code, dummy message, dummy_source)');
  });
}
