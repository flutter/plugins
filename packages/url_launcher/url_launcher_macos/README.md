# url_launcher_macos

The macos implementation of [`url_launcher`][1].

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
  url_launcher: ^5.4.1
  ...
```

If you wish to use the macos package only, you can add  `url_launcher_macos` as a
dependency:

```yaml
...
dependencies:
  ...
  url_launcher_macos: ^0.0.1
  ...
```

[1]: ../url_launcher/url_launcher
