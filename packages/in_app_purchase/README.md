# In App Purchase

A Flutter plugin for in-app purchases. Exposes APIs for making in app purchases
through the App Store (on iOS) and Google Play (on Android).

## Features

Add this to your Flutter app to:

1. Show in app products that are available for sale from the underlying shop.
   Includes consumables, permanent upgrades, and subscriptions.
2. Load in app products currently owned by the user according to the underlying
   shop.
3. Send your user to the underlying store to purchase your products.

## Getting Started

This plugin is in beta. Please use with caution and file any potential issues
you see on our [issue tracker](https://github.com/flutter/flutter/issues/new/choose).

There's a significant amount of setup required for developing in app purchases
successfully, including registering new app IDs and store entries in both the
Play Developer Console and App Store Connect. Both Google Play and the App Store
require developers to configure an app with in-app items for purchase to call
their in-app-purchase APIs. You can check out the [example
app](example/README.md) for how to configure in app purchases in both stores.

Once you've configured your in app purchases in their respective stores, you're
able to start using the plugin. There's two basic options available to you to
use.

1. [in_app_purchase.dart](lib/src/in_app_purchase.dart),
   the generic idiommatic Flutter API. This exposes the most basic IAP-related
   functionality. The goal is that Flutter apps should be able to use this API
   surface on its own for the vast majority of cases. If you use this you should
   be able to handle the basic cases of loading and making purchases, but you
   may not be able to access more subtle functionality specific to either
   underlying platform.

2. Dart APIs exposing the underlying platform APIs as directly as possible:
   [store_kit_wrappers.dart](lib/src/store_kit_wrappers.dart) and
   [billing_client_wrappers.dart](lib/src/billing_client_wrappers.dart). These
   API surfaces should expose all the platform-specific behavior and allow for
   more fine-tuned control when needed. However if you use this you'll need to
   code your purchase handling logic significantly differently depending on
   which platform you're on.

### Initializing the plugin

Using `InAppPurchaseConnection`:

```dart
// Subscribe to any incoming purchases at app initialization. These can
// propagate from either storefront so it's important to listen as soon as
// possible.
class _MyAppState extends State<MyApp> {
  StreamSubscription<List<PurchaseDetails>> _subscription;

  @override
  void initState() {
    final Stream purchaseUpdates =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdates.listen((List<PurchaseDetails> purchases) {
      _handlePurchaseUpdates(purchases);
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
```

### Connecting to the Storefront

Using `InAppPurchaseConnection`:

```dart
final bool available = await InAppPurchaseConnection.instance.isAvailable();
```

### Loading products for sale

Using `InAppPurchaseConnection`:

```dart
const Set<String> _kIds = <String>['product1', 'product2'].toSet();
final ProductDetailsResponse response = await InAppPurchaseConnection.instance.queryProductDetails(_kIds);
if (!response.notFoundIds.isEmpty()) {
    // Handle the error.
}
List<ProductDetails> products = response.productDetails;
```

### Loading previous purchases

Using `InAppPurchaseConnection`:

```dart
final QueryPurchaseDetailsResponse response = await InAppPurchaseConnection.instance.queryPastPurchases();
if (response.error != null) {
    // Handle the error.
}
for (PurchaseDetails purchase : repsonse.pastPurchases) {
    _verifyPurchase(purchase);  // Verify the purchase following the best practices for each storefront.
    _deliverPurchase(purchase); // Deliver the purchase to the user in your app.
    if (Platform.isIOS) {
        // Mark that you've delivered the purchase. Only the App Store requires
        // this final confirmation.
        InAppPurchaseConnection.instance.completePurchase(purchase);
    }
}
```

Note that the App Store does not have any APIs for querying consummable
products, and Google Play considers consummable products to no longer be owned
once they're marked as consumed and fails to return them here. For restoring
these across devices you'll need to persist them on your own server and query
that as well.

### Making a purchase

Both storefronts handle consummable and non-consummable products differently. If
you're using `InAppPurchaseConnection`, you need to make a distinction here and
call the right purchase method for each type.

```dart
final ProductDetails productDetails = ... // Saved earlier from queryPastPurchases().
final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
if (_isConsumable(productDetails)) {
    InAppPurchaseConnection.instance.buyConsumable(purchaseParam: purchaseParam);
} else {
    InAppPurchaseConnection.instance.buyNonConsumable(purchaseParam: purchaseParam);
}

// From here the purchase flow will be handled by the underlying storefront.
// Updates will be delivered to the `InAppPurchaseConnection.instance.purchaseUpdatedStream`.
```

## Development

This plugin uses
[json_serializable](https://pub.dartlang.org/packages/json_serializable) for the
many data structs passed between the underlying platform layers and Dart. After
editing any of the serialized data structs, rebuild the serializers by running
`flutter packages pub run build_runner build --delete-conflicting-outputs`.
`flutter packages pub run build_runner watch --delete-conflicting-outputs` will
watch the filesystem for changes.