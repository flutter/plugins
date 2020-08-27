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

