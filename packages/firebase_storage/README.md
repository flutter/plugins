# Firebase Cloud Storage for Flutter

[![pub package](https://img.shields.io/pub/v/firebase_storage.svg)](https://pub.dartlang.org/packages/firebase_storage)

A Flutter plugin to use the [Firebase Cloud Storage API](https://firebase.google.com/products/storage/).

For Flutter plugins for other Firebase products, see [FlutterFire.md](https://github.com/flutter/plugins/blob/master/FlutterFire.md).

*Note*: This plugin is still under development, and some APIs might not be available yet. [Feedback](https://github.com/flutter/flutter/issues) and [Pull Requests](https://github.com/flutter/plugins/pulls) are most welcome!

## Usage

To use this plugin, add `firebase_storage` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

### Logging

If you wish to see status events for your upload tasks in your logs, you should listen to the `StorageUploadTask.events` stream.  
This could look like the following if you are using `StorageReference.putData`:

```dart
final StorageReference storageReference = FirebaseStorage().ref().child(path);

final StorageUploadTask uploadTask = storageReference.putData(data);

final StreamSubscription<StorageTaskEvent> streamSubscription = uploadTask.events.listen((event) {
  // You can use this to notify yourself or your user in any kind of way.
  // For example: you could use the uploadTask.events stream in a StreamBuilder instead
  // to show your user what the current status is. In that case, you would not need to cancel any
  // subscription as StreamBuilder handles this automatically.

  // Here, every StorageTaskEvent concerning the upload is printed to the logs.
  print('EVENT ${event.type}');
});

// Cancel your subscription when done.
await uploadTask.onComplete;
streamSubscription.cancel();
```

## Getting Started

See the `example` directory for a complete sample app using Firebase Cloud Storage.
