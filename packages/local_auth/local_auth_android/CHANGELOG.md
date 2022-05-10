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
