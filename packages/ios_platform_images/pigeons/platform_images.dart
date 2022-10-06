// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/platform_images_api.g.dart',
  objcHeaderOut: 'ios/Classes/PlatformImagesApi.g.h',
  objcSourceOut: 'ios/Classes/PlatformImagesApi.g.m',
  objcOptions: ObjcOptions(
    prefix: 'FLT',
  ),
  copyrightHeader: 'pigeons/copyright.txt',
))
class PlatformImage {
  double? scale;
  Uint8List? bytes;
}

enum FontWeight {
  ultraLight,
  thin,
  light,
  regular,
  medium,
  semibold,
  bold,
  heavy,
  black,
}

@HostApi()
abstract class PlatformImagesApi {
  PlatformImage getSystemImage(String name, double size, FontWeight weight,
      List<double> colorsRGBA, bool preferMulticolor);
  PlatformImage getPlatformImage(String name);
  String? resolveURL(String name, String? extension);
}
