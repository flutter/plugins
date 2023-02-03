// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'billing_client_wrapper.dart';
import 'purchase_wrapper.dart';

/// Abstraction of result of [BillingClient] operation that includes
/// a [BillingResponse].
abstract class HasBillingResponse {
  /// The status of the operation.
  abstract final BillingResponse responseCode;
}

/// Utility class that manages a [BillingClient] connection.
///
/// Connection is initialized on creation of [BillingClientManager].
/// If [BillingClient] sends `onBillingServiceDisconnected` event or any
/// operation returns [BillingResponse.serviceDisconnected], connection is
/// re-initialized.
///
/// [BillingClient] instance is not exposed directly. It can be accessed via
/// [run] and [runRaw] methods that handle the connection management.
///
/// Consider calling [dispose] after the [BillingClient] is no longer needed.
class BillingClientManager {
  /// Creates the [BillingClientManager].
  ///
  /// Immediately initializes connection to the underlying [BillingClient].
  BillingClientManager() {
    _connect();
  }

  /// Stream of `onPurchasesUpdated` events from the [BillingClient].
  ///
  /// This is a broadcast stream, so it can be listened to multiple times.
  /// A "done" event will be sent after [dispose] is called.
  late final Stream<PurchasesResultWrapper> purchasesUpdatedStream =
      _purchasesUpdatedController.stream;

  /// [BillingClient] instance managed by this [BillingClientManager].
  ///
  /// In order to access the [BillingClient], consider using [run] and [runRaw]
  /// methods.
  @visibleForTesting
  late final BillingClient client = BillingClient(_onPurchasesUpdated);

  final StreamController<PurchasesResultWrapper> _purchasesUpdatedController =
      StreamController<PurchasesResultWrapper>.broadcast();

  bool _isConnecting = false;
  bool _isDisposed = false;

  // Initialized immediately in the constructor, so it's always safe to access.
  late Future<void> _readyFuture;

  /// Executes the given [block] with access to the underlying [BillingClient].
  ///
  /// If necessary, waits for the underlying [BillingClient] to connect.
  /// If given [block] returns [BillingResponse.serviceDisconnected], it will
  /// be transparently retried after the connection is restored. Because
  /// of this, [block] may be called multiple times.
  ///
  /// A response with [BillingResponse.serviceDisconnected] may be returned
  /// in case of [dispose] being called during the operation.
  ///
  /// See [runRaw] for operations that do not return a subclass
  /// of [HasBillingResponse].
  Future<R> run<R extends HasBillingResponse>(
    Future<R> Function(BillingClient client) block,
  ) async {
    assert(_debugAssertNotDisposed());
    await _readyFuture;
    final R result = await block(client);
    if (result.responseCode == BillingResponse.serviceDisconnected &&
        !_isDisposed) {
      await _connect();
      return run(block);
    } else {
      return result;
    }
  }

  /// Executes the given [block] with access to the underlying [BillingClient].
  ///
  /// If necessary, waits for the underlying [BillingClient] to connect.
  /// Designed only for operations that do not return a subclass
  /// of [HasBillingResponse] (e.g. [BillingClient.isReady],
  /// [BillingClient.isFeatureSupported]).
  ///
  /// See [runRaw] for operations that return a subclass
  /// of [HasBillingResponse].
  Future<R> runRaw<R>(Future<R> Function(BillingClient client) block) async {
    assert(_debugAssertNotDisposed());
    await _readyFuture;
    return block(client);
  }

  /// Ends connection to the [BillingClient].
  ///
  /// Consider calling [dispose] after you no longer need the [BillingClient]
  /// API to free up the resources.
  ///
  /// After calling [dispose] :
  /// - Further connection attempts will not be made;
  /// - [purchasesUpdatedStream] will be closed;
  /// - Calls to [run] and [runRaw] will throw.
  void dispose() {
    assert(_debugAssertNotDisposed());
    _isDisposed = true;
    client.endConnection();
    _purchasesUpdatedController.close();
  }

  // If disposed, does nothing.
  // If currently connecting, waits for it to complete.
  // Otherwise, starts a new connection.
  Future<void> _connect() {
    if (_isDisposed) {
      return Future<void>.value();
    }
    if (_isConnecting) {
      return _readyFuture;
    }
    _isConnecting = true;
    _readyFuture = Future<void>.sync(() async {
      await client.startConnection(onBillingServiceDisconnected: _connect);
      _isConnecting = false;
    });
    return _readyFuture;
  }

  void _onPurchasesUpdated(PurchasesResultWrapper event) {
    if (_isDisposed) {
      return;
    }
    _purchasesUpdatedController.add(event);
  }

  bool _debugAssertNotDisposed() {
    assert(() {
      if (_isDisposed) {
        throw FlutterError(
          'A BillingClientManager was used after being disposed.\n'
          'Once you have called dispose() on a BillingClientManager, it can no longer be used.',
        );
      }
      return true;
    }());
    return true;
  }
}
