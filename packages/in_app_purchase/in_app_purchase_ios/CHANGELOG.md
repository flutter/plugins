## 0.1.3+4

* Update minimum Flutter SDK to 2.5 and iOS deployment target to 9.0.

## 0.1.3+3

* Add `implements` to pubspec.

# 0.1.3+2

* Removed dependency on the `test` package.

# 0.1.3+1

- Updated installation instructions in README.

## 0.1.3

* Add price symbol to platform interface object ProductDetail.

## 0.1.2+2

* Fix crash when retrieveReceiptWithError gives an error.

## 0.1.2+1

* Fix wrong data type when cancelling user credentials dialog.

## 0.1.2

* Added countryCode to the SKPriceLocaleWrapper.

## 0.1.1+1

* iOS: Fix treating missing App Store receipt as an exception.

## 0.1.1

* Added support to register a `SKPaymentQueueDelegateWrapper` and handle changes to active subscriptions accordingly (see also Store Kit's [SKPaymentQueueDelegate](https://developer.apple.com/documentation/storekit/skpaymentqueuedelegate?language=objc)).

## 0.1.0+2

* Changed the iOS payment queue handler in such a way that it only adds a listener to the `SKPaymentQueue` when there
  is a listener to the Dart `purchaseStream`.

## 0.1.0+1

* Added a "Restore purchases" button to conform to Apple's StoreKit guidelines on [restoring products](https://developer.apple.com/documentation/storekit/in-app_purchase/restoring_purchased_products?language=objc);

## 0.1.0

* Initial open-source release.
