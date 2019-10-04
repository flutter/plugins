# Flutter Android Lifecycle Plugin

[![pub package](https://img.shields.io/pub/v/flutter_android_lifecycle.svg)](https://pub.dartlang.org/packages/flutter_android_lifecycle)

A Flutter plugin for Android to allow other Flutter plugins to access an Android `Lifecycle` object
in the plugin's binding.

*Note*: This plugin is still under development, and some APIs might not be available yet.

## Installation

Add `flutter_android_lifecycle` as a [dependency in your pubspec.yaml file](https://flutter.io/using-packages/).

## Example

Use a `FlutterLifecycleAdapter` within another Flutter plugin's Android implementation, as shown
below:

```java
public class MyPlugin implements FlutterPlugin {
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    Object lifecycleReference = binding.getLifecycle();
    Lifecycle lifecycle = new FlutterLifecycleAdapter(lifecycleReference).getLifecycle();
    
    // Use lifecycle as desired.
  }
  
  //...
}
```

*Note*: This plugin is still under development, and some APIs might not be available yet.
[Feedback welcome](https://github.com/flutter/flutter/issues) and
[Pull Requests](https://github.com/flutter/plugins/pulls) are most welcome!
