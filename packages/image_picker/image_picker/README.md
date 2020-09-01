# Image Picker plugin for Flutter

[![pub package](https://img.shields.io/pub/v/image_picker.svg)](https://pub.dartlang.org/packages/image_picker)

A Flutter plugin for iOS and Android for picking images from the image library,
and taking new pictures with the camera.

## Installation

First, add `image_picker` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

### iOS

Add the following keys to your _Info.plist_ file, located in `<project root>/ios/Runner/Info.plist`:

* `NSPhotoLibraryUsageDescription` - describe why your app needs permission for the photo library. This is called _Privacy - Photo Library Usage Description_ in the visual editor.
* `NSCameraUsageDescription` - describe why your app needs access to the camera. This is called _Privacy - Camera Usage Description_ in the visual editor.
* `NSMicrophoneUsageDescription` - describe why your app needs access to the microphone, if you intend to record videos. This is called _Privacy - Microphone Usage Description_ in the visual editor.

### Android

#### API 29+
No configuration required - the plugin should work out of the box.

#### API < 29

Add `android:requestLegacyExternalStorage="true"` as an attribute to the `<application>` tag in AndroidManifest.xml. The [attribute](https://developer.android.com/training/data-storage/compatibility) is `false` by default on apps targeting Android Q. 

### Example

``` dart
import 'package:image_picker/image_picker.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Picker Example'),
      ),
      body: Center(
        child: _image == null
            ? Text('No image selected.')
            : Image.file(_image),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
```

### Handling MainActivity destruction on Android

Android system -- although very rarely -- sometimes kills the MainActivity after the image_picker finishes. When this happens, we lost the data selected from the image_picker. You can use `retrieveLostData` to retrieve the lost data in this situation. For example:

```dart
Future<void> retrieveLostData() async {
  final LostData response =
      await picker.getLostData();
  if (response.isEmpty) {
    return;
  }
  if (response.file != null) {
    setState(() {
      if (response.type == RetrieveType.video) {
        _handleVideo(response.file);
      } else {
        _handleImage(response.file);
      }
    });
  } else {
    _handleError(response.exception);
  }
}
```

There's no way to detect when this happens, so calling this method at the right place is essential. We recommend to wire this into some kind of start up check. Please refer to the example app to see how we used it.

## Deprecation warnings in `pickImage`, `pickVideo` and `LostDataResponse`

Starting with version **0.6.7** of the image_picker plugin, the API of the plugin changed slightly to allow for web implementations to exist.

The **old methods that returned `dart:io` File objects were marked as deprecated**, and a new set of methods that return [`PickedFile` objects](https://pub.dev/documentation/image_picker_platform_interface/latest/image_picker_platform_interface/PickedFile-class.html) were introduced.

### How to migrate from to ^0.6.7

#### Instantiate the `ImagePicker`

The new ImagePicker API does not rely in static methods anymore, so the first thing you'll need to do is to create a new instance of the plugin where you need it:

```dart
final _picker = ImagePicker();
```

#### Call the new methods

The new methods **receive the same parameters as before**, but they **return a `PickedFile`, instead of a `File`**. The `LostDataResponse` class has been replaced by the [`LostData` class](https://pub.dev/documentation/image_picker_platform_interface/latest/image_picker_platform_interface/LostData-class.html).

| Old API | New API |
|---------|---------|
| `File image = await ImagePicker.pickImage(...)` | `PickedFile image = await _picker.getImage(...)` |
| `File video = await ImagePicker.pickVideo(...)` | `PickedFile video = await _picker.getVideo(...)` |
| `LostDataResponse response = await ImagePicker.retrieveLostData()` | `LostData response = await _picker.getLostData()` |

#### `PickedFile` to `File`

If your app needs dart:io `File` objects to operate, you may transform `PickedFile` to `File` like so:

```dart
final pickedFile = await _picker.getImage(...);
final File file = File(pickedFile.path);
```

You may also retrieve the bytes from the pickedFile directly if needed:

```dart
final bytes = await pickedFile.readAsBytes();
```

#### Getting ready for the web platform

Note that on the web platform (`kIsWeb == true`), `File` is not available, so the `path` of the `PickedFile` will point to a network resource instead:

```dart
if (kIsWeb) {
  image = Image.network(pickedFile.path);
} else {
  image = Image.file(File(pickedFile.path));
}
```

Alternatively, the code may be unified at the expense of memory utilization:

```dart
image = Image.memory(await pickedFile.readAsBytes())
```

Take a look at the changes to the `example` app introduced in version 0.6.7 to see the migration steps applied there.
