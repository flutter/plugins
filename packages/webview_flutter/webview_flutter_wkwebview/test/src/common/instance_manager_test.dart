// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_wkwebview/src/common/instance_manager.dart';

void main() {
  group('InstanceManager', () {
    late InstanceManager testInstanceManager;

    setUp(() {
      testInstanceManager = InstanceManager();
    });

    test('tryAddInstance', () {
      final Object object = Object();

      expect(testInstanceManager.addDartCreatedInstance(object), 0);
      expect(testInstanceManager.getIdentifier(object), 0);
      expect(testInstanceManager.getInstance(0), object);
    });

    test('removeInstance', () {
      final Object object = Object();
      testInstanceManager.addDartCreatedInstance(object);

      expect(testInstanceManager.removeWeakReference(object), 0);
      expect(testInstanceManager.getIdentifier(object), null);
      expect(testInstanceManager.getInstance(0), null);
      expect(testInstanceManager.removeWeakReference(object), null);
    });
  });
}
