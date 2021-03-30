// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_linux/path_provider_linux.dart';

void main() {
  test('getTemporaryPath', () async {
    final plugin = PathProviderLinux();
    expect(await plugin.getTemporaryPath(), '/tmp');
  });
}
