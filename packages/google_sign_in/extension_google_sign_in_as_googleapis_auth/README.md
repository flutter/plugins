# extension_google_sign_in_as_googleapis_auth

A bridge package between Flutter's [`google_sign_in` plugin](https://pub.dev/packages/google_sign_in) and Dart's [`googleapis` package](https://pub.dev/packages/googleapis), that is able to create [`googleapis_auth`-like `AuthClient` instances](https://pub.dev/documentation/googleapis_auth/latest/googleapis_auth.auth/AuthClient-class.html) directly from the `GoogleSignIn` plugin.

## Usage

This package is implemented as an [extension method](https://dart.dev/guides/language/extension-methods) on top of the `GoogleSignIn` plugin.

In order to use it, you need to add a `dependency` to your `pubspec.yaml`. Then, wherever you're importing `package:google_sign_in/google_sign_in.dart`, add the following:

```dart
...
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
...
```

From that moment on, your `GoogleSignIn` instance will have an additional `Future<AuthClient> authenticatedClient()` method that you can call once your sign in is successful to retrieve an `AuthClient`.

That object can then be used to create instances of `googleapis` API clients:

```dart
...
final peopleApi = PeopleApi(await _googleSignIn.authenticatedClient());
final response = await peopleApi.people.connections.list(
  'people/me',
  personFields: 'names',
);
...
```

## Example

This package contains a modified version of Flutter's Google Sign In example app that uses `package:googleapis`' API clients, instead of raw http requests.

See it [here](https://github.com/flutter/plugins/blob/master/packages/google_sign_in/extension_google_sign_in_as_googleapis_auth/example/lib/main.dart).

The original code (and its license) can be seen [here](https://github.com/flutter/plugins/tree/master/packages/google_sign_in/google_sign_in/example/lib/main.dart).

## Testing

Run tests with `flutter test`.

## Issues and feedback

Please file [issues](https://github.com/flutter/flutter/issues/new)
to send feedback or report a bug. Thank you!
