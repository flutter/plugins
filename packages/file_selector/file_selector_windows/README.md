# file_selector_windows

The Windows implementation of [`file_selector`][1].

## Backward compatible 1.0.0 version is coming
The plugin has reached a stable API, we guarantee that version `1.0.0` will be backward compatible with `0.0.y+z`. If you use
file_selector_windows directly, rather than as an implementation detail
of `file_selector`, please use `file_selector_windows: '>=0.0.y+x <2.0.0'`
as your dependency constraint to allow a smoother ecosystem migration.
For more details see: https://github.com/flutter/flutter/wiki/Package-migration-to-1.0.0

## Usage

### Import the package

This package has not yet been endorsed, meaning that you need to add `file_selector_windows`
as a dependency in your `pubspec.yaml`. It will be not yet be automatically included in your app
when you depend on `package:file_selector`.

This is what the above means to your `pubspec.yaml`:

```yaml
...
dependencies:
  ...
  file_selector: ^0.7.0
  file_selector_windows: ^0.0.1
  ...
```

If you wish to use the Windows package only, you can add  `file_selector_windows` as a
dependency:

```yaml
...
dependencies:
  ...
  file_selector_windows: ^0.0.1
  ...
```

[1]: ../file_selector/file_selector
