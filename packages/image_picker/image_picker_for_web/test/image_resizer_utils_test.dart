// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';

import 'package:image_picker_for_web/src/image_resizer_utils.dart';

void main() {
  group('Image Resizer Utils', () {
    group("calculateSizeOfScaledImage", () {
      test(
          "scaled image height and width are same if max width and max height are same as image's width and height",
          () {
        expect(calculateSizeOfDownScaledImage(Size(500, 300), 500, 300),
            Size(500, 300));
      });

      test(
          "scaled image height and width are same if max width and max height are null",
          () {
        expect(calculateSizeOfDownScaledImage(Size(500, 300), null, null),
            Size(500, 300));
      });

      test("image size is scaled when maxWidth is set", () {
        final imageSize = Size(500, 300);
        final maxWidth = 400;
        final scaledSize = calculateSizeOfDownScaledImage(
            Size(imageSize.width, imageSize.height), maxWidth.toDouble(), null);
        expect(scaledSize.height <= imageSize.height, true);
        expect(scaledSize.width <= maxWidth, true);
      });

      test("image size is scaled when maxHeight is set", () {
        final imageSize = Size(500, 300);
        final maxHeight = 400;
        final scaledSize = calculateSizeOfDownScaledImage(
            Size(imageSize.width, imageSize.height),
            null,
            maxHeight.toDouble());
        expect(scaledSize.height <= maxHeight, true);
        expect(scaledSize.width <= imageSize.width, true);
      });

      test("image size is scaled when both maxWidth and maxHeight is set", () {
        final imageSize = Size(1120, 2000);
        final maxHeight = 1200;
        final maxWidth = 99;
        final scaledSize = calculateSizeOfDownScaledImage(
            Size(imageSize.width, imageSize.height),
            maxWidth.toDouble(),
            maxHeight.toDouble());
        expect(scaledSize.height <= maxHeight, true);
        expect(scaledSize.width <= maxWidth, true);
      });
    });
    group("imageResizeNeeded", () {
      test("image needs to be resized when maxWidth is set", () {
        expect(imageResizeNeeded(50, null, null), true);
      });

      test("image needs to be resized when maxHeight is set", () {
        expect(imageResizeNeeded(null, 50, null), true);
      });

      test("image needs to be resized  when imageQuality is set", () {
        expect(imageResizeNeeded(null, null, 100), true);
      });

      test("image will not be resized when imageQuality is not valid", () {
        expect(imageResizeNeeded(null, null, 101), false);
        expect(imageResizeNeeded(null, null, -1), false);
      });
    });

    group("isImageQualityValid", () {
      test("image quality is valid in 0 to 100", () {
        expect(isImageQualityValid(50), true);
        expect(isImageQualityValid(0), true);
        expect(isImageQualityValid(100), true);
      });

      test(
          "image quality is not valid when imageQuality is less than 0 or greater than 100",
          () {
        expect(isImageQualityValid(-1), false);
        expect(isImageQualityValid(101), false);
      });
    });
  });
}
