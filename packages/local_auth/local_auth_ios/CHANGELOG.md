## NEXT

* Removes unnecessary imports.

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
