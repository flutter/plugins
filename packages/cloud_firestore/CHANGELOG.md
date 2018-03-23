## 0.3.2

* Support for batched writes.

## 0.3.1

* Add GeoPoint class
* Allow for reading and writing DocumentReference, DateTime, and GeoPoint
  values from and to Documents.

## 0.3.0

* **Breaking change**. Set SDK constraints to match the Flutter beta release.

## 0.2.12

* Fix handling of `null` document snapshots (document not exists).
* Add `DocumentSnapshot.exists`.

## 0.2.11
* Fix Dart 2 type errors.

## 0.2.10
* Fix Dart 2 type errors.

## 0.2.9
* Relax sdk upper bound constraint to  '<2.0.0' to allow 'edge' dart sdk use.

## 0.2.8
* Support for Query.getDocuments

## 0.2.7

* Add transaction support.

## 0.2.6

* Build fixes for iOS
* Null checking in newly added Query methods

## 0.2.5

* Query can now have more than one orderBy field.
* startAt, startAfter, endAt, and endBefore support
* limit support

## 0.2.4

* Support for DocumentReference.documentID
* Support for CollectionReference.add

## 0.2.3

* Simplified and upgraded Android project template to Android SDK 27.
* Updated package description.

## 0.2.2

* Add `get` to DocumentReference.

## 0.2.1

* Fix bug on Android where removeListener is sometimes called without a handle

## 0.2.0

* **Breaking change**. Upgraded to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).
* Relaxed GMS dependency to [11.4.0,12.0[

## 0.1.2

* Support for `DocumentReference` update and merge writes
* Suppress unchecked warnings and package name warnings on Android

## 0.1.1

* Added FLT prefix to iOS types.

## 0.1.0

* Added reference to DocumentSnapshot
* Breaking: removed path from DocumentSnapshot
* Additional test coverage for reading collections and documents
* Fixed typo in DocumentChange documentation

## 0.0.6

* Support for getCollection

## 0.0.5

* Support `isNull` filtering in `Query.where`
* Fixed `DocumentChange.oldIndex` and `DocumentChange.newIndex` to be signed
  integers (iOS)

## 0.0.4

* Support for where clauses
* Support for deletion

## 0.0.3

* Renamed package to cloud_firestore

## 0.0.2

* Add path property to DocumentSnapshot

## 0.0.1+1

* Update project homepage

## 0.0.1

* Initial Release
