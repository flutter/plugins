# google\_sign\_in\_web

The web implementation of [google_sign_in](https://pub.dev/packages/google_sign_in)

## Migrating to v0.11 (Google Identity Services)

The `google_sign_in_web` plugin is backed by the new Google Identity Services
(GIS) JS SDK since version 0.11.0.

The GIS SDK is used both for [Authentication](https://developers.google.com/identity/gsi/web/guides/overview)
and [Authorization](https://developers.google.com/identity/oauth2/web/guides/overview) flows.

The GIS SDK, however, doesn't behave exactly like the one being deprecated.
Some concepts have experienced pretty drastic changes, and that's why this
plugin required a major version update.

### Differences between Google Identity Services SDK and Google Sign-In for Web SDK.

The **Google Sign-In JavaScript for Web JS SDK** is set to be deprecated after
March 31, 2023. **Google Identity Services (GIS) SDK** is the new solution to
quickly and easily sign users into your app suing their Google accounts.

* In the GIS SDK, Authentication and Authorization are now two separate concerns.
  * Authentication (information about the current user) flows will not
    authorize `scopes` anymore.
  * Authorization (permissions for the app to access certain user information)
    flows will not return authentication information.
* The GIS SDK no longer has direct access to previously-seen users upon initialization.
  * `signInSilently` now displays the One Tap UX for web.
* The GIS SDK only provides an `idToken` (JWT-encoded info) when the user
  successfully completes an authentication flow. In the plugin: `signInSilently`.
* The plugin `signIn` method uses the Oauth "Implicit Flow" to Authorize the requested `scopes`.
  * If the user hasn't `signInSilently`, they'll have to sign in as a first step
    of the Authorization popup flow.
  * If `signInSilently` was unsuccessful, the plugin will add extra `scopes` to
    `signIn` and retrieve basic Profile information from the People API via a
    REST call immediately after a successful authorization. In this case, the
    `idToken` field of the `GoogleSignInUserData` will always be null.
* The GIS SDK no longer handles sign-in state and user sessions, it only provides
  Authentication credentials for the moment the user did authenticate.
* The GIS SDK no longer is able to renew Authorization sessions on the web.
  Once the token expires, API requests will begin to fail with unauthorized,
  and user Authorization is required again.

See more differences in the following migration guides:

* Authentication > [Migrating from Google Sign-In](https://developers.google.com/identity/gsi/web/guides/migration)
* Authorization > [Migrate to Google Identity Services](https://developers.google.com/identity/oauth2/web/guides/migration-to-gis)

### New use cases to take into account in your app

#### Enable access to the People API for your GCP project

Since the GIS SDK is separating Authentication from Authorization, the
[Oauth Implicit pop-up flow](https://developers.google.com/identity/oauth2/web/guides/use-token-model)
used to Authorize scopes does **not** return any Authentication information
anymore (user credential / `idToken`).

If the plugin is not able to Authenticate an user from `signInSilently` (the
OneTap UX flow), it'll add extra `scopes` to those requested by the programmer
so it can perform a [People API request](https://developers.google.com/people/api/rest/v1/people/get)
to retrieve basic profile information about the user that is signed-in.

The information retrieved from the People API is used to complete data for the
[`GoogleSignInAccount`](https://pub.dev/documentation/google_sign_in/latest/google_sign_in/GoogleSignInAccount-class.html)
object that is returned after `signIn` completes successfully.

#### `signInSilently` always returns `null`

Previous versions of this plugin were able to return a `GoogleSignInAccount`
object that was fully populated (signed-in and authorized) from `signInSilently`
because the former SDK equated "is authenticated" and "is authorized".

With the GIS SDK, `signInSilently` only deals with user Authentication, so users
retrieved "silently" will only contain an `idToken`, but not an `accessToken`.

Only after `signIn` or `requestScopes`, a user will be fully formed.

The GIS-backed plugin always returns `null` from `signInSilently`, to force apps
that expect the former logic to perform a full `signIn`, which will result in a
fully Authenticated and Authorized user, and making this migration easier.

#### `idToken` is `null` in the `GoogleSignInAccount` object after `signIn`

Since the GIS SDK is separating Authentication and Authorization, when a user
fails to Authenticate through `signInSilently` and the plugin performs the
fallback request to the People API described above,
the returned `GoogleSignInUserData` object will contain basic profile information
(name, email, photo, ID), but its `idToken` will be `null`.

This is because JWT are cryptographically signed by Google Identity Services, and
this plugin won't spoof that signature when it retrieves the information from a
simple REST request.

#### User Sessions

Since the GIS SDK does _not_ manage user sessions anymore, apps that relied on
this feature might break.

If long-lived sessions are required, consider using some user authentication
system that supports Google Sign In as a federated Authentication provider,
like [Firebase Auth](https://firebase.google.com/docs/auth/flutter/federated-auth#google),
or similar.

#### Expired / Invalid Authorization Tokens

Since the GIS SDK does _not_ auto-renew authorization tokens anymore, it's now
the responsibility of your app to do so.

Apps now need to monitor the status code of their REST API requests for response
codes different to `200`. For example:

* `401`: Missing or invalid access token.
* `403`: Expired access token.

In either case, your app needs to prompt the end user to `signIn` or
`requestScopes`, to interactively renew the token.

The GIS SDK limits authorization token duration to one hour (3600 seconds).

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
