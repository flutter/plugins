// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_platform_interface/src/errors/in_app_purchase_error.dart';

void main() {
  test('toString: Should return a description of the error', () {
    final IAPError exceptionNoDetails = IAPError(
      code: 'error_code',
      message: 'dummy_message',
      source: 'dummy_source',
    );

    expect(exceptionNoDetails.toString(),
        'IAPError(code: error_code, source: dummy_source, message: dummy_message, details: null)');

    final IAPError exceptionWithDetails = IAPError(
      code: 'error_code',
      message: 'dummy_message',
      source: 'dummy_source',
      details: 'dummy_details',
    );

    expect(exceptionWithDetails.toString(),
        'IAPError(code: error_code, source: dummy_source, message: dummy_message, details: dummy_details)');
  });
}
