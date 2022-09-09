## NEXT

* Updates minimum Flutter version to 2.10.

## 1.0.9

* Fixes avoid_redundant_argument_values lint warnings and minor typos.

## 1.0.8

* Updates `local_auth_platform_interface` constraint to the correct minimum
  version.

## 1.0.7

* Updates references to the obsolete master branch.

## 1.0.6

* Suppresses warnings for pre-iOS-11 codepaths.

## 1.0.5

* Removes unnecessary imports.
* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 1.0.4

* Fixes `deviceSupportsBiometrics` to return true when biometric hardware
  is available but not enrolled.

## 1.0.3

* Adopts `Object.hash`.

## 1.0.2

* Adds support `localizedFallbackTitle` in authenticateWithBiometrics on iOS.

## 1.0.1

* BREAKING CHANGE: Changes `stopAuthentication` to always return false instead of throwing an error.

## 1.0.0

* Initial release from migration to federated architecture.
