/// Modal presentation styles available when presenting view controllers.
///
/// For more info see
/// https://developer.apple.com/documentation/uikit/uimodalpresentationstyle
enum UIModalPresentationStyle {
  /// The default presentation style chosen by the system.
  automatic,

  /// A presentation style that indicates no adaptations should be made.
  /// Not working
  none,

  /// A presentation style in which the presented view covers the screen.
  fullScreen,

  /// A presentation style that partially covers the underlying content.
  pageSheet,

  /// A presentation style that displays the content centered in the screen.
  formSheet,

  /// A presentation style where the content is displayed over another view controller’s content.
  currentContext,

  /// A view presentation style in which the presented view covers the screen.
  overFullScreen,

  /// A presentation style where the content is displayed over another view controller’s content.
  overCurrentContext,

  /// A presentation style where the content is displayed in a popover view.
  popover,

  /// A presentation style that blurs the underlying content before displaying new content in a full-screen presentation.
  blurOverFullScreen,
}
