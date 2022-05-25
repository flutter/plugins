// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_wkwebview/src/common/instance_manager.dart';
import 'package:webview_flutter_wkwebview/src/common/web_kit.pigeon.dart';
import 'package:webview_flutter_wkwebview/src/foundation/foundation_api_impls.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$FunctionFlutterApi', () {
    late InstanceManager instanceManager;

    setUp(() {
      instanceManager = InstanceManager();
    });

    test('dispose', () {
      void function() {}
      final int functionInstanceId = instanceManager.tryAddInstance(function)!;

      FoundationFlutterApis.instance = FoundationFlutterApis(
        instanceManager: instanceManager,
      )..ensureSetUp();

      FoundationFlutterApis.instance.functionFlutterApi
          .dispose(functionInstanceId);
      expect(instanceManager.getInstanceId(function), isNull);
    });
  });
}
