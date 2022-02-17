// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_android/src/instance_manager.dart';

void main() {
  group('InstanceManager', () {
    late InstanceManager testInstanceManager;

    setUp(() {
      testInstanceManager = InstanceManager();
    });

    test('tryAddInstance', () {
      final Object object = Object();

      expect(testInstanceManager.tryAddInstance(object), 0);
      expect(testInstanceManager.getInstanceId(object), 0);
      expect(testInstanceManager.getInstance(0), object);
      expect(testInstanceManager.tryAddInstance(object), null);
    });

    test('removeInstance', () {
      final Object object = Object();
      testInstanceManager.tryAddInstance(object);

      expect(testInstanceManager.removeInstance(object), 0);
      expect(testInstanceManager.getInstanceId(object), null);
      expect(testInstanceManager.getInstance(0), null);
      expect(testInstanceManager.removeInstance(object), null);
    });
  });
}
