// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

/// The values that can be returned in a change map.
///
/// These constants are passed to [FoundationObject.addObserver] and determine
/// the values that are returned as part of the change map passed to an
/// [FoundationObject.observeValue]. You can pass an empty set if you require no
/// change map values.
///
/// See https://developer.apple.com/documentation/foundation/nskeyvalueobservingoptions?language=objc.
enum KeyValueObservingOptions {
  /// Indicates that the change map should provide the new attribute value, if applicable.
  ///
  /// See https://developer.apple.com/documentation/foundation/nskeyvalueobservingoptions/nskeyvalueobservingoptionnew?language=objc.
  new_,

  /// Indicates that the change map should contain the old attribute value, if applicable.
  ///
  /// See https://developer.apple.com/documentation/foundation/nskeyvalueobservingoptions/nskeyvalueobservingoptionold?language=objc.
  old,

  /// Indicates a notification should be sent to the observer immediately.
  ///
  /// If specified the notification is before the observer registration method
  /// even returns.
  ///
  /// The change map in the notification will always contain an
  /// NSKeyValueChangeNewKey entry if [KeyValueObservingOptions.new_] is also
  /// specified but will never contain an NSKeyValueChangeOldKey entry. (In an
  /// initial notification the current value of the observed property may be
  /// old, but it's new to the observer.) You can use this option instead of
  /// explicitly invoking, at the same time, code that is also invoked by the
  /// observer's [FoundationObject.observeValue] method. When
  /// this option is used with [FoundationObject.addObserver], a notification
  /// will be sent for each indexed object to which the observer is being added.
  ///
  /// See https://developer.apple.com/documentation/foundation/nskeyvalueobservingoptions/nskeyvalueobservingoptioninitial?language=objc.
  initial,

  /// Whether separate notifications should be sent to the observer before and after each change.
  ///
  /// This is in constrast to a single notification after the change.
  ///
  /// The change map in a notification sent before a change always
  /// contains an NSKeyValueChangeNotificationIsPriorKey entry whose value is a
  /// num that contains the bool value true, but never contains an
  /// NSKeyValueChangeNewKey entry. When this option is specified, the change
  /// map in a notification sent after a change contains the same entries
  /// that it would contain if this option were not specified. You can use this
  /// option when the observer's own key-value observing-compliance requires it
  /// to invoke one of the -willChange... methods for one of its own properties,
  /// and the value of that property depends on the value of the observed
  /// object's property. (In that situation it's too late to easily invoke
  /// -willChange... properly in response to receiving an
  /// observeValueForKeyPath:ofObject:change:context: message after the change.)
  ///
  /// See https://developer.apple.com/documentation/foundation/nskeyvalueobservingoptions/nskeyvalueobservingoptionprior?language=objc.
  prior,
}

/// The kinds of changes that can be observed.
///
/// These values are returned as the value for a [KeyValueChangeKey.kind] in the
/// change map passed to [FoundationObject.observeValue] indicating the
/// type of change made.
///
/// See https://developer.apple.com/documentation/foundation/nskeyvaluechange?language=objc.
enum KeyValueChange {
  /// Indicates that the value of the observed key path was set to a new value.
  ///
  /// This change can occur when observing an attribute of an object, as well as
  /// properties that specify to-one and to-many relationships.
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
/// These values are used as keys in the change map passed to
/// [FoundationObject.observeValue].
///
/// See https://developer.apple.com/documentation/foundation/nskeyvaluechangekey?language=objc.
enum KeyValueChangeKey {
  /// Indicates changes made in a collection.
  ///
  /// If the value of the [KeyValueChangeKey.kind] entry is
  /// [KeyValueChange.insertion], [KeyValueChange.removal], or
  /// [KeyValueChange.replacement], the value of this key is a Set object that
  /// contains the indexes of the inserted, removed, or replaced objects.
  ///
  /// See https://developer.apple.com/documentation/foundation/nskeyvaluechangeindexeskey?language=objc.
  indexes,

  /// Indicates what sort of change has occurred.
  ///
  /// Contains a value from [KeyValueChange].
  ///
  /// A value of [KeyValueChange.setting] indicates that the observed object has
  /// received an Objective-C `setValue:forKey:` message, or that the
  /// key-value-coding-compliant set method for the key has been invoked, or
  /// that one of the `willChangeValueForKey:` or `didChangeValueForKey:`
  /// methods has otherwise been invoked.
  ///
  /// A value of [KeyValueChange.insertion], [KeyValueChange.removal, or
  /// [KeyValueChange.replacement] indicates that mutating messages have been
  /// sent a key-value observing compliant collection proxy, or that one of the
  /// key-value-coding-compliant collection mutation methods for the key has
  /// been invoked, or a collection will change or did change method has been
  /// otherwise been invoked.
  ///
  /// See https://developer.apple.com/documentation/foundation/nskeyvaluechangekindkey?language=objc.
  kind,

  /// Indicates the new value for the attribute.
  ///
  /// If the value of the [KeyValueChangeKey.kind] entry is
  /// [KeyValueChange.setting], and [KeyValueObservingOptions.new_] was
  /// specified when the observer was registered, the value of this key is the
  /// new value for the attribute.
  ///
  /// For [KeyValueChange.insertion] or [KeyValueChange.replacement], if
  /// [KeyValueObservingOptions.new_] was specified when the observer was
  /// registered, the value for this key is a List instance that contains the
  /// objects that have been inserted or replaced other objects, respectively.
  ///
  /// See https://developer.apple.com/documentation/foundation/nskeyvaluechangenewkey?language=objc.
  new_,

  /// Indicates a notification is sent prior to a change.
  ///
  /// If the [KeyValueObservingOptions.prior] option was specified when the
  /// observer was registered this notification is sent prior to a change.
  ///
  /// The change map contains an [KeyValueChangeKey.notificationIsPrior] entry
  /// whose value is a bool.
  ///
  /// See https://developer.apple.com/documentation/foundation/nskeyvaluechangenotificationispriorkey?language=objc.
  notificationIsPrior,

  /// Indicates a notification before the attribute was changed.
  ///
  /// If the value of the [KeyValueChangeKey.kind] entry is
  /// [KeyValueChange.setting], and [KeyValueObservingOptions.old] was specified
  /// when the observer was registered, the value of this key is the value
  /// before the attribute was changed.
  ///
  /// For [KeyValueChange.removal] or [KeyValueChange.replacement], if
  /// [KeyValueObservingOptions.old] was specified when the observer was
  /// registered, the value is a List instance that contains the objects that
  /// have been removed or have been replaced by other objects, respectively.
  ///
  /// See https://developer.apple.com/documentation/foundation/nskeyvaluechangeoldkey?language=objc.
  old,
}

/// Information about an error condition including a domain, a domain-specific error code, and application-specific information.
class FoundationError {
  /// Constructs a [FoundationError].
  FoundationError({
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

/// A URL load request that is independent of protocol or URL scheme.
///
/// [UrlRequest] encapsulates two essential properties of a load request: the
/// URL to load and the policies used to load it. In addition, for HTTP and
/// HTTPS requests, URLRequest includes the HTTP method (GET, POST, and so on)
/// and the HTTP headers. Finally, custom protocols can support custom
/// properties as explained in
/// [Custom Protocol Properties](https://developer.apple.com/documentation/foundation/nsurlrequest?language=objc#3174619).
class UrlRequest {
  /// Constructs a [UrlRequest].
  UrlRequest({
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

/// The root class of most Objective-C class hierarchies.
///
/// An object from which subclasses inherit a basic interface to the runtime
/// system and the ability to behave as Objective-C objects.
class FoundationObject {
  /// Registers the observer object to receive KVO notifications.
  ///
  /// [observer] - The object to register for KVO notifications.
  ///
  /// [keyPath] - The key path, relative to the object receiving this message,
  /// of the property to observe.
  ///
  /// [options] - A combination of the [KeyValueObservingOptions]s values that
  /// specifies what is included in observation notifications. For possible
  /// values, see [KeyValueObservingOptions].
  ///
  /// Neither the object receiving this message, nor observer, are retained. An
  /// object that calls this method must also eventually call
  /// [removeObserver] method to unregister the observer when participating in
  /// KVO.
  Future<void> addObserver(
    FoundationObject observer,
    String keyPath,
    Set<KeyValueObservingOptions> options,
  ) {
    assert(options.isNotEmpty);
    throw UnimplementedError();
  }

  /// Stops the observer object from receiving change notifications for the property.
  ///
  /// The property was specified by the key path set in [addObserver].
  Future<void> removeObserver(FoundationObject observer, String keyPath) {
    throw UnimplementedError();
  }

  /// Informs the observing object when the value at the specified key path.
  ///
  /// For an object to begin sending change notification messages for the value
  /// at [keyPath], you send it an [addObserver] message, naming the observing
  /// object that should receive the messages. When you are done observing, and
  /// in particular before the observing object is deallocated, you send the
  /// observed object a [removeObserver] message to unregister the observer, and
  /// stop sending change notification messages.
  void observeValue(
    String keyPath,
    FoundationObject object,
    Map<KeyValueChangeKey, Object?> change,
  ) {
    throw UnimplementedError();
  }
}
