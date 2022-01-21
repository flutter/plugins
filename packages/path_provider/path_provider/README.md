# path_provider

[![pub package](https://img.shields.io/pub/v/path_provider.svg)](https://pub.dev/packages/path_provider)

A Flutter plugin for finding commonly used locations on the filesystem. 
Supports Android, iOS, Linux, macOS and Windows.
Not all methods are supported on all platforms.

## Usage

To use this plugin, add `path_provider` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/platform-integration/platform-channels).

Add the following import:
```dart
import 'package:path_provider/path_provider.dart';
```

## Supported platforms and paths

Methods support by platform:

| Dir | Android | iOS | Linux | macOS | Windows |
| :--- | :---: | :---: | :---: | :---: | :---: |
| Temporary | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ |
| Application Support | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ |
| Application Library | ❌️ | ✔️ | ✔️ | ✔️ | ✔️ |
| Application Documents | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ |
| External Storage | ✔️ | ❌ | ❌ | ❌️ | ❌️ |
| External Cache Directories | ✔️ | ❌ | ❌ | ❌️ | ❌️ |
| External Storage Directories | ✔️ | ❌ | ❌ | ❌️ | ❌️ |
| Downloads | ❌ | ❌ | ✔️ | ✔️ | ✔️ |

### Temporary Directory
Path to the temporary directory on the device that is suitable for storing caches of downloaded 
files.

Example:
``` dart
Future<String> requestDirectoryPath() async {
  try {
    final Directory directory = await getTemporaryDirectory();
    final String dirPath = directory.path;
    return dirPath;
  } catch (e) {
    // HANDLE ERROR
  }
  return null;
}
```

### Application Support Directory
Path to a directory where the application may place application support files.

Example:
``` dart
Future<String> requestDirectoryPath() async {
  try {
    final Directory directory = await getApplicationSupportDirectory();
    final String dirPath = directory.path;
    return dirPath;
  } catch (e) {
    // HANDLE ERROR
  }
  return null;
}
```

### Application Library Directory
Path to the directory where an application can store persistent files.

On Android, this function throws an `UnsupportedError` as no equivalent
path exists.

Example:
``` dart
Future<String?> requestDirectoryPath() async {
  try {
    final Directory? directory = await getLibraryDirectory();
    final String? dirPath = directory.path;
    return dirPath;
  } catch (e) {
    // HANDLE ERROR
  }
  return null;
}
```

### Application Documents Directory 
Path to a directory where the application can store user-generated documents.

Example:
``` dart
Future<String> requestDirectoryPath() async {
  try {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String dirPath = directory.path;
    return dirPath;
  } catch (e) {
    // HANDLE ERROR
  }
  return null;
}
```

### External Storage Directory
Path to a directory where the application may access top-level storage.
This path is typically an SD card or built-in storage partition in a device. 
The current operating system should be determined before issuing this
function call, as this functionality is **only available on Android**.

On other than Android platform, this function throws an `UnsupportedError` as no equivalent
path exists.

Example:
``` dart
Future<List<Directory>?> requestDirectories() async {
  try {
    final Directory? directory = await getExternalStorageDirectory();
    final String? dirPath = directory?.path;
    return dirPath;
  } catch (e) {
    // HANDLE ERROR
  }
  return null;
}
```


### External Cache Directories
Paths to directories where application-specific external cache data can be
stored. These paths typically reside on external storage like separate
partitions or SD cards. Phones may have multiple storage directories
available.

The current operating system should be determined before issuing this
function call, as this functionality is **only available on Android**.

On other than Android platform, this function throws an `UnsupportedError` as no equivalent
path exists.

Example:
``` dart
Future<List<Directory>?> requestDirectories() async {
  try {
    final List<Directory>? directories = await getExternalCacheDirectories();
    return directories;
  } catch (e) {
    // HANDLE ERROR
  }
  return null;
}
```


### External Storage Directories
Paths to directories where application-specific data can be stored.
These paths typically reside on external storage like separate partitions
or SD cards. Phones may have multiple storage directories available.

The current operating system should be determined before issuing this
function call, as this functionality is **only available on Android**.

On other than Android platform, this function throws an `UnsupportedError` as no equivalent
path exists.

Example:
``` dart
Future<List<Directory>?> requestDirectories() async {
  try {
    final List<Directory>? directories = 
        await getExternalStorageDirectories(type: StorageDirectory.pictures);
    return directories;
  } catch (e) {
    // HANDLE ERROR
  }
  return null;
}
```

### Downloads Directory
Path to the directory where downloaded files can be stored.
This is typically only relevant on desktop operating systems.

On Android and iOS, this function throws an `UnsupportedError` as no equivalent
path exists.

Example:
``` dart
Future<String?> requestDirectoryPath() async {
  try {
    final Directory? directory = await getDownloadsDirectory();
    final String? dirPath = directory?.path;
    return dirPath;
  } catch (e) {
    // HANDLE ERROR
  }
  return null;
}
```

## Testing

`path_provider` now uses a `PlatformInterface`, meaning that not all platforms share a single `PlatformChannel`-based implementation.
With that change, tests should be updated to mock `PathProviderPlatform` rather than `PlatformChannel`.

See this `path_provider` [test](https://github.com/flutter/plugins/blob/master/packages/path_provider/path_provider/test/path_provider_test.dart) for an example.

