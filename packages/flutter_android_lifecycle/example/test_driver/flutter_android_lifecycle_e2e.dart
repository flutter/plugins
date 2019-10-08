// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:e2e/e2e.dart';
import 'package:flutter_android_lifecycle_example/main.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('loads', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
  });
}
