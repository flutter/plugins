## 0.3.2+1

* Updates minimum Flutter version to 2.10.
* Replaces deprecated ThemeData.primaryColor.

## 0.3.2

* Adds the `identifier` and `type` fields to the `SKProductDiscountWrapper` to reflect the changes in the [SKProductDiscount](https://developer.apple.com/documentation/storekit/skproductdiscount?language=objc) in iOS 12.2.

## 0.3.1+1

* Fixes avoid_redundant_argument_values lint warnings and minor typos.

## 0.3.1

* Adds ability to purchase more than one of a product.

## 0.3.0+10

* Ignores deprecation warnings for upcoming styleFrom button API changes.

## 0.3.0+9

* Updates references to the obsolete master branch.

## 0.3.0+8

* Fixes a memory leak on iOS.

## 0.3.0+7

* Minor fixes for new analysis options.

## 0.3.0+6

* Removes unnecessary imports.
* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 0.3.0+5

* Migrates from `ui.hash*` to `Object.hash*`.

## 0.3.0+4

* Ensures that `NSError` instances with an unexpected value for the `userInfo` field don't crash the app, but send an explanatory message instead.

## 0.3.0+3

* Implements transaction caching for StoreKit ensuring transactions are delivered to the Flutter client.

## 0.3.0+2

* Internal code cleanup for stricter analysis options.

## 0.3.0+1

* Removes dependency on `meta`.

## 0.3.0

* **BREAKING CHANGE:** `InAppPurchaseStoreKitPlatform.restorePurchase()` emits an empty instance of `List<ProductDetails>` when there were no transactions to restore, indicating that the restore procedure has finished.

## 0.2.1

* Renames `in_app_purchase_ios` to `in_app_purchase_storekit` to facilitate
  future macOS support.
