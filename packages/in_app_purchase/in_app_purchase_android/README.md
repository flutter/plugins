# in_app_purchase_android

The Android implementation of [`in_app_purchase`][1].

## Usage

### Import the package

This package has been endorsed, meaning that you only need to add `in_app_purchase`
as a dependency in your `pubspec.yaml`. It will be automatically included in your app
when you depend on `package:in_app_purchase`.

This is what the above means to your `pubspec.yaml`:

```yaml
...
dependencies:
  ...
  in_app_purchase: ^0.6.0
  ...
```

If you wish to use the Android package only, you can add  `in_app_purchase_android` as a
dependency:

```yaml
...
dependencies:
  ...
  in_app_purchase_android: ^1.0.0
  ...
```

[1]: ../in_app_purchase/in_app_purchase