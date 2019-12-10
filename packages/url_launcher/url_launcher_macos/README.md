# url_launcher_macos

The macos implementation of [`url_launcher`][1].

## Usage

### Import the package

To use this plugin in your Flutter macos app, simply add it as a dependency in
your `pubspec.yaml` alongside the base `url_launcher` plugin.

_(This is only temporary: in the future we hope to make this package an
"endorsed" implementation of `url_launcher`, so that it is automatically
included in your Flutter macos app when you depend on `package:url_launcher`.)_

This is what the above means to your `pubspec.yaml`:

```yaml
...
dependencies:
  ...
  url_launcher: ^0.5.4+8
  url_launcher_macos: ^0.1.0
  ...
```

### Use the plugin

Once you have the `url_launcher_macos` dependency in your pubspec, you should
be able to use `package:url_launcher` as normal.

[1]: ../url_launcher
