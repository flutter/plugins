# image_picker_for_web

A web implementation of [`image_picker`][1].

## Browser Support

Since Web Browsers don't offer direct access to their users' file system,
this plugin provides a `PickedFile` abstraction to make access access uniform
across platforms.

The web version of the plugin puts network-accessible URIs as the `path`
in the returned `PickedFile`.

### URL.createObjectURL()

The `PickedFile` object in web is backed by [`URL.createObjectUrl` Web API](https://developer.mozilla.org/en-US/docs/Web/API/URL/createObjectURL),
which is reasonably well supported across all browsers:

![Data on support for the bloburls feature across the major browsers from caniuse.com](https://caniuse.bitsofco.de/image/bloburls.png)

However, the returned `path` attribute of the `PickedFile` points to a `network` resource, and not a
local path in your users' drive. See **Use the plugin** below for some examples on how to use this
return value in a cross-platform way.

### input file "accept"

In order to filter only video/image content, some browsers offer an [`accept` attribute](https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes/accept) in their `input type="file"` form elements:

![Data on support for the input-file-accept feature across the major browsers from caniuse.com](https://caniuse.bitsofco.de/image/input-file-accept.png)

This feature is just a convenience for users, **not validation**.

Users can override this setting on their browsers. You must validate in your app (or server)
that the user has picked the file type that you can handle.

### input file "capture"

In order to "take a photo", some mobile browsers offer a [`capture` attribute](https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes/capture):

![Data on support for the html-media-capture feature across the major browsers from caniuse.com](https://caniuse.bitsofco.de/image/html-media-capture.png)

Each browser may implement `capture` any way they please, so it may (or may not) make a
difference in your users' experience.

## Usage

### Import the package

This package is an unendorsed web platform implementation of `image_picker`.

In order to use this, you'll need to depend in `image_picker: ^0.6.7` (which was the first version of the plugin that allowed federation), and `image_picker_for_web: ^0.1.0`.

```yaml
...
dependencies:
  ...
  image_picker: ^0.6.7
  image_picker_for_web: ^0.1.0
  ...
...
```

### Use the plugin

You should be able to use `package:image_picker` _almost_ as normal.

Once the user has picked a file, the returned `PickedFile` instance will contain a
`network`-accessible URL (pointing to a location within the browser).

The instace will also let you retrieve the bytes of the selected file across all platforms.

If you want to use the path directly, your code would need look like this:

```dart
...
if (kIsWeb) {
  Image.network(pickedFile.path);
} else {
  Image.file(File(pickedFile.path));
}
...
```

Or, using bytes:

```dart
...
Image.memory(await pickedFile.readAsBytes())
...
```

[1]: https://pub.dev/packages/image_picker
