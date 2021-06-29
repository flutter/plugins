# url_launcher_windows

The Windows implementation of [`url_launcher`][1].

## Usage

### Import the package

This package has been endorsed, meaning that you only need to add `url_launcher`
as a dependency in your `pubspec.yaml`. It will be automatically included in your app
when you depend on `package:url_launcher`.

This is what the above means to your `pubspec.yaml`:

```yaml
...
dependencies:
  ...
  url_launcher: ^5.6.0
  ...
```

If you wish to use the Windows package only, you can add  `url_launcher_windows` as a
dependency:

```yaml
...
dependencies:
  ...
  url_launcher_windows: ^0.0.1
  ...
```

[1]: ../url_launcher/url_launcher
