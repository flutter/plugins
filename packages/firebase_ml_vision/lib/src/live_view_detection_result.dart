part of firebase_ml_vision;

abstract class LiveViewDetectionResult {
  final Size size;
  dynamic get data;

  LiveViewDetectionResult(this.size);
}

class LiveViewTextDetectionResult extends LiveViewDetectionResult {
  final List<TextBlock> data;

  LiveViewTextDetectionResult(this.data, Size imageSize) : super(imageSize);
}

class LiveViewBarcodeDetectionResult extends LiveViewDetectionResult {
  final List<Barcode> data;

  LiveViewBarcodeDetectionResult(this.data, Size imageSize) : super(imageSize);
}

class LiveViewFaceDetectionResult extends LiveViewDetectionResult {
  final List<Face> data;

  LiveViewFaceDetectionResult(this.data, Size imageSize) : super(imageSize);
}

class LiveViewLabelDetectionResult extends LiveViewDetectionResult {
  final List<Label> data;

  LiveViewLabelDetectionResult(this.data, Size imageSize) : super(imageSize);
}

class LiveViewDefaultDetectionResult extends LiveViewDetectionResult {

  LiveViewDefaultDetectionResult() : super(Size.zero);

  @override
  dynamic get data {
    return null;
  }
}
