# Google ML Kit for Firebase

[![pub package](https://img.shields.io/pub/v/firebase_ml_vision.svg)](https://pub.dartlang.org/packages/firebase_ml_vision)

A Flutter plugin to use the [Google ML Kit for Firebase API](https://firebase.google.com/docs/ml-kit/).

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
  <!-- To use multiple models: android:value="ocr,model2,model3" -->
</application>
```

## On-device Text Recognition

To use the on-device text recognition model, run the text detector as described below:

1. Create a `FirebaseVisionImage` object from your image.

To create a `FirebaseVisionImage` from an image `File` object:

```dart
final File imageFile = getImageFile();
final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(imageFile);
```

2. Get an instance of `TextDetector` and pass `visionImage` to `detectInImage().`

```dart
final TextDetector detector = FirebaseVision.instance.getTextDetector();
final List<TextBlock> blocks = await detector.detectInImage(visionImage);

detector.close();
```

3. Extract text and text locations from blocks of recognized text.

```dart
for (TextBlock block in blocks) {
  final Rectangle<int> boundingBox = block.boundingBox;
  final List<Point<int>> cornerPoints = block.cornerPoints;
  final String text = block.text;

  for (TextLine line in block.lines) {
    // ...

    for (TextElement element in line.elements) {
      // ...
    }
  }
}
```

## Getting Started

See the `example` directory for a complete sample app using Google ML Kit for Firebase.
