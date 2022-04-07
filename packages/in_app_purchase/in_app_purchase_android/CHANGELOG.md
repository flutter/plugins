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
