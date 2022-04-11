// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../webview_platform.dart';
import 'javascript_mode.dart';
import 'web_settings_delegate_creation_params.dart';

/// A single setting for configuring a WebViewPlatform which may be absent.
@immutable
class WebSetting<T> {
  /// Constructs an absent setting instance.
  ///
  /// The [isPresent] field for the instance will be false.
  ///
  /// Accessing [value] for an absent instance will throw.
  const WebSetting.absent()
      : _value = null,
        isPresent = false;

  /// Constructs a setting of the given `value`.
  ///
  /// The [isPresent] field for the instance will be true.
  const WebSetting.of(T value)
      : _value = value,
        isPresent = true;

  final T? _value;

  /// The setting's value.
  ///
  /// Throws if [WebSetting.isPresent] is false.
  T get value {
    if (!isPresent) {
      throw StateError('Cannot access a value of an absent WebSetting');
    }
    assert(isPresent);
    // The intention of this getter is to return T whether it is nullable or
    // not whereas _value is of type T? since _value can be null even when
    // T is not nullable (when isPresent == false).
    //
    // We promote _value to T using `as T` instead of `!` operator to handle
    // the case when _value is legitimately null (and T is a nullable type).
    // `!` operator would always throw if _value is null.
    return _value as T;
  }

  /// True when this web setting instance contains a value.
  ///
  /// When false the [WebSetting.value] getter throws.
  final bool isPresent;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is WebSetting<T> &&
        other.isPresent == isPresent &&
        other._value == _value;
  }

  @override
  int get hashCode => hashValues(_value, isPresent);
}

/// Defines the parameters to configure a [WebViewPlatform].
///
/// Initial settings are passed as part of [CreationParams], settings updates
/// are sent with [WebViewPlatformController#updateSettings].
///
/// Platform specific implementations can add additional fields by extending this
/// class and provide a factory method that takes the
/// [WebSettingsDelegate] as a parameter.
///
/// {@tool sample}
/// This example demonstrates how to extend the [WebSettingsDelegate] to
/// provide additional platform specific parameters.
///
/// Note that the additional parameters should always accept `null` or have a
/// default value to prevent breaking changes.
///
/// ```dart
/// class AndroidWebSettingsDelegate extends WebSettingsDelegate {
///   AndroidWebSettingsDelegate._(
///     WebSettingsDelegate webSettingsDelegate,
///     this.historyUrl,
///   ) : super(
///     allowsInlineMediaPlayback: webSettingsDelegate.allowsInlineMediaPlayback,
///     debuggingEnabled: webSettingsDelegate.debuggingEnabled,
///     gestureNavigationEnabled: webSettingsDelegate.gestureNavigationEnabled,
///     hasNavigationDelegate: webSettingsDelegate.hasNavigationDelegate,
///     hasProgressTracking: webSettingsDelegate.hasProgressTracking,
///     javaScriptMode: webSettingsDelegate.javaScriptMode,
///     userAgent: webSettingsDelegate.userAgent,
///     zoomEnabled: webSettingsDelegate.zoomEnabled,
///   );
///
///   factory AndroidWebSettingsDelegate.fromWebSettingsDelegate(
///     WebSettingsDelegate webSettings, {
///     Uri? historyUrl,
///   }) {
///     return AndroidWebSettingsDelegate._(
///       webSettings: webSettings,
///       historyUrl: historyUrl,
///     );
///   }
///
///   final Uri? historyUrl;
/// }
/// ```
/// {@end-tool}
class WebSettingsDelegate extends PlatformInterface {
  /// Construct an instance with initial settings.
  ///
  /// Future setting changes can be sent with [WebViewPlatformController#updateSettings].
  factory WebSettingsDelegate({
    required WebSettingsDelegateCreationParams options,
  }) {
    final WebSettingsDelegate webSettingsDelegate =
        WebViewPlatform.instance!.createWebSettingsDelegate(
      options: options,
    );
    PlatformInterface.verify(webSettingsDelegate, _token);
    return webSettingsDelegate;
  }

  /// Used by the platform implementation to create a new
  /// [WebSettingsDelegate].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  WebSettingsDelegate.implementation({
    required WebSettingsDelegateCreationParams options,
  })  : allowsInlineMediaPlayback = options.allowsInlineMediaPlayback,
        userAgent = options.userAgent,
        debuggingEnabled = options.debuggingEnabled,
        gestureNavigationEnabled = options.gestureNavigationEnabled,
        javaScriptMode = options.javaScriptMode,
        zoomEnabled = options.zoomEnabled,
        super(token: _token);

  static final Object _token = Object();

  /// Whether to play HTML5 videos inline or use the native full-screen controller on iOS.
  ///
  /// This will have no effect on Android.
  final bool? allowsInlineMediaPlayback;

  /// Whether to enable the platform's webview content debugging tools.
  ///
  /// See also: [WebView.debuggingEnabled].
  final bool? debuggingEnabled;

  /// Whether to allow swipe based navigation on supported platforms.
  ///
  /// See also: [WebView.gestureNavigationEnabled]
  final bool? gestureNavigationEnabled;

  /// The JavaScript execution mode to be used by the webview.
  final JavaScriptMode? javaScriptMode;

  /// The value used for the HTTP `User-Agent:` request header.
  ///
  /// If [userAgent.value] is null the platform's default user agent should be used.
  ///
  /// An absent value ([userAgent.isPresent] is false) represents no change to this setting from the
  /// last time it was set.
  ///
  /// See also [WebView.userAgent].
  final WebSetting<String?> userAgent;

  /// Sets whether the WebView should support zooming using its on-screen zoom controls and gestures.
  final bool? zoomEnabled;

  @override
  String toString() {
    return 'WebSettings(javaScriptMode: $javaScriptMode, debuggingEnabled: $debuggingEnabled, gestureNavigationEnabled: $gestureNavigationEnabled, userAgent: $userAgent, allowsInlineMediaPlayback: $allowsInlineMediaPlayback)';
  }
}
