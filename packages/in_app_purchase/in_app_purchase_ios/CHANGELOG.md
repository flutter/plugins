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
