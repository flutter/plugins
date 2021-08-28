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
