# in_app_purchase_ios

The iOS implementation of [`in_app_purchase`][1].

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

If you wish to use the iOS package only, you can add  `in_app_purchase_ios` as a
dependency:

```yaml
...
dependencies:
  ...
  in_app_purchase_ios: ^1.0.0
  ...
```

## Contributing

This plugin uses
[json_serializable](https://pub.dev/packages/json_serializable) for the
many data structs passed between the underlying platform layers and Dart. After
editing any of the serialized data structs, rebuild the serializers by running
`flutter packages pub run build_runner build --delete-conflicting-outputs`.
`flutter packages pub run build_runner watch --delete-conflicting-outputs` will
watch the filesystem for changes.

If you would like to contribute to the plugin, check out our
[contribution guide](https://github.com/flutter/plugins/blob/master/CONTRIBUTING.md).


[1]: ../in_app_purchase/in_app_purchase