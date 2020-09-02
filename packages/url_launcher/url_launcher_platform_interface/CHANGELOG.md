## 1.0.8

* Added webOnlyWindowName parameter

## 1.0.7

* Update lower bound of dart dependency to 2.1.0.

## 1.0.6

* Make the pedantic dev_dependency explicit.

## 1.0.5

* Make the `PlatformInterface` `_token` non `const` (as `const` `Object`s are not unique).

## 1.0.4

* Use the common PlatformInterface code from plugin_platform_interface.
* [TEST ONLY BREAKING CHANGE] remove UrlLauncherPlatform.isMock, we're not increasing the major version
  as doing so for platform interfaces has bad implications, given that this is only going to break
  test code, and that the plugin is young and shouldn't have third-party users we've decided to land
  this as a patch bump.

## 1.0.3

* Minor DartDoc changes and add a lint for missing DartDocs.

## 1.0.2

* Use package URI in test directory to import code from lib.

## 1.0.1

* Enforce that UrlLauncherPlatform isn't implemented with `implements`.

## 1.0.0

* Initial release.
