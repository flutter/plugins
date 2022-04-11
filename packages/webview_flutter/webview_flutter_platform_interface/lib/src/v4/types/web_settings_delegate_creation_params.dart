import 'javascript_mode.dart';
import 'web_settings_delegate.dart';

/// Parameters object for creating a [WebSettingsDelegate] object.
/// See more at [WebViewPlatform.createWebSettingsDelegate].
class WebSettingsDelegateCreationParams {
  /// Constructs a new [WebSettingsDelegateCreationParams] object.
  const WebSettingsDelegateCreationParams({
    required this.userAgent,
    this.allowsInlineMediaPlayback,
    this.debuggingEnabled,
    this.gestureNavigationEnabled,
    this.javaScriptMode,
    this.zoomEnabled,
  });

  /// The value used for the HTTP `User-Agent:` request header.
  ///
  /// If [userAgent.value] is null the platform's default user agent should be used.
  ///
  /// An absent value ([userAgent.isPresent] is false) represents no change to this setting from the
  /// last time it was set.
  ///
  /// See also [WebView.userAgent].
  final WebSetting<String?> userAgent;

  /// Whether to play HTML5 videos inline or use the native full-screen controller on platforms that provide this functionality.
  ///
  /// This will be ignored on platforms that don't support it (such as Android).
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

  /// Sets whether the WebView should support zooming using its on-screen zoom controls and gestures.
  final bool? zoomEnabled;
}
