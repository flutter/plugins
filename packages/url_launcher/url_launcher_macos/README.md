# url\_launcher\_macos

The macOS implementation of [`url_launcher`][1].

## Usage

To use this plugin in your Flutter Web app, simply add it as a dependency in
your pubspec using a `git` dependency. This is only temporary: in the future
we hope to make this package an "endorsed" implementation of `url_launcher`,
so that it is automatically included in your macOS Flutter app when you depend
on `package:url_launcher`.

```yaml
dependencies:
  url_launcher: ^5.1.4
  url_launcher_macos:
    git:
      url: git://github.com/flutter/plugins.git
      path: packages/url_launcher/url_launcher_macos
```

Once you have the `url_launcher_macos` dependency in your pubspec, you should
be able to use `package:url_launcher` as normal.

[1]: ../url_launcher
