# connectivity_macos

The macos implementation of [`connectivity`].

## Usage

### Import the package

To use this plugin in your Flutter Web app, simply add it as a dependency in
your `pubspec.yaml` alongside the base `connectivity` plugin.

_(This is only temporary: in the future we hope to make this package an
"endorsed" implementation of `connectivity`, so that it is automatically
included in your Flutter macos app when you depend on `package:connectivity_macos`.)_

This is what the above means to your `pubspec.yaml`:

```yaml
...
dependencies:
  ...
  connectivity: ^0.4.6
  connectivity_macos: ^0.0.1
  ...
```

### Use the plugin

Once you have the `connectivity_macos` dependency in your pubspec, you should
be able to use `package:connectivity` as normal.
