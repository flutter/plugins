## 2.1.6

* Internal code cleanup for stricter analysis options.

## 2.1.5

* Removes dependency on `meta`.

## 2.1.4

* Implemented `maxWidth`, `maxHeight` and `imageQuality` when selecting images
  (except for gifs).

## 2.1.3

* Add `implements` to pubspec.

## 2.1.2

* Updated installation instructions in README.

# 2.1.1

* Implemented `getMultiImage`.
* Initialized the following `XFile` attributes for picked files:
  * `name`, `length`, `mimeType` and `lastModified`.

# 2.1.0

* Implemented `getImage`, `getVideo` and `getFile` methods that return `XFile` instances.
* Move tests to `example` directory, so they run as integration_tests with `flutter drive`.

# 2.0.0

* Migrate to null safety.
* Add doc comments to point out that some arguments aren't supported on the web.

# 0.1.0+3

* Update Flutter SDK constraint.

# 0.1.0+2

* Adds Video MIME Types for the safari browser for acception

# 0.1.0+1

* Remove `android` directory.

# 0.1.0

* Initial open-source release.
