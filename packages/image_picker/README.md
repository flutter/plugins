# Image Picker plugin for Flutter

[![pub package](https://img.shields.io/pub/v/image_picker.svg)](https://pub.dartlang.org/packages/image_picker)

A Flutter plugin for iOS and Android for picking images from the image library,
and taking new pictures with the camera.

*Note*: This plugin is still under development, and some APIs might not be available yet. [Feedback welcome](https://github.com/flutter/flutter/issues) and [Pull Requests](https://github.com/flutter/plugins/pulls) are most welcome!

## Installation

First, add `image_picker` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

### iOS

Add the following keys to your _Info.plist_ file, located in `<project root>/ios/Runner/Info.plist`:

* `NSPhotoLibraryUsageDescription` - describe why your app needs permission for the photo library. This is called _Privacy - Photo Library Usage Description_ in the visual editor.
* `NSCameraUsageDescription` - describe why your app needs access to the camera. This is called _Privacy - Camera Usage Description_ in the visual editor.

### Android

Add the following permissions to your Android Manifest, located in `<project root>/android/app/src/main/AndroidManifest.xml:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

You're good to go!

### Example

``` dart
class _MyHomePageState extends State<MyHomePage> {
  File imageFile;

  getImage() async {
    var _fileName = await ImagePicker.pickImage();
    setState(() {
      imageFile = _fileName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Image Picker Example'),
      ),
      body: new Center(
        child: imageFile == null
            ? new Text('No image selected.')
            : new Image.file(imageFile),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: new Icon(Icons.add_a_photo),
      ),
    );
  }
}
```
