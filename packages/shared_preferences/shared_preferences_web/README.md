# shared_preferences_web

The web implementation of [`shared_preferences`][1].

**Please set your constraint to `shared_preferences_web: '>=0.1.y+x <2.0.0'`**

## Backward compatible 1.0.0 version is coming
The plugin has reached a stable API, we guarantee that version `1.0.0` will be backward compatible with `0.1.y+z`.
Please use `shared_preferences_web: '>=0.1.y+x <2.0.0'` as your dependency constraint to allow a smoother ecosystem migration.
For more details see: https://github.com/flutter/flutter/wiki/Package-migration-to-1.0.0

## Usage

### Import the package

To use this plugin in your Flutter Web app, simply add it as a dependency in
your `pubspec.yaml` alongside the base `shared_preferences` plugin.

_(This is only temporary: in the future we hope to make this package an
"endorsed" implementation of `shared_preferences`, so that it is automatically
included in your Flutter Web app when you depend on `package:shared_preferences`.)_

This is what the above means to your `pubspec.yaml`:

```yaml
...
dependencies:
  ...
  shared_preferences: ^0.5.4+8
  shared_preferences_web: ^0.1.0
  ...
```

### Use the plugin

Once you have the `shared_preferences_web` dependency in your pubspec, you should
be able to use `package:shared_preferences` as normal.

[1]: ../shared_preferences/shared_preferences
