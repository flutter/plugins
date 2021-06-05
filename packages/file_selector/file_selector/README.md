# file_selector

[![pub package](https://img.shields.io/pub/v/file_selector.svg)](https://pub.dartlang.org/packages/file_selector)

A Flutter plugin that manages files and interactions with file dialogs.

## Usage
To use this plugin, add `file_selector` as a [dependency in your pubspec.yaml file](https://flutter.dev/platform-plugins/).

### Examples
Here are small examples that show you how to use the API.  
Please also take a look at our [example][example] app.

#### Open a single file
``` dart
final typeGroup = XTypeGroup(label: 'images', extensions: ['jpg', 'png']);
final file = await openFile(acceptedTypeGroups: [typeGroup]);
```

#### Open multiple files at once
``` dart
final typeGroup = XTypeGroup(label: 'images', extensions: ['jpg', 'png']);
final files = await openFiles(acceptedTypeGroups: [typeGroup]);
```

#### Saving a file
```dart
final path = await getSavePath();
final name = "hello_file_selector.txt";
final data = Uint8List.fromList("Hello World!".codeUnits);
final mimeType = "text/plain";
final file = XFile.fromData(data, name: name, mimeType: mimeType);
await file.saveTo(path);
```

[example]:./example
