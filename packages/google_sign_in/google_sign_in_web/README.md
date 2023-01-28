# google\_sign\_in\_web

The web implementation of [google_sign_in](https://pub.dev/packages/google_sign_in)

## Migrating to v0.11 (Google Identity Services)

The `google_sign_in_web` plugin is backed by the new Google Identity Services
JS SDK since version 0.11.0.

The new SDK is used both for [Authentication](https://developers.google.com/identity/gsi/web/guides/overview)
and [Authorization](https://developers.google.com/identity/oauth2/web/guides/overview) flows.

The new SDK, however, doesn't behave exactly like the one being deprecated.
Some concepts have experienced pretty drastic changes, and that's why this
required a major version update.

### Key differences between the SDK

* For the SDK, Authentication and Authorization are now two separate concerns.
  * Authentication (information about the current user) flows will not
    authorize `scopes` anymore.
  * Authorization (permissions for the app to access certain user information)
    flows will not return authentication information.
* The SDK no longer has direct access to previously-seen users upon initialization.
  * `signInSilently` now displays the One Tap UX for web.
* The new SDK only provides an `idToken` (JWT-encoded info) when the user
  successfully completes `signInSilently`.
* `signIn` uses the Oauth "Implicit Flow" to Authorize the requested `scopes`.
  * If the user hasn't `signInSilently`, they'll have to sign in as a first step
    of the Authorization popup flow.
  * If `signInSilently` was unsuccessful, the plugin will add extra `scopes` to
    `signIn` and retrieve basic Profile information from the People API via a
    REST call immediately after a successful authorization. In this case, the
    `idToken` field of the `GoogleSignInUserData` will always be null.
* The SDK no longer handles sign-in state and user sessions, it only provides
  Authentication credentials for the moment the user did authenticate.
* The SDK no longer is able to renew Authorization sessions on the web.
  Once the token expires, API requests will begin to fail with unauthorized,
  and user Authorization is required again.

See more differences in the following migration guides:

* Authentication > [Migrating from Google Sign-In](https://developers.google.com/identity/gsi/web/guides/migration)
* Authorization > [Migrate to Google Identity Services](https://developers.google.com/identity/oauth2/web/guides/migration-to-gis)

### New use cases to take into account in your app

#### User Sessions

Since the new SDK does *not* manage user sessions anymore, apps that relied on
this feature might break.

If long-lived sessions are required, consider using some User authentication
system that supports Google Sign In as a federated Authentication provider,
like [Firebase Auth](https://firebase.google.com/docs/auth/flutter/federated-auth#google),
or similar (expand this list as other providers become generally available for
Flutter web).

#### Expired / Invalid Authorization Tokens

Since the new SDK does *not* auto-renew authorization tokens anymore, it's now
the responsibility of your app to do so.

Apps now need to monitor the status code of their REST API requests for response
codes different to `200`. For example:

* `401`: Missing or invalid access token.
* `403`: Expired access token.

In either case, your app needs to prompt the end user to `signIn` again, to
interactively renew the token. The GIS SDK limits authorization token duration
to one hour (3600 seconds).

#### Null `idToken`

The `GoogleSignInUserData` returned after `signIn` may contain a `null` `idToken`
field. This is not an indication of the session being invalid, it's just that
the user canceled (or wasn't presented with) the OneTap UX from `signInSilently`.

In cases where the OneTap UX does not authenticate the user, the `signIn` method
will attempt to "fill in the gap" by requesting basic profile information of the
currently signed-in user.

In that case, the `GoogleSignInUserData` will contain a `null` `idToken`.

## Usage

### Import the package

This package is [endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin),
which means you can simply use `google_sign_in`
normally. This package will be automatically included in your app when you do.

### Web integration

First, go through the instructions [here](https://developers.google.com/identity/gsi/web/guides/get-google-api-clientid) to create your Google Sign-In OAuth client ID.

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

For local development, you must add two `localhost` entries:

* `http://localhost` and
* `http://localhost:7357` (or any port that is free in your machine)

#### Starting flutter in http://localhost:7357

Normally `flutter run` starts in a random port. In the case where you need to deal with authentication like the above, that's not the most appropriate behavior.

You can tell `flutter run` to listen for requests in a specific host and port with the following:

```sh
flutter run -d chrome --web-hostname localhost --web-port 7357
```

### Other APIs

Read the rest of the instructions if you need to add extra APIs (like Google People API).

### Using the plugin

See the [**Usage** instructions of `package:google_sign_in`](https://pub.dev/packages/google_sign_in#usage)

Note that the **`serverClientId` parameter of the `GoogleSignIn` constructor is not supported on Web.**

## Example

Find the example wiring in the [Google sign-in example application](https://github.com/flutter/plugins/blob/main/packages/google_sign_in/google_sign_in/example/lib/main.dart).

## API details

See [google_sign_in.dart](https://github.com/flutter/plugins/blob/main/packages/google_sign_in/google_sign_in/lib/google_sign_in.dart) for more API details.

## Contributions and Testing

Tests are crucial for contributions to this package. All new contributions should be reasonably tested.

**Check the [`test/README.md` file](https://github.com/flutter/plugins/blob/main/packages/google_sign_in/google_sign_in_web/test/README.md)** for more information on how to run tests on this package.

Contributions to this package are welcome. Read the [Contributing to Flutter Plugins](https://github.com/flutter/plugins/blob/main/CONTRIBUTING.md) guide to get started.

## Issues and feedback

Please file [issues](https://github.com/flutter/flutter/issues/new)
to send feedback or report a bug.

**Thank you!**
