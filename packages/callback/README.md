# Callback

[![pub package](https://img.shields.io/pub/v/callback.svg)](https://pub.dartlang.org/packages/callback)

A Flutter plugin that allows native callbacks to be registered and
called from Dart side. You can use this plugin to communicate lifecycle events
from Dart to native side. It is also useful for handling events that require
dependencies between multiple plugins; a callback defined at app layer
can orchestrate such logic.

## Usage
To use this plugin, add `callback` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

### Example

``` java
// After plugin registration.
CallbackPlugin plugin = valuePublishedByPlugin("io.flutter.plugins.callback.CallbackPlugin");
plugin.registerCallback("hello_world", new Runnable() {
  @Override
  public void run() {
    Log.w("CallbackSampleApp", "Hello World!");
  }
});
```

``` objc
// After plugin registration
CallbackPlugin *plugin = (CallbackPlugin *)[self valuePublishedByPlugin:@"CallbackPlugin"];
[plugin registerCallback:^{
  NSLog(@"Hello world!!");
} withId:@"hello_world"];

```


``` dart
// Import package
import 'package:callback/callback.dart' as callback;

// Instantiate it
Callback.call('hello_world');
```
