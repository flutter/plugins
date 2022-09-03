## NEXT

* Updates minimum Flutter version to 2.10.

## 2.3.0

* Adopts `plugin_platform_interface`. As a result, `isMock` is deprecated in
  favor of the now-standard `MockPlatformInterfaceMixin`.

## 2.2.0

* Adds support for the `serverClientId` parameter.

## 2.1.3

* Enables mocking models by changing overridden operator == parameter type from `dynamic` to `Object`.
* Removes unnecessary imports.
* Adds `SignInInitParameters` class to hold all sign in params, including the new `forceCodeForRefreshToken`.

## 2.1.2

* Internal code cleanup for stricter analysis options.

## 2.1.1

* Removes dependency on `meta`.

## 2.1.0

* Add serverAuthCode attribute to user data

## 2.0.1

* Updates `init` function in `MethodChannelGoogleSignIn` to parametrize `clientId` property.

## 2.0.0

* Migrate to null-safety.

## 1.1.3

* Update Flutter SDK constraint.

## 1.1.2

* Update lower bound of dart dependency to 2.1.0.

## 1.1.1

* Add attribute serverAuthCode.

## 1.1.0

* Add hasRequestedScope method to determine if an Oauth scope has been granted.
* Add requestScope Method to request new Oauth scopes be granted by the user.

## 1.0.4

* Make the pedantic dev_dependency explicit.

## 1.0.3

* Remove the deprecated `author:` field from pubspec.yaml
* Require Flutter SDK 1.10.0 or greater.

## 1.0.2

* Add missing documentation.

## 1.0.1

* Switch away from quiver_hashcode.

## 1.0.0

* Initial release.
