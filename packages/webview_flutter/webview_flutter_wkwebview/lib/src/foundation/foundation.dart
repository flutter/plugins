// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/foundation.dart';

/// The values that can be returned in a change map.
///
/// Wraps [NSKeyValueObservingOptions](https://developer.apple.com/documentation/foundation/nskeyvalueobservingoptions?language=objc).
enum NSKeyValueObservingOptions {
  /// Indicates that the change map should provide the new attribute value, if applicable.
  ///
  /// See https://developer.apple.com/documentation/foundation/nskeyvalueobservingoptions/nskeyvalueobservingoptionnew?language=objc.
  newValue,

  /// Indicates that the change map should contain the old attribute value, if applicable.
  ///
  /// See https://developer.apple.com/documentation/foundation/nskeyvalueobservingoptions/nskeyvalueobservingoptionold?language=objc.
  oldValue,

  /// Indicates a notification should be sent to the observer immediately.
  ///
  /// See https://developer.apple.com/documentation/foundation/nskeyvalueobservingoptions/nskeyvalueobservingoptioninitial?language=objc.
  initialValue,

  /// Whether separate notifications should be sent to the observer before and after each change.
  ///
  /// See https://developer.apple.com/documentation/foundation/nskeyvalueobservingoptions/nskeyvalueobservingoptionprior?language=objc.
  priorNotification,
}

/// The kinds of changes that can be observed.
///
/// Wraps [NSKeyValueChange](https://developer.apple.com/documentation/foundation/nskeyvaluechange?language=objc).
enum NSKeyValueChange {
  /// Indicates that the value of the observed key path was set to a new value.
  ///
  /// See https://developer.apple.com/documentation/foundation/nskeyvaluechange/nskeyvaluechangesetting?language=objc.
  setting,

  /// Indicates that an object has been inserted into the to-many relationship that is being observed.
  ///
  /// See https://developer.apple.com/documentation/foundation/nskeyvaluechange/nskeyvaluechangeinsertion?language=objc.
  insertion,

  /// Indicates that an object has been removed from the to-many relationship that is being observed.
  ///
  /// See https://developer.apple.com/documentation/foundation/nskeyvaluechange/nskeyvaluechangeremoval?language=objc.
  removal,

  /// Indicates that an object has been replaced in the to-many relationship that is being observed.
  ///
  /// See https://developer.apple.com/documentation/foundation/nskeyvaluechange/nskeyvaluechangereplacement?language=objc.
  replacement,
}

/// The keys that can appear in the change map.
///
/// Wraps [NSKeyValueChangeKey](https://developer.apple.com/documentation/foundation/nskeyvaluechangekey?language=objc).
enum NSKeyValueChangeKey {
  /// Indicates changes made in a collection.
  ///
  /// See https://developer.apple.com/documentation/foundation/nskeyvaluechangeindexeskey?language=objc.
  indexes,

  /// Indicates what sort of change has occurred.
  ///
  /// See https://developer.apple.com/documentation/foundation/nskeyvaluechangekindkey?language=objc.
  kind,

  /// Indicates the new value for the attribute.
  ///
  /// See https://developer.apple.com/documentation/foundation/nskeyvaluechangenewkey?language=objc.
  newValue,

  /// Indicates a notification is sent prior to a change.
  ///
  /// See https://developer.apple.com/documentation/foundation/nskeyvaluechangenotificationispriorkey?language=objc.
  notificationIsPrior,

  /// Indicates the value of this key is the value before the attribute was changed.
  ///
  /// https://developer.apple.com/documentation/foundation/nskeyvaluechangeoldkey?language=objc.
  oldValue,
}

/// A URL load request that is independent of protocol or URL scheme.
///
/// Wraps [NSUrlRequest](https://developer.apple.com/documentation/foundation/nsurlrequest?language=objc).
@immutable
class NSUrlRequest {
  /// Constructs an [NSUrlRequest].
  const NSUrlRequest({
    required this.url,
    this.httpMethod,
    this.httpBody,
    this.allHttpHeaderFields = const <String, String>{},
  });

  /// The URL being requested.
  final String url;

  /// The HTTP request method.
  ///
  /// The default HTTP method is “GET”.
  final String? httpMethod;

  /// Data sent as the message body of a request, as in an HTTP POST request.
  final Uint8List? httpBody;

  /// All of the HTTP header fields for a request.
  final Map<String, String> allHttpHeaderFields;
}

/// Information about an error condition.
///
/// Wraps [NSError](https://developer.apple.com/documentation/foundation/nserror?language=objc).
@immutable
class NSError {
  /// Constructs an [NSError].
  const NSError({
    required this.code,
    required this.domain,
    required this.localizedDescription,
  });

  /// The error code.
  ///
  /// Note that errors are domain-specific.
  final int code;

  /// A string containing the error domain.
  final String domain;

  /// A string containing the localized description of the error.
  final String localizedDescription;
}

/// The root class of most Objective-C class hierarchies.
class NSObject {
  /// Registers the observer object to receive KVO notifications.
  Future<void> addObserver(
    NSObject observer, {
    required String keyPath,
    required Set<NSKeyValueObservingOptions> options,
  }) {
    assert(options.isNotEmpty);
    throw UnimplementedError();
  }

  /// Stops the observer object from receiving change notifications for the property.
  Future<void> removeObserver(NSObject observer, {required String keyPath}) {
    throw UnimplementedError();
  }

  /// Informs the observing object when the value at the specified key path has changed.
  set observeValue(
    void Function(
      String keyPath,
      NSObject object,
      Map<NSKeyValueChangeKey, Object?> change,
    )?
        observeValue,
  ) {
    throw UnimplementedError();
  }
}
