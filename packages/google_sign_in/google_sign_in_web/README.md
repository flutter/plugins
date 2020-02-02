# google_sign_in_web

The web implementation of [google_sign_in](https://pub.dev/google_sign_in/google_sign_in)

## Usage

### Import the package

This package is the endorsed implementation of `google_sign_in` for the web platform since version `4.1.0`, so it gets automatically added to your dependencies by depending on `google_sign_in: ^4.1.0`.

No modifications to your pubspec.yaml should be required in a recent enough version of Flutter (`>=1.12.13+hotfix.4`):

```yaml
...
dependencies:
  ...
  google_sign_in: ^4.1.0
  ...
...
```

### Web integration

First, go through the instructions [here](https://developers.google.com/identity/sign-in/web/sign-in#before_you_begin) to create your Google Sign-In OAuth client ID.

On your `web/index.html` file, add the following `meta` tag, somewhere in the
`head` of the document:

```html
<meta name="google-signin-client_id" content="YOUR_GOOGLE_SIGN_IN_OAUTH_CLIENT_ID.apps.googleusercontent.com">
```

Read the rest of the instructions if you need to add extra APIs (like Google People API).


### Use the plugin
Add the following import to your Dart code:

```dart
import 'package:google_sign_in/google_sign_in.dart';
```

Initialize GoogleSignIn with the scopes you want:

```dart
GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);
```
[Full list of available scopes](https://developers.google.com/identity/protocols/googlescopes).

You can now use the `GoogleSignIn` class to authenticate in your Dart code, e.g.

```dart
Future<void> _handleSignIn() async {
  try {
    await _googleSignIn.signIn();
  } catch (error) {
    print(error);
  }
}
```

## Example

Find the example wiring in the [Google sign-in example application](https://github.com/flutter/plugins/blob/master/packages/google_sign_in/google_sign_in/example/lib/main.dart).

## API details

See the [google_sign_in.dart](https://github.com/flutter/plugins/blob/master/packages/google_sign_in/google_sign_in/lib/google_sign_in.dart) for more API details.

## Contributions and Testing

Tests are a crucial to contributions to this package. All new contributions should be reasonably tested.

In order to run tests in this package, do:

```
flutter test --platform chrome -j1
```

Contributions to this package are welcome. Read the [Contributing to Flutter Plugins](https://github.com/flutter/plugins/blob/master/CONTRIBUTING.md) guide to get started.

## Issues and feedback

Please file [issues](https://github.com/flutter/flutter/issues/new)
to send feedback or report a bug.

**Thank you!**
