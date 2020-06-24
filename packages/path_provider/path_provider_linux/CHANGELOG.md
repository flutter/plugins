## 0.1.0
* This release updaes getApplicationSupportPath to use the application ID instead of the executable name.
  * Older apps will lose their preferences as they migrate to the new app ID based path.

## 0.0.1+2
* This release updates the example to depend on the endorsed plugin rather than relative path

## 0.0.1+1
* This updates the readme and pubspec and example to reflect the endorsement of this implementation of `path_provider`

## 0.0.1
* The initial implementation of path_provider for Linux
  * Implements getApplicationSupportPath, getApplicationDocumentsPath, getDownloadsPath, and getTemporaryPath
  
