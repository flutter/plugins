## 2.0.0

* Added `ConnectivityResult.unknown`, for the cases where the plugin is unable to determine the
connectivity status of the device. _(This happens mostly in the `web` platform.)_

## 1.0.3

* Make the pedantic dev_dependency explicit.

## 1.0.2

* Bring ConnectivityResult and LocationAuthorizationStatus enums from the core package.
* Use the above Enums as return values for ConnectivityPlatformInterface methods.
* Modify the MethodChannel implementation so it returns the right types.
* Bring all utility methods, asserts and other logic that is only needed on the MethodChannel implementation from the core package.
* Bring MethodChannel unit tests from core package.

## 1.0.1

* Fix README.md link.

## 1.0.0

* Initial release.
