import 'package:flutter/foundation.dart';

import '../camera.dart';

/// Converts [ImageFormatGroup] to integer definition of the raw format
int imageFormatGroupAsIntegerValue(ImageFormatGroup imageFormatGroup) {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    switch (imageFormatGroup) {
    // kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
      case ImageFormatGroup.yuv420:
        return 875704438;
    // kCVPixelFormatType_32BGRA
      case ImageFormatGroup.bgra8888:
        return 1111970369;
      case ImageFormatGroup.jpeg:
      case ImageFormatGroup.unknown:
        return 0;
    }
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    switch (imageFormatGroup) {
    // kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
      case ImageFormatGroup.yuv420:
        return 35;
    // kCVPixelFormatType_32BGRA
      case ImageFormatGroup.bgra8888:
      case ImageFormatGroup.unknown:
        return 0;
      case ImageFormatGroup.jpeg:
        return 256;
    }
  }
  // unknown ImageFormatGroup or unsupported platform
  return 0;
}