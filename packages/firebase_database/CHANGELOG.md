## 0.2.0

* Support for multiple databases, new dependency on firebase_core
* Relax GMS dependency to 11.+

## 0.1.4

* Add FLT prefix to iOS types
* Avoid error when clearing FirebaseSortedList

## 0.1.3

* Fix memory leak in FirebaseAnimatedList
* Change GMS dependency to 11.4.+

## 0.1.2

* Change GMS dependency to 11.+

## 0.1.1

* Add RTDB transaction support.

## 0.1.0+1

* Aligned author name with rest of repo.

## 0.1.0

* **Breaking Change**: Added current list index to the type signature of itemBuilder for FirebaseAnimatedList.

## 0.0.14

* Fix FirebaseSortedList to show data changes.

## 0.0.13

* Fixed lingering value/child listeners.

## 0.0.12

* Updated to Firebase SDK to always use latest patch version for 11.0.x builds

## 0.0.11

* Fixes startAt/endAt on iOS when used without a key

## 0.0.10

* Added workaround for inconsistent numeric types when using keepSynced on iOS
* Bug fixes to Query handling

## 0.0.9

* Updated to Firebase SDK Version 11.0.1

## 0.0.8

* Added missing offline persistence and query functionality on Android
* Fixed startAt query behavior on iOS
* Persistence methods no longer throw errors on failure, return false instead
* Updates to docs and tests

## 0.0.7

* Fixed offline persistence on iOS

## 0.0.6

* Various APIs added to FirebaseDatabase and Query
* Added removal and priority to DatabaseReference
* Improved documentation
* Added unit tests

## 0.0.5

* Fixed analyzer warnings

## 0.0.4

* Removed stub code and replaced it with support for more event types, paths, auth
* Improved example

## 0.0.3

* Updated README.md
* Bumped buildToolsVersion to 25.0.3
* Added example app

## 0.0.2

* Fix compilation error

## 0.0.1

* Initial Release
