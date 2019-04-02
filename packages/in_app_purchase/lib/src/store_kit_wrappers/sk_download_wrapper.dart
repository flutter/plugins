import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'sk_payment_transaction_wrappers.dart';
import 'sk_payment_queue_wrapper.dart';

part 'sk_download_wrapper.g.dart';

/// Dart wrapper around StoreKit's [SKDownload](https://developer.apple.com/documentation/storekit/skdownload?language=objc).
///
/// When a product is created in the App Store Connect, one or more download contents can be associated with it.
/// When the product is purchased, a List of [SKDownloadWrapper] object will be present in an [SKPaymentTransactionWrapper] object.
/// To download the content, add the [SKDownloadWrapper] objects to the payment queue and wait for the content to be downloaded.
/// You can also read the [contentURL] to get the URL of the downloaded content after the download completes.
/// Note that all downloaded files must be processed before the completion of the [SKPaymentTransactionWrapper]([SKPaymentQueueWrapper.finishTransaction] is called).
/// After the transaction is complete, any [SKDownloadWrapper] object in the transaction will not be able to be added to the payment queue
/// and the [contentURL ]of the [SKDownloadWrapper] object will be invalid.
@JsonSerializable(nullable: true)
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

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    final SKDownloadWrapper typedOther = other;
    return typedOther.contentIdentifier == contentIdentifier &&
        typedOther.state == state &&
        typedOther.contentLength == contentLength &&
        typedOther.contentURL == contentURL &&
        typedOther.contentVersion == contentVersion &&
        typedOther.transactionID == transactionID &&
        typedOther.progress == progress &&
        typedOther.timeRemaining == timeRemaining &&
        typedOther.downloadTimeUnknown == downloadTimeUnknown &&
        typedOther.error == error;
  }
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
