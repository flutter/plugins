# Shared preferences plugin

[![pub package](https://img.shields.io/pub/v/shared_preferences.svg)](https://pub.dev/packages/shared_preferences)

Wraps platform-specific persistent storage for simple data
(NSUserDefaults on iOS and macOS, SharedPreferences on Android, etc.). 
Data may be persisted to disk asynchronously,
and there is no guarantee that writes will be persisted to disk after
returning, so this plugin must not be used for storing critical data.

Although key-value storage is easy and convenient to use, it has limitations:
* Only primitive types can be used: `int`, `double`, `bool`, `String`, and `StringList`.
* It’s not designed to store a lot of data.
* No encryption for data.

SharedPreferences data is deleted when the application is uninstalled or the application data 
is cleared.

## Usage
To use this plugin, add `shared_preferences` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/platform-integration/platform-channels).

Add the following import: 
```dart
import 'package:shared_preferences/shared_preferences.dart';
```

### Examples
Here are small examples that show you how to use the API.

#### Write data
```dart 
// Obtain shared preferences.
final prefs = await SharedPreferences.getInstance();

// Save data for different keys and types.
await prefs.setInt('counter', 10);
await prefs.setBool('repeat', true);
await prefs.setDouble('decimal', 1.5);
await prefs.setString('action', 'Start');
await prefs.setStringList('items', <String>['Earth, Moon, Sun']);
```

#### Read data
```dart 
// Try reading data from the counter key. If it doesn't exist, return 0.
final counter = prefs.getInt('counter') ?? 0;
// Try reading data from the repeat key. If it doesn't exist, return false.
final repeat = prefs.getBool('repeat') ?? false;
// Try reading data from the decimal key. If it doesn't exist, return 0.
final decimal = prefs.getDouble('decimal') ?? 0;
// Try reading data from the action key. If it doesn't exist, return empty string.
final action = prefs.getString('action') ?? '';
// Try reading data from the items key. If it doesn't exist, return empty list.
final items = prefs.getStringList('items') ?? <String>[];
```

#### Remove an entry
```dart 
// Remove data from the provided key.
final success = await prefs.remove('counter');
```

#### Remove all keys and values
```dart 
final success = await prefs.clear();
```

### Sample Usage

``` dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
      child: RaisedButton(
        onPressed: _incrementCounter,
        child: Text('Increment Counter'),
        ),
      ),
    ),
  ));
}

_incrementCounter() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int counter = (prefs.getInt('counter') ?? 0) + 1;
  print('Pressed $counter times.');
  await prefs.setInt('counter', counter);
}
```
### Testing

You can populate `SharedPreferences` with initial values in your tests by running this code:

```dart
Map<String, Object> values = <String, Object>{'counter': 1};
SharedPreferences.setMockInitialValues(values);
```

### Storage location on platforms

| Platform | Location |
| :--- | :--- |
| Android | SharedPreferences |
| iOS | NSUserDefaults |
| Linux | LocalFileSystem |
| MacOS | NSUserDefaults |
| Web | LocalStorage |
| Windows | LocalFileSystem |

[example]:./example