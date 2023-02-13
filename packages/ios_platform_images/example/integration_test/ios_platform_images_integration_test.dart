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

      final Finder flutterLogoFinder = find.byKey(const Key('Flutter logo'));
      expect(flutterLogoFinder, findsOneWidget);
      final Size flutterLogoSize = flutterLogoFinder.evaluate().single.size ??
          fail('Widget size is null');

      expect(flutterLogoSize.width, equals(101));
      expect(flutterLogoSize.height, equals(125));
    },
  );

  testWidgets(
    'load ios system images',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final Finder smilingFaceFinder = find.byKey(const Key('Smiling face'));
      expect(smilingFaceFinder, findsOneWidget);
      final Size smilingFaceSize = smilingFaceFinder.evaluate().single.size ??
          fail('Smiling face widget size is null');
      expect(smilingFaceSize.width.round(), equals(100));
      expect(smilingFaceSize.height.round(), equals(96));

      final Finder hammerCircleFinder = find.byKey(const Key('Hammer circle'));
      expect(hammerCircleFinder, findsOneWidget);
      final Size hammerCircleSize = hammerCircleFinder.evaluate().single.size ??
          fail('Hammer circle widget size is null');
      expect(hammerCircleSize.width.round(), equals(100));
      expect(hammerCircleSize.height.round(), equals(96));

      final Finder ladybugFinder = find.byKey(const Key('Ladybug'));
      expect(ladybugFinder, findsOneWidget);
      final Size ladybugSize = ladybugFinder.evaluate().single.size ??
          fail('Ladybug widget size is null');
      expect(ladybugSize.width.round(), equals(116));
      expect(ladybugSize.height.round(), equals(111));
    },
  );

  testWidgets(
    'ios system image error case',
    (WidgetTester tester) async {
      final Completer<ImageInfo> completer = Completer<ImageInfo>();

      final ImageProvider imageProvider =
          IosPlatformImages.loadSystemImage('invalid_symbol', 10);

      imageProvider.resolve(ImageConfiguration.empty).completer?.addListener(
            ImageStreamListener(
              (ImageInfo info, bool _) => completer.complete(info),
              onError: (Object exception, StackTrace? stack) {
                completer.completeError(exception);
              },
            ),
          );

      await expectLater(completer.future, throwsArgumentError);
    },
  );
}
