// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';

void main() {
  testWidgets('FirebaseAuth example widget test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.tap(find.text('Test registration'));
    await tester.pumpAndSettle();
    expect(find.text('Registration'), findsOneWidget);
  });
}
