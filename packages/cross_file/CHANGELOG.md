## 0.3.0

* Migrated package to null-safety.
* **breaking change** According to our unit tests, the API should be backwards-compatible. Some relevant changes were made, however:
  * Web: `lastModified` returns the epoch time as a default value, to maintain the `Future<DateTime>` return type (and not `null`)

## 0.2.1

* Prepare for breaking `package:http` change.

## 0.2.0

* **breaking change** Make sure the `saveTo` method returns a `Future` so it can be awaited and users are sure the file has been written to disk.

## 0.1.0+2

* Fix outdated links across a number of markdown files ([#3276](https://github.com/flutter/plugins/pull/3276))

## 0.1.0+1

* Update Flutter SDK constraint.

## 0.1.0

* Initial open-source release.
