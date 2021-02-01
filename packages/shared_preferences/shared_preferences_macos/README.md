# shared_preferences_macos

The macos implementation of [`shared_preferences`][1].

**Please set your constraint to `shared_preferences_macos: '>=0.0.y+x <2.0.0'`**

## Backward compatible 1.0.0 version is coming
The plugin has reached a stable API, we guarantee that version `1.0.0` will be backward compatible with `0.0.y+z`.
Please use `shared_preferences_macos: '>=0.0.y+x <2.0.0'` as your dependency constraint to allow a smoother ecosystem migration.
For more details see: https://github.com/flutter/flutter/wiki/Package-migration-to-1.0.0

## Usage

### Import the package

This package has been endorsed, meaning that you only need to add `shared_preferences`
as a dependency in your `pubspec.yaml`. It will be automatically included in your app
when you depend on `package:shared_preferences`.

This is what the above means to your `pubspec.yaml`:

```yaml
...
dependencies:
  ...
  shared_preferences: ^0.5.6
  ...
```

If you wish to use the macos package only, you can add  `shared_preferences_macos` as a
dependency:

```yaml
...
dependencies:
  ...
  shared_preferences_macos: ^0.0.1
  ...
```

[1]: ../
