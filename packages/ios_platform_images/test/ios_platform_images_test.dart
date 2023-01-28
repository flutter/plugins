// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_platform_images/platform_images_api.g.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
@GenerateNiceMocks(<MockSpec<dynamic>>[MockSpec<PlatformImagesApi>()])
import 'ios_platform_images_test.mocks.dart';

void main() {
  final MockPlatformImagesApi api = MockPlatformImagesApi();

  TestWidgetsFlutterBinding.ensureInitialized();

  final PlatformImage fakePlatformImage =
      PlatformImage(scale: 1, bytes: Uint8List(1));
  final PlatformImage fakeSystemImage =
      PlatformImage(scale: 1, bytes: Uint8List(2));

  setUp(() {
    when(api.resolveURL('foobar', null)).thenAnswer((_) async => '42');
    when(api.getPlatformImage('platformImage'))
        .thenAnswer((_) async => fakePlatformImage);
    when(api.getSystemImage(
            'systemImage', 2, FontWeight.bold, <double>[1, 1, 1], true))
        .thenAnswer((_) async => fakeSystemImage);
  });

  test('resolveURL', () async {
    expect(await api.resolveURL('foobar', null), '42');
  });

  test('getPlatformImage', () async {
    expect(await api.getPlatformImage('platformImage'), fakePlatformImage);
  });

  test('getSystemImage', () async {
    expect(
        await api.getSystemImage(
            'systemImage', 2, FontWeight.bold, <double>[1, 1, 1], true),
        fakeSystemImage);
  });
}
