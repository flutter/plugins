// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The media types that require a user gesture to begin playing.
///
/// See https://developer.apple.com/documentation/webkit/wkaudiovisualmediatypes?language=objc.
enum AudiovisualMediaType {
  /// No media types require a user gesture to begin playing.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkaudiovisualmediatypes/wkaudiovisualmediatypenone?language=objc.
  none,

  /// Media types that contain audio require a user gesture to begin playing.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkaudiovisualmediatypes/wkaudiovisualmediatypeaudio?language=objc.
  audio,

  /// Media types that contain video require a user gesture to begin playing.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkaudiovisualmediatypes/wkaudiovisualmediatypevideo?language=objc.
  video,

  /// All media types require a user gesture to begin playing.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkaudiovisualmediatypes/wkaudiovisualmediatypeall?language=objc.
  all,
}

/// A collection of properties that you use to initialize a web view.
///
/// A [WebViewConfiguration] object provides information about how to configure
/// a [WebView] object. Use your configuration object to specify:
///
/// * The initial cookies to make available to your web content
/// * Handlers for any custom URL schemes your web content uses
/// * Settings for how to handle media content
/// * Information about how to manage selections within the web view
/// * Custom scripts to inject into the webpage
/// * Custom rules that determine how to render content
///
/// You create a [WebViewConfiguration] object in your code, configure its
/// properties, and pass it to the initializer of your [WebView] object. The web
/// view incorporates your configuration settings only at creation time; you
/// cannot change those settings dynamically later.
class WebViewConfiguration {
  /// Indicates whether HTML5 videos play inline or use the native full-screen controller.
  set allowsInlineMediaPlayback(bool allow) {
    throw UnimplementedError();
  }

  /// The media types that require a user gesture to begin playing.
  ///
  /// Use [AudiovisualMediaType.none] to indicate that no user gestures are
  /// required to begin playing media.
  set mediaTypesRequiringUserActionForPlayback(
    Set<AudiovisualMediaType> types,
  ) {
    assert(types.isNotEmpty);
    throw UnimplementedError();
  }

  /// Indicates whether HTML5 videos require the user to start playing them.
  ///
  /// Deprecated for iOS >= 10.0.
  ///
  /// Passing false indicates the videos can play automatically.
  @Deprecated(
    'Deprecated for iOS 10.0+. '
    'Please use WebViewConfiguration.mediaTypesRequiringUserActionForPlayback.',
  )
  set requiresUserActionForMediaPlayback(bool required) {
    throw UnimplementedError();
  }

  /// Deprecated for iOS >= 9.0.
  @Deprecated(
    'Deprecated for iOS 9.0+. '
    'Please use WebViewConfiguration.mediaTypesRequiringUserActionForPlayback.',
  )
  set mediaPlaybackRequiresUserAction(bool required) {
    throw UnimplementedError();
  }
}

/// Object that displays interactive web content, such as for an in-app browser.
///
/// A [WebView] object is a platform-native view that you use to incorporate web
/// content seamlessly into your app’s UI. A web view supports a full
/// web-browsing experience, and presents HTML, CSS, and JavaScript content
/// alongside your app’s native views. Use it when web technologies satisfy your
/// app’s layout and styling requirements more readily than native views. For
/// example, you might use it when your app’s content changes frequently.
///
/// A web view offers control over the navigation and user experience through
/// delegate objects. Use the navigation delegate to react when the user clicks
/// links in your web content, or interacts with the content in a way that
/// affects navigation. For example, you might prevent the user from navigating
/// to new content unless specific conditions are met. Use the UI delegate to
/// present native UI elements, such as alerts or contextual menus, in response
/// to interactions with your web content.
///
/// For more extensive customizations, create your web view using a
/// [WebViewConfiguration] object. For example, use a web view configuration
/// object to specify handlers for custom URL schemes, manage cookies, and
/// customize preferences for your web content.
///
/// Before your web view appears onscreen, load content from a web server using
/// a [UrlRequest] class or load content directly from a local file or HTML
/// string. The web view automatically loads embedded resources such as images
/// or videos as part of the initial load request. It then renders your content
/// and displays the results inside the view’s bounds rectangle.
///
/// A web view automatically converts telephone numbers that appear in web
/// content to Phone links. When the user taps a Phone link, the Phone app
/// launches and dials the number. Use the [WebViewConfiguration] object to
/// change the default data detector behavior.
///
/// **Managing the Navigation Through Your Web Content**
/// [WebView[ provides a complete browsing experience, including the ability to
/// navigate between different webpages using links, forward and back buttons,
/// and more. When the user clicks a link in your content, the web view acts
/// like a browser and displays the content at that link. To disallow
/// navigation, or to customize your web view’s navigation behavior,
/// provide your web view with a navigation delegate — that is, an object that
/// extends the [NavigationDelegate] class. Use your navigation delegate to
/// modify the web view’s navigation behavior, or to track the loading progress
/// of new content.
///
/// You can also use the methods of [WebView] to navigate programmatically
/// through your content, or to trigger navigation from other parts of your
/// app’s interface. For example, if your UI includes forward and back buttons,
/// connect those buttons to the [goBack] and [goForward] methods of your web
/// view to trigger the corresponding web navigation. Use the [canGoBack] and
/// [canGoForward] fields to determine when to enable or disable your buttons.
class WebView {
  /// Construct a [WebView].
  ///
  /// [configuration] contains the configuration details for the web view. This
  /// method saves a copy of your configuration object. Changes you make to your
  /// original object after calling this method have no effect on the web view’s
  /// configuration. For a list of configuration options and their default
  /// values, see [WebViewConfiguration]. If you didn’t create your web view
  /// using the `configuration` parameter, this field contains a default
  /// configuration object.
  // TODO(bparrishMines): Remove ignore once constructor is implemented.
  // ignore: avoid_unused_constructor_parameters
  WebView([WebViewConfiguration? configuration]) {
    throw UnimplementedError();
  }
}
