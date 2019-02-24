// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/src/channel.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sk_payment_queue_wrapper.g.dart';

/// A wrapper around [`SKPaymentQueue`](https://developer.apple.com/documentation/storekit/skpaymentqueue?language=objc).
///
/// The payment queue contains payment related operations. It communicates with App Store and presents
/// a user interface for the user to process and authorize the payment.
class SKPaymentQueueWrapper {
  /// Calls [`-[SKPaymentQueue canMakePayments:]`](https://developer.apple.com/documentation/storekit/skpaymentqueue/1506139-canmakepayments?language=objc).
  static Future<bool> canMakePayments() async =>
      await channel.invokeMethod('-[SKPaymentQueue canMakePayments:]');
}

/// Dart wrapper around StoreKit's
/// [SKPaymentTransactionState](https://developer.apple.com/documentation/storekit/skpaymenttransactionstate?language=objc).
///
/// Presents the state of a transaction. Used for handling a transaction based on different state.
enum SKPaymentTransactionStateWrapper {
  /// Indicates the transaction is being processed in App Store.
  @JsonValue(0)
  purchasing,

  /// The payment is processed. You should provide the user the content they purchased.
  @JsonValue(1)
  purchased,

  /// The transaction failed. Check the [SKPaymentTransactionWrapper.error] property from [SKPaymentTransactionWrapper] for details.
  @JsonValue(2)
  failed,

  /// This transaction restores the content previously purchased by the user. The previous transaction information can be
  /// obtained in [SKPaymentTransactionWrapper.originalTransaction] from [SKPaymentTransactionWrapper].
  @JsonValue(3)
  restored,

  /// The transaction is in the queue but pending external action. Wait for another callback to get the final state.
  @JsonValue(4)
  deferred,
}

/// Dart wrapper around StoreKit's [SKPaymentTransaction](https://developer.apple.com/documentation/storekit/skpaymenttransaction?language=objc).
///
/// Created when a payment is added to the [SKPaymentQueueWrapper]. Transactions are delivered to your app when a payment is finished processing.
/// Completed transactions provide a receipt and a transaction identifier that the app can use to save a permanent record of the processed payment.
@JsonSerializable()
class SKPaymentTransactionWrapper {
  SKPaymentTransactionWrapper({
    @required this.payment,
    @required this.transactionState,
    @required this.originalTransaction,
    @required this.transactionTimeStamp,
    @required this.transactionIdentifier,
    @required this.downloads,
    @required this.error,
  });

  /// Constructs an instance of this from a key value map of data.
  ///
  /// The map needs to have named string keys with values matching the names and
  /// types of all of the members on this class.
  /// The `map` parameter must not be null.
  @visibleForTesting
  factory SKPaymentTransactionWrapper.fromJson(Map map) {
    if (map == null) {
      return null;
    }
    return _$SKPaymentTransactionWrapperFromJson(map);
  }

  /// Current transaction state.
  final SKPaymentTransactionStateWrapper transactionState;

  /// The payment that is created and added to the payment queue which generated this transaction.
  final SKPaymentWrapper payment;

  /// The original Transaction, only available if the [transactionState] is [SKPaymentTransactionStateWrapper.restored].
  ///
  /// When the [transactionState] is [SKPaymentTransactionStateWrapper.restored], the current transaction object holds a new
  /// [transactionIdentifier].
  final SKPaymentTransactionWrapper originalTransaction;

  /// The timestamp of the transaction.
  ///
  /// Milliseconds since epoch.
  /// It is only defined when the [transactionState] is [SKPaymentTransactionStateWrapper.purchased] or [SKPaymentTransactionStateWrapper.restored].
  final double transactionTimeStamp;

  /// The unique string identifer of the transaction.
  ///
  /// It is only defined when the [transactionState] is [SKPaymentTransactionStateWrapper.purchased] or [SKPaymentTransactionStateWrapper.restored].
  /// You may wish to record this string as part of an audit trail for App Store purchases.
  /// The value of this string corresponds to the same property in the receipt.
  final String transactionIdentifier;

  /// An array of the [SKDownloadWrapper] object of this transaction.
  ///
  /// Only available if the transaction contains downloadable contents.
  ///
  /// It is only defined when the [transactionState] is [SKPaymentTransactionStateWrapper.purchased].
  /// Must be used to download the transaction's content before the transaction is finished.
  final List<SKDownloadWrapper> downloads;

  /// The error object, only available if the [transactionState] is [SKPaymentTransactionStateWrapper.failed].
  final SKError error;
}

/// Dart wrapper around StoreKit's [SKDownloadState](https://developer.apple.com/documentation/storekit/skdownloadstate?language=objc).
///
/// The state a download operation that can be in.
enum SKDownloadState {
  /// Indicates that downloadable content is waiting to start.
  @JsonValue(0)
  waiting,

  /// The downloadable content is currently being downloaded
  @JsonValue(1)
  active,

  /// The app paused the download.
  @JsonValue(2)
  pause,

  /// The content is successfully downloaded.
  @JsonValue(3)
  finished,

  /// Indicates that some error occurred while the content was being downloaded.
  @JsonValue(4)
  failed,

  /// The app canceled the download.
  @JsonValue(5)
  cancelled,
}

/// Dart wrapper around StoreKit's [SKDownload](https://developer.apple.com/documentation/storekit/skdownload?language=objc).
///
/// When a product is created in the App Store Connect, one or more download contents can be associated with it.
/// When the product is purchased, a List of [SKDownloadWrapper] object will be present in an [SKPaymentTransactionWrapper] object.
/// To download the content, add the [SKDownloadWrapper] objects to the payment queue and wait for the content to be downloaded.
/// You can also read the [contentURL] to get the URL of the downloaded content after the download completes.
/// Note that all downloaded files must be processed before the completion of the [SKPaymentTransactionWrapper].
/// After the transaction is complete, any [SKDownloadWrapper] object in the transaction will not be able to be added to the payment queue
/// and the [contentURL ]of the [SKDownloadWrapper] object will be invalid.
@JsonSerializable()
class SKDownloadWrapper {
  SKDownloadWrapper({
    @required this.contentIdentifier,
    @required this.state,
    @required this.contentLength,
    @required this.contentURL,
    @required this.contentVersion,
    @required this.transactionID,
    @required this.progress,
    @required this.timeRemaining,
    @required this.downloadTimeUnknown,
    @required this.error,
  });

  /// Constructs an instance of this from a key value map of data.
  ///
  /// The map needs to have named string keys with values matching the names and
  /// types of all of the members on this class.
  /// The `map` parameter must not be null.
  @visibleForTesting
  factory SKDownloadWrapper.fromJson(Map map) {
    assert(map != null);
    return _$SKDownloadWrapperFromJson(map);
  }

  /// Identifies the downloadable content.
  ///
  /// It is specified in the App Store Connect when the downloadable content is created.
  final String contentIdentifier;

  /// The current download state.
  ///
  /// When the state changes, one of the [SKTransactionObserverWrapper] subclasses' observing methods should be triggered.
  /// The developer should properly handle the downloadable content based on the state.
  final SKDownloadState state;

  /// Length of the content in bytes.
  final int contentLength;

  /// The URL string of the content.
  final String contentURL;

  /// Version of the content formatted as a series of dot-separated integers.
  final String contentVersion;

  /// The transaction ID of the transaction that is associated with the downloadable content.
  final String transactionID;

  /// The download progress, between 0.0 to 1.0.
  final double progress;

  /// The estimated time remaining for the download; if no good estimate is able to be made,
  /// [downloadTimeUnknown] will be set to true.
  final double timeRemaining;

  /// true if [timeRemaining] cannot be estimated.
  final bool downloadTimeUnknown;

  /// The error that prevented the downloading; only available if the [transactionState] is [SKPaymentTransactionStateWrapper.failed].
  final SKError error;
}

/// Dart wrapper around StoreKit's [NSError](https://developer.apple.com/documentation/foundation/nserror?language=objc).
@JsonSerializable()
class SKError {
  SKError(
      {@required this.code, @required this.domain, @required this.userInfo});

  /// Constructs an instance of this from a key-value map of data.
  ///
  /// The map needs to have named string keys with values matching the names and
  /// types of all of the members on this class.
  /// The `map` parameter must not be null.
  @visibleForTesting
  factory SKError.fromJson(Map map) {
    assert(map != null);
    return _$SKErrorFromJson(map);
  }

  /// Error [code](https://developer.apple.com/documentation/foundation/1448136-nserror_codes) defined in the Cocoa Framework.
  final int code;

  /// Error [domain](https://developer.apple.com/documentation/foundation/nscocoaerrordomain?language=objc) defined in the Cocoa Framework.
  final String domain;

  /// A map that contains more detailed information about the error. Any key of the map must be one of the [NSErrorUserInfoKey](https://developer.apple.com/documentation/foundation/nserroruserinfokey?language=objc).
  final Map<String, dynamic> userInfo;
}

/// Dart wrapper around StoreKit's [SKPayment](https://developer.apple.com/documentation/storekit/skpayment?language=objc).
///
/// Used as the parameter to initiate a payment.
/// In general, a developer should not need to create the payment object explicitly; instead, use
/// [SKPaymentQueueWrapper.addPayment] directly with a product identifier to initiate a payment.
@JsonSerializable()
class SKPaymentWrapper {
  SKPaymentWrapper(
      {@required this.productIdentifier,
      @required this.applicationUsername,
      this.requestData,
      this.quantity = 1,
      this.simulatesAskToBuyInSandbox = false});

  /// Constructs an instance of this from a key value map of data.
  ///
  /// The map needs to have named string keys with values matching the names and
  /// types of all of the members on this class.
  /// The `map` parameter must not be null.
  @visibleForTesting
  factory SKPaymentWrapper.fromJson(Map map) {
    assert(map != null);
    return _$SKPaymentWrapperFromJson(map);
  }

  /// The id for the product that the payment is for.
  final String productIdentifier;

  /// An opaque id for the user's account.
  ///
  /// Used to help the store detect irregular activity. See https://developer.apple.com/documentation/storekit/skpayment/1506116-applicationusername?language=objc for more details.
  final String applicationUsername;

  /// Reserved for future use.
  ///
  /// The value must be null before sending the payment. If the value is not null, the payment will be rejected.
  /// Converted to String from NSData from ios platform using UTF8Encoding. The default is null.
  // The iOS Platform provided this property but it is reserved for future use. We also provide this
  // property to match the iOS platform; in case any future update for this property occurs, we do not need to
  // add this property later.
  final String requestData;

  /// The amount of the product this payment is for. The default is 1. The minimum is 1. The maximum is 10.
  final int quantity;

  /// Produces an "ask to buy" flow in the sandbox if set to true. Default is false. I doesn't do it.
  ///
  /// For how to test in App Store sand box, see https://developer.apple.com/in-app-purchase/.
  final bool simulatesAskToBuyInSandbox;
}
