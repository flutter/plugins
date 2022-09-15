## 1.0.12

* Updates androidx.fragment version to 1.5.2.
* Updates minimum Flutter version to 2.10.

## 1.0.11

* Fixes avoid_redundant_argument_values lint warnings and minor typos.

## 1.0.10

* Updates `local_auth_platform_interface` constraint to the correct minimum
  version.

## 1.0.9

* Updates  androidx.fragment version to 1.5.1.

## 1.0.8

* Removes usages of `FingerprintManager` and other `BiometricManager` deprecated method usages.

## 1.0.7

* Updates gradle version to 7.2.1.

## 1.0.6

* Updates androidx.core version to 1.8.0.

## 1.0.5

* Updates references to the obsolete master branch.

## 1.0.4

* Minor fixes for new analysis options.

## 1.0.3

* Removes unnecessary imports.
* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 1.0.2

* Fixes `getEnrolledBiometrics` to match documented behaviour:
  Present biometrics that are not enrolled are no longer returned.
* `getEnrolledBiometrics` now only returns `weak` and `strong` biometric types.
* `deviceSupportsBiometrics` now returns the correct value regardless of enrollment state.

## 1.0.1

* Adopts `Object.hash`.

## 1.0.0

* Initial release from migration to federated architecture.
