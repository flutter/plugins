## 2.1.0

* Now `getTemporaryPath` returns the value of the `TMPDIR` environment variable primarily. If `TMPDIR` is not set, `/tmp` is returned.

## 2.0.2

* Updated installation instructions in README.

## 2.0.1

* Add `implements` to pubspec.yaml.
* Add `registerWith` method to the main Dart class.

## 2.0.0

* Migrate to null safety.

## 0.1.1+3

* Update Flutter SDK constraint.

## 0.1.1+2

* Log errors in the example when calls to the `path_provider` fail.

## 0.1.1+1

* Check in linux/ directory for example/

## 0.1.1	- NOT PUBLISHED
* Reverts changes on 0.1.0, which broke the tree.


## 0.1.0	- NOT PUBLISHED
* This release updates getApplicationSupportPath to use the application ID instead of the executable name.
  * No migration is provided, so any older apps that were using this path will now have a different directory.

## 0.0.1+2
* This release updates the example to depend on the endorsed plugin rather than relative path

## 0.0.1+1
* This updates the readme and pubspec and example to reflect the endorsement of this implementation of `path_provider`

## 0.0.1
* The initial implementation of path_provider for Linux
  * Implements getApplicationSupportPath, getApplicationDocumentsPath, getDownloadsPath, and getTemporaryPath
