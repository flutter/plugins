// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:json_annotation/json_annotation.dart';

import '../channel.dart';
import '../in_app_purchase_storekit_platform.dart';

part 'sk_payment_queue_wrapper.g.dart';

/// A wrapper around
/// [`SKPaymentQueue`](https://developer.apple.com/documentation/storekit/skpaymentqueue?language=objc).
///
/// The payment queue contains payment related operations. It communicates with
/// the App Store and presents a user interface for the user to process and
/// authorize payments.
///
/// Full information on using `SKPaymentQueue` and processing purchases is
/// available at the [In-App Purchase Programming
/// Guide](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/StoreKitGuide/Introduction.html#//apple_ref/doc/uid/TP40008267).
class SKPaymentQueueWrapper {
  /// Returns the default payment queue.
  ///
  /// We do not support instantiating a custom payment queue, hence the
  /// singleton. However, you can override the observer.
  factory SKPaymentQueueWrapper() {
    return _singleton;
  }

  SKPaymentQueueWrapper._();

  static final SKPaymentQueueWrapper _singleton = SKPaymentQueueWrapper._();

  SKPaymentQueueDelegateWrapper? _paymentQueueDelegate;
  SKTransactionObserverWrapper? _observer;

  /// Calls [`-[SKPaymentQueue transactions]`](https://developer.apple.com/documentation/storekit/skpaymentqueue/1506026-transactions?language=objc)
  Future<List<SKPaymentTransactionWrapper>> transactions() async {
    return _getTransactionList((await channel
        .invokeListMethod<dynamic>('-[SKPaymentQueue transactions]'))!);
  }

  /// Calls [`-[SKPaymentQueue canMakePayments:]`](https://developer.apple.com/documentation/storekit/skpaymentqueue/1506139-canmakepayments?language=objc).
  static Future<bool> canMakePayments() async =>
      (await channel
          .invokeMethod<bool>('-[SKPaymentQueue canMakePayments:]')) ??
      false;

  /// Sets an observer to listen to all incoming transaction events.
  ///
  /// This should be called and set as soon as the app launches in order to
  /// avoid missing any purchase updates from the App Store. See the
  /// documentation on StoreKit's [`-[SKPaymentQueue
  /// addTransactionObserver:]`](https://developer.apple.com/documentation/storekit/skpaymentqueue/1506042-addtransactionobserver?language=objc).
  void setTransactionObserver(SKTransactionObserverWrapper observer) {
    _observer = observer;
    channel.setMethodCallHandler(handleObserverCallbacks);
  }

  /// Instructs the iOS implementation to register a transaction observer and
  /// start listening to it.
  ///
  /// Call this method when the first listener is subscribed to the
  /// [InAppPurchaseStoreKitPlatform.purchaseStream].
  Future<void> startObservingTransactionQueue() => channel
      .invokeMethod<void>('-[SKPaymentQueue startObservingTransactionQueue]');

  /// Instructs the iOS implementation to remove the transaction observer and
  /// stop listening to it.
  ///
  /// Call this when there are no longer any listeners subscribed to the
  /// [InAppPurchaseStoreKitPlatform.purchaseStream].
  Future<void> stopObservingTransactionQueue() => channel
      .invokeMethod<void>('-[SKPaymentQueue stopObservingTransactionQueue]');

  /// Sets an implementation of the [SKPaymentQueueDelegateWrapper].
  ///
  /// The [SKPaymentQueueDelegateWrapper] can be used to inform iOS how to
  /// finish transactions when the storefront changes or if the price consent
  /// sheet should be displayed when the price of a subscription has changed. If
  /// no delegate is registered iOS will fallback to it's default configuration.
  /// See the documentation on StoreKite's [`-[SKPaymentQueue delegate:]`](https://developer.apple.com/documentation/storekit/skpaymentqueue/3182429-delegate?language=objc).
  ///
  /// When set to `null` the payment queue delegate will be removed and the
  /// default behaviour will apply (see [documentation](https://developer.apple.com/documentation/storekit/skpaymentqueue/3182429-delegate?language=objc)).
  Future<void> setDelegate(SKPaymentQueueDelegateWrapper? delegate) async {
    if (delegate == null) {
      await channel.invokeMethod<void>('-[SKPaymentQueue removeDelegate]');
      paymentQueueDelegateChannel.setMethodCallHandler(null);
    } else {
      await channel.invokeMethod<void>('-[SKPaymentQueue registerDelegate]');
      paymentQueueDelegateChannel
          .setMethodCallHandler(handlePaymentQueueDelegateCallbacks);
    }

    _paymentQueueDelegate = delegate;
  }

  /// Posts a payment to the queue.
  ///
  /// This sends a purchase request to the App Store for confirmation.
  /// Transaction updates will be delivered to the set
  /// [SkTransactionObserverWrapper].
  ///
  /// A couple preconditions need to be met before calling this method.
  ///
  ///   - At least one [SKTransactionObserverWrapper] should have been added to
  ///     the payment queue using [addTransactionObserver].
  ///   - The [payment.productIdentifier] needs to have been previously fetched
  ///     using [SKRequestMaker.startProductRequest] so that a valid `SKProduct`
  ///     has been cached in the platform side already. Because of this
  ///     [payment.productIdentifier] cannot be hardcoded.
  ///
  /// This method calls StoreKit's [`-[SKPaymentQueue addPayment:]`]
  /// (https://developer.apple.com/documentation/storekit/skpaymentqueue/1506036-addpayment?preferredLanguage=occ).
  ///
  /// Also see [sandbox
  /// testing](https://developer.apple.com/apple-pay/sandbox-testing/).
  Future<void> addPayment(SKPaymentWrapper payment) async {
    assert(_observer != null,
        '[in_app_purchase]: Trying to add a payment without an observer. One must be set using `SkPaymentQueueWrapper.setTransactionObserver` before the app launches.');
    final Map<String, dynamic> requestMap = payment.toMap();
    await channel.invokeMethod<void>(
      '-[InAppPurchasePlugin addPayment:result:]',
      requestMap,
    );
  }

  /// Finishes a transaction and removes it from the queue.
  ///
  /// This method should be called after the given [transaction] has been
  /// succesfully processed and its content has been delivered to the user.
  /// Transaction status updates are propagated to [SkTransactionObserver].
  ///
  /// This will throw a Platform exception if [transaction.transactionState] is
  /// [SKPaymentTransactionStateWrapper.purchasing].
  ///
  /// This method calls StoreKit's [`-[SKPaymentQueue
  /// finishTransaction:]`](https://developer.apple.com/documentation/storekit/skpaymentqueue/1506003-finishtransaction?language=objc).
  Future<void> finishTransaction(
      SKPaymentTransactionWrapper transaction) async {
    final Map<String, String?> requestMap = transaction.toFinishMap();
    await channel.invokeMethod<void>(
      '-[InAppPurchasePlugin finishTransaction:result:]',
      requestMap,
    );
  }

  /// Restore previously purchased transactions.
  ///
  /// Use this to load previously purchased content on a new device.
  ///
  /// This call triggers purchase updates on the set
  /// [SKTransactionObserverWrapper] for previously made transactions. This will
  /// invoke [SKTransactionObserverWrapper.restoreCompletedTransactions],
  /// [SKTransactionObserverWrapper.paymentQueueRestoreCompletedTransactionsFinished],
  /// and [SKTransactionObserverWrapper.updatedTransaction]. These restored
  /// transactions need to be marked complete with [finishTransaction] once the
  /// content is delivered, like any other transaction.
  ///
  /// The `applicationUserName` should match the original
  /// [SKPaymentWrapper.applicationUsername] used in [addPayment].
  /// If no `applicationUserName` was used, `applicationUserName` should be null.
  ///
  /// This method either triggers [`-[SKPayment
  /// restoreCompletedTransactions]`](https://developer.apple.com/documentation/storekit/skpaymentqueue/1506123-restorecompletedtransactions?language=objc)
  /// or [`-[SKPayment restoreCompletedTransactionsWithApplicationUsername:]`](https://developer.apple.com/documentation/storekit/skpaymentqueue/1505992-restorecompletedtransactionswith?language=objc)
  /// depending on whether the `applicationUserName` is set.
  Future<void> restoreTransactions({String? applicationUserName}) async {
    await channel.invokeMethod<void>(
        '-[InAppPurchasePlugin restoreTransactions:result:]',
        applicationUserName);
  }

  /// Present Code Redemption Sheet
  ///
  /// Use this to allow Users to enter and redeem Codes
  ///
  /// This method triggers [`-[SKPayment
  /// presentCodeRedemptionSheet]`](https://developer.apple.com/documentation/storekit/skpaymentqueue/3566726-presentcoderedemptionsheet?language=objc)
  Future<void> presentCodeRedemptionSheet() async {
    await channel.invokeMethod<void>(
        '-[InAppPurchasePlugin presentCodeRedemptionSheet:result:]');
  }

  /// Shows the price consent sheet if the user has not yet responded to a
  /// subscription price change.
  ///
  /// Use this function when you have registered a [SKPaymentQueueDelegateWrapper]
  /// (using the [setDelegate] method) and returned `false` when the
  /// `SKPaymentQueueDelegateWrapper.shouldShowPriceConsent()` method was called.
  ///
  /// See documentation of StoreKit's [`-[SKPaymentQueue showPriceConsentIfNeeded]`](https://developer.apple.com/documentation/storekit/skpaymentqueue/3521327-showpriceconsentifneeded?language=objc).
  Future<void> showPriceConsentIfNeeded() async {
    await channel
        .invokeMethod<void>('-[SKPaymentQueue showPriceConsentIfNeeded]');
  }

  /// Triage a method channel call from the platform and triggers the correct observer method.
  ///
  /// This method is public for testing purposes only and should not be used
  /// outside this class.
  @visibleForTesting
  Future<dynamic> handleObserverCallbacks(MethodCall call) async {
    assert(_observer != null,
        '[in_app_purchase]: (Fatal)The observer has not been set but we received a purchase transaction notification. Please ensure the observer has been set using `setTransactionObserver`. Make sure the observer is added right at the App Launch.');
    final SKTransactionObserverWrapper observer = _observer!;
    switch (call.method) {
      case 'updatedTransactions':
        {
          final List<SKPaymentTransactionWrapper> transactions =
              _getTransactionList(call.arguments as List<dynamic>);
          return Future<void>(() {
            observer.updatedTransactions(transactions: transactions);
          });
        }
      case 'removedTransactions':
        {
          final List<SKPaymentTransactionWrapper> transactions =
              _getTransactionList(call.arguments as List<dynamic>);
          return Future<void>(() {
            observer.removedTransactions(transactions: transactions);
          });
        }
      case 'restoreCompletedTransactionsFailed':
        {
          final SKError error = SKError.fromJson(Map<String, dynamic>.from(
              call.arguments as Map<dynamic, dynamic>));
          return Future<void>(() {
            observer.restoreCompletedTransactionsFailed(error: error);
          });
        }
      case 'paymentQueueRestoreCompletedTransactionsFinished':
        {
          return Future<void>(() {
            observer.paymentQueueRestoreCompletedTransactionsFinished();
          });
        }
      case 'shouldAddStorePayment':
        {
          final SKPaymentWrapper payment = SKPaymentWrapper.fromJson(
              (call.arguments['payment'] as Map<dynamic, dynamic>)
                  .cast<String, dynamic>());
          final SKProductWrapper product = SKProductWrapper.fromJson(
              (call.arguments['product'] as Map<dynamic, dynamic>)
                  .cast<String, dynamic>());
          return Future<void>(() {
            if (observer.shouldAddStorePayment(
                    payment: payment, product: product) ==
                true) {
              SKPaymentQueueWrapper().addPayment(payment);
            }
          });
        }
      default:
        break;
    }
    throw PlatformException(
        code: 'no_such_callback',
        message: 'Did not recognize the observer callback ${call.method}.');
  }

  // Get transaction wrapper object list from arguments.
  List<SKPaymentTransactionWrapper> _getTransactionList(
      List<dynamic> transactionsData) {
    return transactionsData.map<SKPaymentTransactionWrapper>((dynamic map) {
      return SKPaymentTransactionWrapper.fromJson(
          Map.castFrom<dynamic, dynamic, String, dynamic>(
              map as Map<dynamic, dynamic>));
    }).toList();
  }

  /// Triage a method channel call from the platform and triggers the correct
  /// payment queue delegate method.
  ///
  /// This method is public for testing purposes only and should not be used
  /// outside this class.
  @visibleForTesting
  Future<dynamic> handlePaymentQueueDelegateCallbacks(MethodCall call) async {
    assert(_paymentQueueDelegate != null,
        '[in_app_purchase]: (Fatal)The payment queue delegate has not been set but we received a payment queue notification. Please ensure the payment queue has been set using `setDelegate`.');

    final SKPaymentQueueDelegateWrapper delegate = _paymentQueueDelegate!;
    switch (call.method) {
      case 'shouldContinueTransaction':
        final SKPaymentTransactionWrapper transaction =
            SKPaymentTransactionWrapper.fromJson(
                (call.arguments['transaction'] as Map<dynamic, dynamic>)
                    .cast<String, dynamic>());
        final SKStorefrontWrapper storefront = SKStorefrontWrapper.fromJson(
            (call.arguments['storefront'] as Map<dynamic, dynamic>)
                .cast<String, dynamic>());
        return delegate.shouldContinueTransaction(transaction, storefront);
      case 'shouldShowPriceConsent':
        return delegate.shouldShowPriceConsent();
      default:
        break;
    }
    throw PlatformException(
        code: 'no_such_callback',
        message:
            'Did not recognize the payment queue delegate callback ${call.method}.');
  }
}

/// Dart wrapper around StoreKit's
/// [NSError](https://developer.apple.com/documentation/foundation/nserror?language=objc).
@immutable
@JsonSerializable()
class SKError {
  /// Creates a new [SKError] object with the provided information.
  const SKError(
      {required this.code, required this.domain, required this.userInfo});

  /// Constructs an instance of this from a key-value map of data.
  ///
  /// The map needs to have named string keys with values matching the names and
  /// types of all of the members on this class. The `map` parameter must not be
  /// null.
  factory SKError.fromJson(Map<String, dynamic> map) {
    return _$SKErrorFromJson(map);
  }

  /// Error [code](https://developer.apple.com/documentation/foundation/1448136-nserror_codes)
  /// as defined in the Cocoa Framework.
  @JsonKey(defaultValue: 0)
  final int code;

  /// Error
  /// [domain](https://developer.apple.com/documentation/foundation/nscocoaerrordomain?language=objc)
  /// as defined in the Cocoa Framework.
  @JsonKey(defaultValue: '')
  final String domain;

  /// A map that contains more detailed information about the error.
  ///
  /// Any key of the map must be a valid [NSErrorUserInfoKey](https://developer.apple.com/documentation/foundation/nserroruserinfokey?language=objc).
  @JsonKey(defaultValue: <String, dynamic>{})
  final Map<String, dynamic> userInfo;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SKError &&
        other.code == code &&
        other.domain == domain &&
        const DeepCollectionEquality.unordered()
            .equals(other.userInfo, userInfo);
  }

  @override
  int get hashCode => Object.hash(
        code,
        domain,
        userInfo,
      );
}

/// Dart wrapper around StoreKit's
/// [SKPayment](https://developer.apple.com/documentation/storekit/skpayment?language=objc).
///
/// Used as the parameter to initiate a payment. In general, a developer should
/// not need to create the payment object explicitly; instead, use
/// [SKPaymentQueueWrapper.addPayment] directly with a product identifier to
/// initiate a payment.
@immutable
@JsonSerializable(createToJson: true)
class SKPaymentWrapper {
  /// Creates a new [SKPaymentWrapper] with the provided information.
  const SKPaymentWrapper({
    required this.productIdentifier,
    this.applicationUsername,
    this.requestData,
    this.quantity = 1,
    this.simulatesAskToBuyInSandbox = false,
    this.paymentDiscount,
  });

  /// Constructs an instance of this from a key value map of data.
  ///
  /// The map needs to have named string keys with values matching the names and
  /// types of all of the members on this class. The `map` parameter must not be
  /// null.
  factory SKPaymentWrapper.fromJson(Map<String, dynamic> map) {
    assert(map != null);
    return _$SKPaymentWrapperFromJson(map);
  }

  /// Creates a Map object describes the payment object.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'productIdentifier': productIdentifier,
      'applicationUsername': applicationUsername,
      'requestData': requestData,
      'quantity': quantity,
      'simulatesAskToBuyInSandbox': simulatesAskToBuyInSandbox
    };
  }

  /// The id for the product that the payment is for.
  @JsonKey(defaultValue: '')
  final String productIdentifier;

  /// An opaque id for the user's account.
  ///
  /// Used to help the store detect irregular activity. See
  /// [applicationUsername](https://developer.apple.com/documentation/storekit/skpayment/1506116-applicationusername?language=objc)
  /// for more details. For example, you can use a one-way hash of the user’s
  /// account name on your server. Don’t use the Apple ID for your developer
  /// account, the user’s Apple ID, or the user’s plaintext account name on
  /// your server.
  final String? applicationUsername;

  /// Reserved for future use.
  ///
  /// The value must be null before sending the payment. If the value is not
  /// null, the payment will be rejected.
  ///
  // The iOS Platform provided this property but it is reserved for future use.
  // We also provide this property to match the iOS platform. Converted to
  // String from NSData from ios platform using UTF8Encoding. The / default is
  // null.
  final String? requestData;

  /// The amount of the product this payment is for.
  ///
  /// The default is 1. The minimum is 1. The maximum is 10.
  ///
  /// If the object is invalid, the value could be 0.
  @JsonKey(defaultValue: 0)
  final int quantity;

  /// Produces an "ask to buy" flow in the sandbox.
  ///
  /// Setting it to `true` will cause a transaction to be in the state [SKPaymentTransactionStateWrapper.deferred],
  /// which produce an "ask to buy" prompt that interrupts the the payment flow.
  ///
  /// Default is `false`.
  ///
  /// See https://developer.apple.com/in-app-purchase/ for a guide on Sandbox
  /// testing.
  final bool simulatesAskToBuyInSandbox;

  /// The details of a discount that should be applied to the payment.
  ///
  /// See [Implementing Promotional Offers in Your App](https://developer.apple.com/documentation/storekit/original_api_for_in-app_purchase/subscriptions_and_offers/implementing_promotional_offers_in_your_app?language=objc)
  /// for more information on generating keys and creating offers for
  /// auto-renewable subscriptions. If set to `null` no discount will be
  /// applied to this payment.
  final SKPaymentDiscountWrapper? paymentDiscount;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SKPaymentWrapper &&
        other.productIdentifier == productIdentifier &&
        other.applicationUsername == applicationUsername &&
        other.quantity == quantity &&
        other.simulatesAskToBuyInSandbox == simulatesAskToBuyInSandbox &&
        other.requestData == requestData;
  }

  @override
  int get hashCode => Object.hash(productIdentifier, applicationUsername,
      quantity, simulatesAskToBuyInSandbox, requestData);

  @override
  String toString() => _$SKPaymentWrapperToJson(this).toString();
}

/// Dart wrapper around StoreKit's
/// [SKPaymentDiscount](https://developer.apple.com/documentation/storekit/skpaymentdiscount?language=objc).
///
/// Used to indicate a discount is applicable to a payment. The
/// [SKPaymentDiscountWrapper] instance should be assigned to the
/// [SKPaymentWrapper] object to which the discount should be applied.
/// Discount offers are set up in App Store Connect. See [Implementing Promotional Offers in Your App](https://developer.apple.com/documentation/storekit/original_api_for_in-app_purchase/subscriptions_and_offers/implementing_promotional_offers_in_your_app?language=objc)
/// for more information.
@immutable
@JsonSerializable(createToJson: true)
class SKPaymentDiscountWrapper {
  /// Creates a new [SKPaymentDiscountWrapper] with the provided information.
  const SKPaymentDiscountWrapper({
    required this.identifier,
    required this.keyIdentifier,
    required this.nonce,
    required this.signature,
    required this.timestamp,
  });

  /// Constructs an instance of this from a key value map of data.
  ///
  /// The map needs to have named string keys with values matching the names and
  /// types of all of the members on this class.
  factory SKPaymentDiscountWrapper.fromJson(Map<String, dynamic> map) {
    assert(map != null);
    return _$SKPaymentDiscountWrapperFromJson(map);
  }

  /// Creates a Map object describes the payment object.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'identifier': identifier,
      'keyIdentifier': keyIdentifier,
      'nonce': nonce,
      'signature': signature,
      'timestamp': timestamp,
    };
  }

  /// The identifier of the discount offer.
  ///
  /// The identifier must match one of the offers set up in App Store Connect.
  final String identifier;

  /// A string identifying the key that is used to generate the signature.
  ///
  /// Keys are generated and downloaded from App Store Connect. See
  /// [Generating a Signature for Promotional Offers](https://developer.apple.com/documentation/storekit/original_api_for_in-app_purchase/subscriptions_and_offers/generating_a_signature_for_promotional_offers?language=objc)
  /// for more information.
  final String keyIdentifier;

  /// A universal unique identifier (UUID) created together with the signature.
  ///
  /// The UUID should be generated on your server when it creates the
  /// `signature` for the payment discount. The UUID can be used once, a new
  /// UUID should be created for each payment request. The string representation
  /// of the UUID must be lowercase. See
  /// [Generating a Signature for Promotional Offers](https://developer.apple.com/documentation/storekit/original_api_for_in-app_purchase/subscriptions_and_offers/generating_a_signature_for_promotional_offers?language=objc)
  /// for more information.
  final String nonce;

  /// A cryptographically signed string representing the to properties of the
  /// promotional offer.
  ///
  /// The signature is string signed with a private key and contains all the
  /// properties of the promotional offer. To keep you private key secure the
  /// signature should be created on a server. See [Generating a Signature for Promotional Offers](https://developer.apple.com/documentation/storekit/original_api_for_in-app_purchase/subscriptions_and_offers/generating_a_signature_for_promotional_offers?language=objc)
  /// for more information.
  final String signature;

  /// The date and time the signature was created.
  ///
  /// The timestamp should be formatted in Unix epoch time. See
  /// [Generating a Signature for Promotional Offers](https://developer.apple.com/documentation/storekit/original_api_for_in-app_purchase/subscriptions_and_offers/generating_a_signature_for_promotional_offers?language=objc)
  /// for more information.
  final int timestamp;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SKPaymentDiscountWrapper &&
        other.identifier == identifier &&
        other.keyIdentifier == keyIdentifier &&
        other.nonce == nonce &&
        other.signature == signature &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode =>
      Object.hash(identifier, keyIdentifier, nonce, signature, timestamp);
}
