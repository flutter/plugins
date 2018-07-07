import 'dart:math';

class VisionModelUtils {
  static const String rectLeft = "left";
  static const String rectTop = "top";
  static const String rectWidth = "width";
  static const String rectHeight = "height";

  static Rectangle<int> mlRectToRectangle(Map<dynamic, dynamic> data) {
    if (data != null) {
      return Rectangle<int>(
        data[rectLeft],
        data[rectTop],
        data[rectWidth],
        data[rectHeight],
      );
    } else {
      return null;
    }
  }
}
