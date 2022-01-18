# path_provider

[![pub package](https://img.shields.io/pub/v/path_provider.svg)](https://pub.dev/packages/path_provider)

A Flutter plugin for finding commonly used locations on the filesystem. Supports Android, iOS, Linux, macOS and Windows.
Not all methods are supported on all platforms.

## Installation

To use this plugin, add `path_provider` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/platform-integration/platform-channels).
Please see the example app of this plugin for a full example.

## Usage

Methods support by platform

| Dir | Android | iOS | Linux | MacOS | Windows |
| :--- | :---: | :---: | :---: | :---: | :---: |
| Temporary | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ |
| Application Support | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ |
| Application Library | ❌️ | ✔️ | ✔️ | ✔️ | ✔️ |
| Application Documents | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ |
| External Storage | ✔️ | ❌ | ❌ | ❌️ | ❌️ |
| External Cache (Directories) | ✔️ | ❌ | ❌ | ❌️ | ❌️ |
| External Storage (Directories) | ✔️ | ❌ | ❌ | ❌️ | ❌️ |
| Downloads | ❌ | ❌ | ✔️ | ✔️ | ✔️ |

### Temporary Directory
Path to the temporary directory on the device that is not backed up and is
suitable for storing caches of downloaded files.

Example:
``` dart
Future<String?> requestDirectoryPath() async {
  try {
    Directory directory = await getTemporaryDirectory();
    String dirPath = directory.path;
    return dirPath;
  } catch (e) {
    // HANDLE ERROR
  }
  return null;
}
``` 

Platform support:

| Android | iOS | Linux | MacOS | Windows | 
| :---: | :---: | :---: | :---: | :---: |
| ✔️ | ✔️ | ✔️ | ✔️ | ✔️ |

### Application Support Directory
Path to a directory where the application may place application support files.

Example:
``` dart
Future<String?> requestDirectoryPath() async {
  try {
    Directory directory = await getApplicationSupportDirectory();
    String dirPath = directory.path;
    return dirPath;
  } catch (e) {
    // HANDLE ERROR
  }
  return null;
}
```

Platform support:

| Android | iOS | Linux | MacOS | Windows | 
| :---: | :---: | :---: | :---: | :---: |
| ✔️ | ✔️ | ✔️ | ✔️ | ✔️ |

### Application Library Directory
Path to the directory where application can store files that are persistent,
backed up, and not visible to the user, such as sqlite.db.

Example:
``` dart
Future<String?> requestDirectoryPath() async {
  try {
    Directory? directory = await getLibraryDirectory();
    String? dirPath = directory.path;
    return dirPath;
  } catch (e) {
    // HANDLE ERROR
  }
  return null;
}
```

Platform support:

| Android | iOS | Linux | MacOS | Windows | 
| :---: | :---: | :---: | :---: | :---: |
| ❌️ | ✔️ | ✔️ | ✔️ | ✔️ |

### Application Documents Directory 
Path to a directory where the application may place data that is
user-generated, or that cannot otherwise be recreated by your application.

Example:
``` dart
Future<String?> requestDirectoryPath() async {
  try {
    Directory? directory = await getApplicationDocumentsDirectory();
    String dirPath = directory.path;
    return dirPath;
  } catch (e) {
    // HANDLE ERROR
  }
  return null;
}
```

Platform support:

| Android | iOS | Linux | MacOS | Windows | 
| :---: | :---: | :---: | :---: | :---: |
| ✔️ | ✔️ | ✔️ | ✔️ | ✔️ |

### External Storage Directory
Path to a directory where the application may access top level storage.
The current operating system should be determined before issuing this
function call, as this functionality is **only available on Android**.

Example:
``` dart
Future<List<Directory>?> requestDirectories() async {
  try {
    Directory? directory = await getExternalStorageDirectory();
    String? dirPath = directory?.path;
    return dirPath;
  } catch (e) {
    // HANDLE ERROR
  }
  return null;
}
```

Platform support:

| Android | iOS | Linux | MacOS | Windows | 
| :---: | :---: | :---: | :---: | :---: |
| ✔️ | ❌️ | ❌️ | ❌️ | ❌ |

### External Cache Directories
Paths to directories where application specific external cache data can be
stored. These paths typically reside on external storage like separate
partitions or SD cards. Phones may have multiple storage directories
available.

The current operating system should be determined before issuing this
function call, as this functionality is **only available on Android**.

Example:
``` dart
Future<List<Directory>?> requestDirectories() async {
  try {
    List<Directory>? directories = await getExternalCacheDirectories();
    return directories;
  } catch (e) {
    // HANDLE ERROR
  }
  return null;
}
```

Platform support:

| Android | iOS | Linux | MacOS | Windows | 
| :---: | :---: | :---: | :---: | :---: |
| ✔️ | ❌️ | ❌️ | ❌️ | ❌ |

### External Storage Directories
Paths to directories where application specific data can be stored.
These paths typically reside on external storage like separate partitions
or SD cards. Phones may have multiple storage directories available.

The current operating system should be determined before issuing this
function call, as this functionality is **only available on Android**.

Example:
``` dart
Future<List<Directory>?> requestDirectories() async {
  try {
    List<Directory>? directories = await getExternalStorageDirectories();
    return directories;
  } catch (e) {
    // HANDLE ERROR
  }
  return null;
}
```

Platform support:

| Android | iOS | Linux | MacOS | Windows | 
| :---: | :---: | :---: | :---: | :---: |
| ✔️ | ❌️ | ❌️ | ❌️ | ❌ |


### Downloads Directory
Path to the directory where downloaded files can be stored.
This is typically only relevant on desktop operating systems.

Example:
``` dart
Future<String?> requestDirectoryPath() async {
  try {
    Directory? directory = await getDownloadsDirectory();
    String? dirPath = directory.path;
    return dirPath;
  } catch (e) {
    // HANDLE ERROR
  }
  return null;
}
```

On Android and on iOS, this function throws an [UnsupportedError] as no equivalent
path exists.


Platform support:

| Android |   iOS   |  Linux  |  MacOS  | Windows | 
| :-----: | :-----: | :-----: | :-----: | :-----: |
| ❌️ | ❌️ | ✔️ | ✔️ | ✔️ |

## Usage in tests

`path_provider` now uses a `PlatformInterface`, meaning that not all platforms share the a single `PlatformChannel`-based implementation.
With that change, tests should be updated to mock `PathProviderPlatform` rather than `PlatformChannel`.

See this `path_provider` [test](https://github.com/flutter/plugins/blob/master/packages/path_provider/path_provider/test/path_provider_test.dart) for an example.

