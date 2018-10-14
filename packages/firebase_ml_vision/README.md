# ML Kit for Firebase

[![pub package](https://img.shields.io/pub/v/firebase_ml_vision.svg)](https://pub.dartlang.org/packages/firebase_ml_vision)

A Flutter plugin to use the [ML Kit for Firebase API](https://firebase.google.com/docs/ml-kit/).

For Flutter plugins for other Firebase products, see [FlutterFire.md](https://github.com/flutter/plugins/blob/master/FlutterFire.md).

*Note*: This plugin is still under development, and some APIs might not be available yet. [Feedback](https://github.com/flutter/flutter/issues) and [Pull Requests](https://github.com/flutter/plugins/pulls) are most welcome!

## Usage

To use this plugin, add `firebase_ml_vision` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). You must also configure Firebase for each platform project: Android and iOS (see the example folder or https://codelabs.developers.google.com/codelabs/flutter-firebase/#4 for step by step details).

### Android
Optional but recommended: If you use the on-device API, configure your app to automatically download the ML model to the device after your app is installed from the Play Store. To do so, add the following declaration to your app's AndroidManifest.xml file:

```manifest
<application ...>
  ...
  <meta-data
    android:name="com.google.firebase.ml.vision.DEPENDENCIES"
    android:value="ocr" />
  <!-- To use multiple models: android:value="ocr,label,barcode,face" -->
</application>
```

## Using an On-device FirbaseVisionDetector

### 1. Create a `FirebaseVisionImage`.

Create a `FirebaseVisionImage` object from your image. To create a `FirebaseVisionImage` from an image `File` object:

```dart
final File imageFile = getImageFile();
final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(imageFile);
```

### 2. Create an instance of a detector.

Get an instance of a `FirebaseVisionDetector`.

```dart
final BarcodeDetector barcodeDetector = FirebaseVision.instance.barcodeDetector();
final CloudLabelDetector cloudLabelDetector = FirebaseVision.instance.cloudLabelDetector();
final FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
final LabelDetector labelDetector = FirebaseVision.instance.labelDetector();
final TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
```

You can also configure all detectors except `TextRecognizer` with desired options.

```dart
final LabelDetector detector = FirebaseVision.instance.labelDetector(
  LabelDetectorOptions(confidenceThreshold: 0.75),
);
```

### 3. Call `detectInImage()` with `visionImage`.

```dart
final List<Barcode> barcodes = await barcodeDetector.detectInImage(visionImage);
final List<Label> labels = await cloudLabelDetector.detectInImage(visionImage);
final List<Face> faces = await faceDetector.detectInImage(visionImage);
final List<Label> labels = await labelDetector.detectInImage(visionImage);
final VisionText visionText = await textRecognizer.detectInImage(visionImage);
```

### 4. Extract data.

a. Extract barcodes.

```dart
for (Barcode barcode in barcodes) {
  final Rectangle<int> boundingBox = barcode.boundingBox;
  final List<Point<int>> cornerPoints = barcode.cornerPoints;

  final String rawValue = barcode.rawValue;

  final BarcordeValueType valueType = barcode.valueType;

  // See API reference for complete list of supported types
  switch (valueType) {
    case BarcodeValueType.wifi:
      final String ssid = barcode.wifi.ssid;
      final String password = barcode.wifi.password;
      final BarcodeWiFiEncryptionType type = barcode.wifi.encryptionType;
      break;
    case BarcodeValueType.url:
      final String title = barcode.url.title;
      final String url = barcode.url.url;
      break;
  }
}
```

b. Extract faces.

```dart
for (Face face in faces) {
  final Rectangle<int> boundingBox = face.boundingBox;

  final double rotY = face.headEulerAngleY; // Head is rotated to the right rotY degrees
  final double rotZ = face.headEulerAngleZ; // Head is tilted sideways rotZ degrees

  // If landmark detection was enabled with FaceDetectorOptions (mouth, ears,
  // eyes, cheeks, and nose available):
  final FaceLandmark leftEar = face.getLandmark(FaceLandmarkType.leftEar);
  if (leftEar != null) {
    final Point<double> leftEarPos = leftEar.position;
  }

  // If classification was enabled with FaceDetectorOptions:
  if (face.smilingProbability != null) {
    final double smileProb = face.smilingProbability;
  }

  // If face tracking was enabled with FaceDetectorOptions:
  if (face.trackingId != null) {
    final int id = face.trackingId;
  }
}
```

c. Extract labels.

```dart
for (Label label in labels) {
  final String text = label.label;
  final String entityId = label.entityId;
  final double confidence = label.confidence;
}
```

d. Extract text.

```dart
String text = visionText.text;
for (TextBlock block in visionText.blocks) {
  final Rectangle<int> boundingBox = block.boundingBox;
  final List<Point<int>> cornerPoints = block.cornerPoints;
  final String text = block.text;
  final List<RecognizedLanguage> languages = block.recognizedLanguages;

  for (TextLine line in block.lines) {
    // Same getters as TextBlock
    for (TextElement element in line.elements) {
      // Same getters as TextBlock
    }
  }
}
```

## Getting Started

See the `example` directory for a complete sample app using ML Kit for Firebase.
