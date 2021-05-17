A storefront-independent API for purchases in Flutter apps.

<!-- If this package were in its own repo, we'd put badges here -->

This plugin supports in-app purchases (_IAP_) through an _underlying store_,
which can be the App Store (on iOS) or Google Play (on Android).

> This plugin is in beta. Use it with caution and
> [file any potential issues you see](https://github.com/flutter/flutter/issues/new/choose).

<p>
  <img src="https://github.com/flutter/plugins/blob/master/packages/in_app_purchase/in_app_purchase/doc/iap_ios.gif?raw=true"
    alt="An animated image of the iOS in-app purchase UI" height="400"/>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://github.com/flutter/plugins/blob/master/packages/in_app_purchase/in_app_purchase/doc/iap_android.gif?raw=true"
   alt="An animated image of the Android in-app purchase UI" height="400"/>
</p>

## Features

Use this plugin in your Flutter app to:

* Show in-app products that are available for sale from the underlying store.
   Products can include consumables, permanent upgrades, and subscriptions.
* Load in-app products that the user owns.
* Send the user to the underlying store to purchase products.
* Present a UI for redeeming subscription offer codes. (iOS 14 only)

## Getting started

This plugin relies on the App Store and Google Play for making in-app purchases.
It exposes a unified surface, but you still need to understand and configure
your app with each store. Both stores have extensive guides:

* [App Store documentation](https://developer.apple.com/in-app-purchase/)
* [Google Play documentation](https://developer.android.com/google/play/billing/billing_overview)

For a list of steps for configuring in-app purchases in both stores, see the
[example app README](https://github.com/flutter/plugins/blob/master/packages/in_app_purchase/in_app_purchase/example/README.md).

Once you've configured your in-app purchases in their respective stores, you
can start using the plugin. Two basic options are available:

1. A generic, idiomatic Flutter API: [in_app_purchase](https://pub.dev/documentation/in_app_purchase/latest/in_app_purchase/in_app_purchase-library.html).
   This API supports most use cases for loading and making purchases.

2. Platform-specific Dart APIs: [store_kit_wrappers](https://pub.dev/documentation/in_app_purchase_ios/latest/store_kit_wrappers/store_kit_wrappers-library.html)
   and [billing_client_wrappers](https://pub.dev/documentation/in_app_purchase_android/latest/billing_client_wrappers/billing_client_wrappers-library.html).
   These APIs expose platform-specific behavior and allow for more fine-tuned
   control when needed. However, if you use one of these APIs, your
   purchase-handling logic is significantly different for the different
   storefronts.

See also the codelab for [in-app purchases in Flutter](https://codelabs.developers.google.com/codelabs/flutter-in-app-purchases) for a detailed guide on adding in-app purchase support to a Flutter App.

## Usage

This section has examples of code for the following tasks:

* [Initializing the plugin](#initializing-the-plugin)
* [Listening to purchase updates](#listening-to-purchase-updates)
* [Connecting to the underlying store](#connecting-to-the-underlying-store)
* [Loading products for sale](#loading-products-for-sale)
* [Loading previous purchases](#loading-previous-purchases)
* [Making a purchase](#making-a-purchase)
* [Completing a purchase](#completing-a-purchase)
* [Upgrading or downgrading an existing in-app subscription](#upgrading-or-downgrading-an-existing-in-app-subscription)
* [Presenting a code redemption sheet (iOS 14)](#presenting-a-code-redemption-sheet-ios-14)

### Initializing the plugin

The following initialization code is required for Google Play:

```dart
// Import `in_app_purchase_android.dart` to be able to access the 
// `InAppPurchaseAndroidPlatformAddition` class.
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

void main() {
  // Inform the plugin that this app supports pending purchases on Android.
  // An error will occur on Android if you access the plugin `instance`
  // without this call.
  if (defaultTargetPlatform == TargetPlatform.android) {
    InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  }
  runApp(MyApp());
}
```

**Note:** It is not necessary to depend on `com.android.billingclient:billing` in your own app's `android/app/build.gradle` file. If you choose to do so know that conflicts might occur.

### Listening to purchase updates

In your app's `initState` method, subscribe to any incoming purchases. These
can propagate from either underlying store.
You should always start listening to purchase update as early as possible to be able
to catch all purchase updates, including the ones from the previous app session.
To listen to the update:

```dart
class _MyAppState extends State<MyApp> {
  StreamSubscription<List<PurchaseDetails>> _subscription;

  @override
  void initState() {
    final Stream purchaseUpdated =
        InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
```

Here is an example of how to handle purchase updates:

```dart
void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
  purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.pending) {
      _showPendingUI();
    } else {
      if (purchaseDetails.status == PurchaseStatus.error) {
        _handleError(purchaseDetails.error!);
      } else if (purchaseDetails.status == PurchaseStatus.purchased || 
                 purchaseDetails.status == PurchaseStatus.restored) {
        bool valid = await _verifyPurchase(purchaseDetails);
        if (valid) {
          _deliverProduct(purchaseDetails);
        } else {
          _handleInvalidPurchase(purchaseDetails);
          return;
        }
      }
      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance
            .completePurchase(purchaseDetails);
      }
    }
  });
}
```

### Connecting to the underlying store

```dart
final bool available = await InAppPurchase.instance.isAvailable();
if (!available) {
  // The store cannot be reached or accessed. Update the UI accordingly.
}
```

### Loading products for sale

```dart
// Set literals require Dart 2.2. Alternatively, use
// `Set<String> _kIds = <String>['product1', 'product2'].toSet()`.
const Set<String> _kIds = <String>{'product1', 'product2'};
final ProductDetailsResponse response =
    await InAppPurchase.instance.queryProductDetails(_kIds);
if (response.notFoundIDs.isNotEmpty) {
  // Handle the error.
}
List<ProductDetails> products = response.productDetails;
```

### Restoring previous purchases

Restored purchases will be emitted on the `InAppPurchase.purchaseStream`, make
sure to validate restored purchases following the best practices for each 
underlying store:

* [Verifying App Store purchases](https://developer.apple.com/documentation/storekit/in-app_purchase/validating_receipts_with_the_app_store)
* [Verifying Google Play purchases](https://developer.android.com/google/play/billing/security#verify)


```dart
await InAppPurchase.instance.restorePurchases();
```

Note that the App Store does not have any APIs for querying consumable
products, and Google Play considers consumable products to no longer be owned
once they're marked as consumed and fails to return them here. For restoring
these across devices you'll need to persist them on your own server and query
that as well.

### Making a purchase

Both underlying stores handle consumable and non-consumable products differently. If
you're using `InAppPurchase`, you need to make a distinction here and
call the right purchase method for each type.

```dart
final ProductDetails productDetails = ... // Saved earlier from queryProductDetails().
final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
if (_isConsumable(productDetails)) {
  InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
} else {
  InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
}
// From here the purchase flow will be handled by the underlying store.
// Updates will be delivered to the `InAppPurchase.instance.purchaseStream`.
```

### Completing a purchase

The `InAppPurchase.purchaseStream` will send purchase updates after
you initiate the purchase flow using `InAppPurchase.buyConsumable` 
or `InAppPurchase.buyNonConsumable`. After delivering the content to 
the user, call `InAppPurchase.completePurchase` to tell the App Store
and Google Play that the purchase has been finished.

> **Warning:** Failure to call `InAppPurchase.completePurchase` and
> get a successful response within 3 days of the purchase will result a refund.

### Upgrading or downgrading an existing in-app subscription

To upgrade/downgrade an existing in-app subscription in Google Play,
you need to provide an instance of `ChangeSubscriptionParam` with the old
`PurchaseDetails` that the user needs to migrate from, and an optional
`ProrationMode` with the `GooglePlayPurchaseParam` object while calling
`InAppPurchase.buyNonConsumable`.

The App Store does not require this because it provides a subscription
grouping mechanism. Each subscription you offer must be assigned to a
subscription group. Grouping related subscriptions together can help prevent
users from accidentally purchasing multiple subscriptions. Refer to the
[Creating a Subscription Group](https://developer.apple.com/app-store/subscriptions/#groups) section of
[Apple's subscription guide](https://developer.apple.com/app-store/subscriptions/).

```dart
final PurchaseDetails oldPurchaseDetails = ...;
PurchaseParam purchaseParam = GooglePlayPurchaseParam(
    productDetails: productDetails,
    changeSubscriptionParam: ChangeSubscriptionParam(
        oldPurchaseDetails: oldPurchaseDetails,
        prorationMode: ProrationMode.immediateWithTimeProration));
InAppPurchase.instance
    .buyNonConsumable(purchaseParam: purchaseParam);
```

### Presenting a code redemption sheet (iOS 14)

The following code brings up a sheet that enables the user to redeem offer
codes that you've set up in App Store Connect. For more information on
redeeming offer codes, see [Implementing Offer Codes in Your App](https://developer.apple.com/documentation/storekit/in-app_purchase/subscriptions_and_offers/implementing_offer_codes_in_your_app).

```dart
InAppPurchaseIosPlatformAddition iosPlatformAddition = 
  InAppPurchase.getPlatformAddition<InAppPurchaseIosPlatformAddition>();
iosPlatformAddition.presentCodeRedemptionSheet();
```

> **note:** The `InAppPurchaseIosPlatformAddition` is defined in the `in_app_purchase_ios.dart` 
> file so you need to import it into the file you will be using `InAppPurchaseIosPlatformAddition`:
> ```dart
> import 'package:in_app_purchase_ios/in_app_purchase_ios.dart';
> ```

## Contributing to this plugin

If you would like to contribute to the plugin, check out our
[contribution guide](https://github.com/flutter/plugins/blob/master/CONTRIBUTING.md).
