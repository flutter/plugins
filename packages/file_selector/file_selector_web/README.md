# file_selector_web

The web implementation of [`file_selector`][1].

## Usage

### Import the package
To use this plugin in your Flutter Web app, simply add it as a dependency in
your pubspec alongside the base `file_selector` plugin.

_(This is only temporary: in the future we hope to make this package an
"endorsed" implementation of `file_selector`, so that it is automatically
included in your Flutter Web app when you depend on `package:file_selector`.)_

This is what the above means to your `pubspec.yaml`:

```yaml
...
dependencies:
  ...
  file_selector: ^0.7.0
  file_selector_web: ^0.7.0
  ...
```

### Use the plugin
Once you have the `file_selector_web` dependency in your pubspec, you should
be able to use `package:file_selector` as normal.

[1]: ../file_selector/file_selector
