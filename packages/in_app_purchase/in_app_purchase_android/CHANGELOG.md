## 0.2.3+4

* Updates minimum Flutter version to 2.10.
* Adds IMMEDIATE_AND_CHARGE_FULL_PRICE to the `ProrationMode`.

## 0.2.3+3

* Fixes avoid_redundant_argument_values lint warnings and minor typos.

## 0.2.3+2

* Fixes incorrect json key in `queryPurchasesAsync` that fixes restore purchases functionality.

## 0.2.3+1

* Updates `json_serializable` to fix warnings in generated code.

## 0.2.3

* Upgrades Google Play Billing Library to 5.0
* Migrates APIs to support breaking changes in new Google Play Billing API
* `PurchaseWrapper` and `PurchaseHistoryRecordWrapper` now handles `skus` a list of sku strings. `sku` is deprecated.

## 0.2.2+8

* Ignores deprecation warnings for upcoming styleFrom button API changes.

## 0.2.2+7

* Updates references to the obsolete master branch.

## 0.2.2+6

* Enables mocking models by changing overridden operator == parameter type from `dynamic` to `Object`.

## 0.2.2+5

* Minor fixes for new analysis options.

## 0.2.2+4

* Removes unnecessary imports.
* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 0.2.2+3

* Migrates from `ui.hash*` to `Object.hash*`.
* Updates minimum Flutter version to 2.5.0.

## 0.2.2+2

* Internal code cleanup for stricter analysis options.

## 0.2.2+1

* Removes the dependency on `meta`.

## 0.2.2

* Fixes the `purchaseStream` incorrectly reporting `PurchaseStatus.error` when user upgrades subscription by deferred proration mode.

## 0.2.1

* Deprecated the `InAppPurchaseAndroidPlatformAddition.enablePendingPurchases()` method and `InAppPurchaseAndroidPlatformAddition.enablePendingPurchase` property. Since Google Play no longer accepts App submissions that don't support pending purchases it is no longer necessary to acknowledge this through code.
* Updates example app Android compileSdkVersion to 31.

## 0.2.0

* BREAKING CHANGE : Refactor to handle new `PurchaseStatus` named `canceled`. This means developers
  can distinguish between an error and user cancellation.

## 0.1.6

* Require Dart SDK >= 2.14.
* Update `json_annotation` dependency to `^4.3.0`.

## 0.1.5+1

* Fix a broken link in the README.

## 0.1.5

* Introduced the `SkuDetailsWrapper.introductoryPriceAmountMicros` field of the correct type (`int`) and deprecated the `SkuDetailsWrapper.introductoryPriceMicros` field.
* Update dev_dependency `build_runner` to ^2.0.0 and `json_serializable` to ^5.0.2.

## 0.1.4+7

* Ensure that the `SkuDetailsWrapper.introductoryPriceMicros` is populated correctly.

## 0.1.4+6

* Ensure that purchases correctly indicate whether they are acknowledged or not. The `PurchaseDetails.pendingCompletePurchase` field now correctly indicates if the purchase still needs to be completed.

## 0.1.4+5

* Add `implements` to pubspec.
* Updated Android lint settings.

## 0.1.4+4

* Removed dependency on the `test` package.

## 0.1.4+3

* Updated installation instructions in README.

## 0.1.4+2

* Added price currency symbol to SkuDetailsWrapper.

## 0.1.4+1

* Fixed typos.

## 0.1.4

* Added support for launchPriceChangeConfirmationFlow in the BillingClientWrapper and in InAppPurchaseAndroidPlatformAddition.

## 0.1.3+1

* Add payment proxy.

## 0.1.3

* Added support for isFeatureSupported in the BillingClientWrapper and in InAppPurchaseAndroidPlatformAddition.

## 0.1.2

* Added support for the obfuscatedAccountId and obfuscatedProfileId in the PurchaseWrapper.

## 0.1.1

* Added support to request a list of active subscriptions and non-consumed one-time purchases on Android, through the `InAppPurchaseAndroidPlatformAddition.queryPastPurchases` method.

## 0.1.0+1

* Migrate maven repository from jcenter to mavenCentral.

## 0.1.0

* Initial open-source release.
