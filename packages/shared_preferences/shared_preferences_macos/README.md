# shared_preferences_macos

The macos implementation of [`shared_preferences`][1].

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

[1]: ../shared_preferences/shared_preferences
