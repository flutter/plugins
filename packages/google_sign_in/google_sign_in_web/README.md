# google\_sign\_in\_web

The web implementation of [google_sign_in](https://pub.dev/packages/google_sign_in)

## Usage

### Import the package

This package is [endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin),
which means you can simply use `google_sign_in`
normally. This package will be automatically included in your app when you do.

### Web integration

First, go through the instructions [here](https://developers.google.com/identity/sign-in/web/sign-in#before_you_begin) to create your Google Sign-In OAuth client ID.

On your `web/index.html` file, add the following `meta` tag, somewhere in the
`head` of the document:

```html
<meta name="google-signin-client_id" content="YOUR_GOOGLE_SIGN_IN_OAUTH_CLIENT_ID.apps.googleusercontent.com">
```

For this client to work correctly, the last step is to configure the **Authorized JavaScript origins**, which _identify the domains from which your application can send API requests._ When in local development, this is normally `localhost` and some port.

You can do this by:

1. Going to the [Credentials page](https://console.developers.google.com/apis/credentials).
2. Clicking "Edit" in the OAuth 2.0 Web application client that you created above.
3. Adding the URIs you want to the **Authorized JavaScript origins**.

For local development, may add a `localhost` entry, for example: `http://localhost:7357`

#### Starting flutter in http://localhost:7357

Normally `flutter run` starts in a random port. In the case where you need to deal with authentication like the above, that's not the most appropriate behavior.

You can tell `flutter run` to listen for requests in a specific host and port with the following:

```
flutter run -d chrome --web-hostname localhost --web-port 7357
```

### Other APIs

Read the rest of the instructions if you need to add extra APIs (like Google People API).


### Using the plugin
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

Tests are crucial for contributions to this package. All new contributions should be reasonably tested.

**Check the [`test/README.md` file](https://github.com/flutter/plugins/blob/master/packages/google_sign_in/google_sign_in_web/test/README.md)** for more information on how to run tests on this package.

Contributions to this package are welcome. Read the [Contributing to Flutter Plugins](https://github.com/flutter/plugins/blob/master/CONTRIBUTING.md) guide to get started.

## Issues and feedback

Please file [issues](https://github.com/flutter/flutter/issues/new)
to send feedback or report a bug.

**Thank you!**
