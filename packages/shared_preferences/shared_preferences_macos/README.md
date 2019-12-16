# shared_preferences_macos

The macos implementation of [`shared_preferences`][1].

## Usage

### Import the package

To use this plugin in your Flutter app, simply add it as a dependency in
your `pubspec.yaml` alongside the base `shared_preferences` plugin.

_(This is only temporary: in the future we hope to make this package an
"endorsed" implementation of `shared_preferences`, so that it is automatically
included in your Flutter app when you depend on `package:shared_preferences`.)_

This is what the above means to your `pubspec.yaml`:

```yaml
...
dependencies:
  ...
  shared_preferences: ^0.5.4+8
  shared_preferences_macos: ^0.1.0
  ...
```

### Use the plugin

Once you have the `shared_preferences_macos` dependency in your pubspec, you should
be able to use `package:shared_preferences` as normal.

[1]: ../shared_preferences/shared_preferences_macos
