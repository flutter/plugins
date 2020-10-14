// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:url_launcher_platform_interface/link.dart';

typedef _ClickListener = void Function(html.MouseEvent);

/// The unique identifier for the view type to be used for link platform views.
const String viewType = '__url_launcher::link';

/// The name of the property used to set the viewId on the DOM element.
const String _viewIdProperty = '__url_launcher::link::viewId';

/// Signature for a function that takes a unique [id] and creates an HTML element.
typedef PlatformViewFactory = html.Element Function(int viewId);

/// Factory that returns the link DOM element for each unique view id.
PlatformViewFactory get linkViewFactory => _LinkViewController._viewFactory;

/// The delegate for building the [Link] widget on the web.
///
/// It uses a platform view to render an anchor element in the DOM.
class WebLinkDelegate extends StatefulWidget {
  /// Creates a delegate for the given [link].
  const WebLinkDelegate(this.link);

  /// Information about the link built by the app.
  final LinkInfo link;

  @override
  _WebLinkDelegateState createState() => _WebLinkDelegateState();
}

class _WebLinkDelegateState extends State<WebLinkDelegate> {
  _LinkViewController _controller;

  @override
  void didUpdateWidget(WebLinkDelegate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.link.uri != oldWidget.link.uri) {
      _controller?._setUri(widget.link.uri);
    }
    if (widget.link.target != oldWidget.link.target) {
      _controller?._setTarget(widget.link.target);
    }
  }

  Future<void> _followLink() {
    final Completer<void> completer = Completer<void>();
    _LinkViewController._registerHitTest(
      _controller,
      onClick: (html.MouseEvent event) {
        completer.complete(_onDomClick(event));
      },
    );
    return completer.future;
  }

  Future<void> _onDomClick(html.MouseEvent event) {
    if (!widget.link.uri.hasScheme) {
      // A uri that doesn't have a scheme is an internal route name. In this
      // case, we push it via Flutter's navigation system instead of letting the
      // browser handle it.
      event.preventDefault();
      final String routeName = widget.link.uri.toString();
      // TODO(mdebbar): how do we know if `isUsingRouter` should be true or false?
      return pushRouteNameToFramework(routeName, isUsingRouter: false);
    }

    // External links will be handled by the browser, so we don't have to do
    // anything.
    return Future<void>.value(null);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.link.builder(
          context,
          widget.link.isDisabled ? null : _followLink,
        ),
        Positioned.fill(
          child: PlatformViewLink(
            viewType: viewType,
            onCreatePlatformView: _createController,
            surfaceFactory:
                (BuildContext context, PlatformViewController controller) {
              return PlatformViewSurface(
                controller: controller,
                gestureRecognizers:
                    Set<Factory<OneSequenceGestureRecognizer>>(),
                hitTestBehavior: PlatformViewHitTestBehavior.transparent,
              );
            },
          ),
        ),
      ],
    );
  }

  _LinkViewController _createController(PlatformViewCreationParams params) {
    _controller = _LinkViewController(params.id);
    _controller._initialize().then((_) {
      params.onPlatformViewCreated(params.id);
    });
    return _controller
      .._setUri(widget.link.uri)
      .._setTarget(widget.link.target);
  }
}

/// Controls link views.
class _LinkViewController extends PlatformViewController {
  _LinkViewController(this.viewId) {
    if (_instances.isEmpty) {
      // This is the first controller being created, attach the global click
      // listener.
      _clickSubscribtion = html.window.onClick.listen(_onGlobalClick);
    }
    _instances[viewId] = this;
  }

  static Map<int, _LinkViewController> _instances =
      <int, _LinkViewController>{};

  static html.Element _viewFactory(int viewId) {
    return _instances[viewId]?._element;
  }

  static int _hitTestedViewId;
  static _ClickListener _hitTestedClickCallback;

  static StreamSubscription _clickSubscribtion;

  static void _onGlobalClick(html.MouseEvent event) {
    final int viewId = _getViewIdFromTarget(event);
    _instances[viewId]?._onDomClick(event);
    // After the DOM click event has been received, clean up the hit test state
    // so we can start fresh on the next click.
    _unregisterHitTest();
  }

  /// Call this method to indicated that a hit test has been registered for the
  /// given [controller].
  ///
  /// The [onClick] callback is invoked when the anchor element receives a
  /// `click` from the browser.
  static void _registerHitTest(
    _LinkViewController controller, {
    @required _ClickListener onClick,
  }) {
    _hitTestedViewId = controller.viewId;
    _hitTestedClickCallback = onClick;
  }

  static void _unregisterHitTest() {
    _hitTestedViewId = null;
    _hitTestedClickCallback = null;
  }

  @override
  final int viewId;

  html.Element _element;
  bool get _isInitialized => _element != null;

  Future<void> _initialize() async {
    _element = html.Element.tag('a');
    setProperty(_element, _viewIdProperty, viewId);
    _element.style
      ..opacity = '0'
      ..display = 'block'
      ..cursor = 'unset';

    final Map<String, dynamic> args = <String, dynamic>{
      'id': viewId,
      'viewType': viewType,
    };
    await SystemChannels.platform_views.invokeMethod<void>('create', args);
  }

  void _onDomClick(html.MouseEvent event) {
    final bool isHitTested = _hitTestedViewId == viewId;
    if (isHitTested) {
      _hitTestedClickCallback(event);
    } else {
      // There was no hit test registered for this click. This means the click
      // landed on the anchor element but not on the underlying widget. In this
      // case, we prevent the browser from following the click.
      event.preventDefault();
    }
  }

  void _setUri(Uri uri) {
    assert(_isInitialized);
    if (uri == null) {
      _element.removeAttribute('href');
    } else {
      _element.setAttribute('href', uri.toString());
    }
  }

  void _setTarget(LinkTarget target) {
    assert(_isInitialized);
    _element.setAttribute('target', _getHtmlTarget(target));
  }

  String _getHtmlTarget(LinkTarget target) {
    switch (target) {
      case LinkTarget.defaultTarget:
      case LinkTarget.self:
        return '_self';
      case LinkTarget.blank:
        return '_blank';
      default:
        throw Exception('Unknown LinkTarget value $target.');
    }
  }

  @override
  Future<void> clearFocus() async {
    // Currently this does nothing on Flutter Web.
    // TODO(het): Implement this. See https://github.com/flutter/flutter/issues/39496
  }

  @override
  Future<void> dispatchPointerEvent(PointerEvent event) async {
    // We do not dispatch pointer events to HTML views because they may contain
    // cross-origin iframes, which only accept user-generated events.
  }

  @override
  Future<void> dispose() async {
    if (_isInitialized) {
      assert(_instances[viewId] == this);
      _instances.remove(viewId);
      if (_instances.isEmpty) {
        await _clickSubscribtion.cancel();
      }
      // Asynchronously dispose this view.
      await SystemChannels.platform_views.invokeMethod<void>('dispose', viewId);
    }
  }
}

int _getViewIdFromTarget(html.Event event) {
  final html.Element linkElement = _getLinkElementFromTarget(event);
  if (linkElement != null) {
    return getProperty(linkElement, _viewIdProperty);
  }
  return null;
}

html.Element _getLinkElementFromTarget(html.Event event) {
  final html.Element target = event.target;
  if (_isLinkElement(target)) {
    return target;
  }
  if (target.shadowRoot != null) {
    final html.Element child = target.shadowRoot.lastChild;
    if (_isLinkElement(child)) {
      return child;
    }
  }
  return null;
}

bool _isLinkElement(html.Element element) {
  return element.tagName == 'A' && hasProperty(element, _viewIdProperty);
}
