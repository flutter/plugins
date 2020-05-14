# path_provider_macos

The macos implementation of [`path_provider`].

**Please set your constraint to `path_provider_macos: '>=0.0.y+x <2.0.0'`**

## Backward compatible 1.0.0 version is coming
The plugin has reached a stable API, we guarantee that version `1.0.0` will be backward compatible with `0.0.y+z`.
Please use `path_provider_macos: '>=0.0.y+x <2.0.0'` as your dependency constraint to allow a smoother ecosystem migration.
For more details see: https://github.com/flutter/flutter/wiki/Package-migration-to-1.0.0

## Usage

### Import the package

To use this plugin in your Flutter macos app, simply add it as a dependency in
your `pubspec.yaml` alongside the base `path_provider` plugin.

_(This is only temporary: in the future we hope to make this package an
"endorsed" implementation of `path_provider`, so that it is automatically
included in your Flutter macos app when you depend on `package:path_provider`.)_

This is what the above means to your `pubspec.yaml`:

```yaml
...
dependencies:
  ...
  path_provider: ^1.5.1
  path_provider_macos: ^0.0.1
  ...
```

### Use the plugin

Once you have the `path_provider_macos` dependency in your pubspec, you should
be able to use `package:path_provider` as normal.
