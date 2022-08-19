// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ios_platform_images/ios_platform_images.dart';

import 'package:ios_platform_images_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'load ios bundled image',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Flutter logo'), findsOneWidget);
    },
  );

  testWidgets(
    'load ios system images',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Smiling face'), findsOneWidget);
      expect(find.bySemanticsLabel('Sprinting hare'), findsOneWidget);
      expect(find.bySemanticsLabel('Ladybug'), findsOneWidget);
    },
  );

  testWidgets(
    'ios system image error case',
    (WidgetTester tester) async {
      final Completer<ImageInfo> _completer = Completer<ImageInfo>();

      final ImageProvider imageProvider =
          IosPlatformImages.loadSystemImage('invalid_symbol', 10);

      imageProvider.resolve(ImageConfiguration.empty).completer?.addListener(
            ImageStreamListener(
              (ImageInfo info, bool _) => _completer.complete(info),
              onError: (Object exception, StackTrace? stack) => () {
                _completer.completeError(exception);
              },
            ),
          );

      await expectLater(_completer.future, throwsArgumentError);
    },
  );
}
