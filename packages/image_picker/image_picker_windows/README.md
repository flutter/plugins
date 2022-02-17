# image\_picker\_windows

A Windows implementation of [`image_picker`][1].

### pickImage()
The arguments `maxWidth`, `maxHeight` and `imageQuality` are not supported.

### pickVideo()
The argument `maxDuration` is not supported on Windows.

## Usage

### Import the package

This package is not yet [endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin), which means you need to add 
not only the `image_picker`, as well as the `image_picker_windows`.

### Use the plugin

You should be able to use `package:image_picker` _almost_ as normal, since this package is not fully featured yet.

If you want to use the path directly, your code would need look like this:

```dart
...
Image.file(File(pickedFile.path));
...
```

Or, using bytes:

```dart
...
Image.memory(await pickedFile.readAsBytes())
...
```
