## NEXT

* Updates minimum Flutter version to 2.10.

## 0.2.1+1

* Fixes avoid_redundant_argument_values lint warnings and minor typos.

## 0.2.1

* Adds a check for string size before Win32 MultiByte <-> WideChar conversions

## 0.2.0

**BREAKING CHANGES**:
  * `CameraException.code` now has value `"CameraAccessDenied"` if camera access permission was denied.
  * `CameraException.code` now has value `"camera_error"` if error occurs during capture.

## 0.1.0+5

* Fixes bugs in in error handling.

## 0.1.0+4

* Allows retrying camera initialization after error.

## 0.1.0+3

* Updates the README to better explain how to use the unendorsed package.

## 0.1.0+2

* Updates references to the obsolete master branch.

## 0.1.0+1

* Removes unnecessary imports.
* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 0.1.0

* Initial release
