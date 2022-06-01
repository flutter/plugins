// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartTestOut: 'test/test_api.dart',
  objcHeaderOut: 'ios/Classes/messages.g.h',
  objcSourceOut: 'ios/Classes/messages.g.m',
  objcOptions: ObjcOptions(
    prefix: 'FLT',
  ),
  copyrightHeader: 'pigeons/copyright.txt',
))
class MaxSize {
  MaxSize(this.width, this.height);
  double? width;
  double? height;
}

// Corresponds to `CameraDevice` from the platform interface package.
enum SourceCamera { rear, front }

// Corresponds to `ImageSource` from the platform interface package.
enum SourceType { camera, gallery }

class SourceSpecification {
  SourceSpecification(this.type, this.camera);
  SourceType type;
  SourceCamera? camera;
}

// Corresponds to `MediaSelectionType` from the platform interface package.
enum IOSMediaSelectionType { image, video }

// TODO(BeMacized): Enums need be wrapped in a data class because thay can't
// be used as primitive arguments. See https://github.com/flutter/flutter/issues/87307
class IOSMediaSelectionTypeData {
  late IOSMediaSelectionType value;
}

@HostApi(dartHostTestHandler: 'TestHostImagePickerApi')
abstract class ImagePickerApi {
  @async
  @ObjCSelector('pickImageWithSource:maxSize:quality:')
  String? pickImage(
      SourceSpecification source, MaxSize maxSize, int? imageQuality);
  @async
  @ObjCSelector('pickMultiImageWithMaxSize:quality:')
  List<String>? pickMultiImage(MaxSize maxSize, int? imageQuality);
  @async
  @ObjCSelector('pickMediaWithMaxSize:quality:allowMultiple:allowedTypes:')
  List<String>? pickMedia(MaxSize maxSize, int? imageQuality,
      bool allowMultiple, List<IOSMediaSelectionTypeData> allowedTypes);
  @async
  @ObjCSelector('pickVideoWithSource:maxDuration:')
  String? pickVideo(SourceSpecification source, int? maxDurationSeconds);
}
