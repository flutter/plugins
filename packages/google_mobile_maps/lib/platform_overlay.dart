// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:meta/meta.dart';

/// Base class for controllers of platform overlays.
///
/// Platform overlays are normal platform-specific views that are
/// created, shown on top of the Flutter view, or hidden below it,
/// under control of the Flutter app. The platform overlay is
/// typically placed on top of a [Texture] widget acting as stand-in
/// while Flutter movement or transformations are ongoing.
///
/// Overlays are attached to a [BuildContext] when used in a Widget and
/// are deactivated when the ambient ModalRoute (if any) is not on top of the
/// navigator stack.
///
/// *Warning*: Platform overlays cannot be freely composed with
/// over widgets.
///
/// Limitations and caveats:
///
/// * TODO(mravn)
abstract class PlatformOverlayController extends NavigatorObserver
    with WidgetsBindingObserver {
  final double width;
  final double height;
  final Completer<int> _overlayIdCompleter = new Completer<int>();
  BuildContext _context;
  Route<dynamic> _currentRoute;
  Route<dynamic> _previousRoute;
  Route<dynamic> _routeWithOverlay;
  int _activationCount = 0;
  bool _deactivatedByPush = false;
  bool _disposed = false;

  PlatformOverlayController(this.width, this.height);

  void attachTo(BuildContext context) {
    _context = context;
    _routeWithOverlay = _currentRoute;
    _activateOverlayAfterPushAnimations(_routeWithOverlay, _previousRoute);
    WidgetsBinding.instance.addObserver(this);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_disposed) {
        return;
      }
      if (!_overlayIdCompleter.isCompleted) {
        _overlayIdCompleter.complete(
            createOverlay(new Size(width, height) * window.devicePixelRatio));
      }
    });
  }

  void detach() {
    WidgetsBinding.instance.removeObserver(this);
  }

  /// Allow activating the overlay, unless there are other pending calls to
  /// [deactivateOverlay].
  void activateOverlay() {
    _activationCount += 1;
    if (_activationCount == 1) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (_disposed) {
          return;
        }
        final RenderObject object = _context?.findRenderObject();
        Offset offset;
        if (object is RenderBox) {
          offset = object.localToGlobal(Offset.zero) * window.devicePixelRatio;
        } else {
          offset = Offset.zero;
        }
        showOverlay(offset);
      });
    }
  }

  /// Prevent activating the overlay until a matching call to [activateOverlay].
  void deactivateOverlay() {
    _activationCount -= 1;
    if (_activationCount == 0) {
      hideOverlay();
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    _currentRoute = route;
    _previousRoute = previousRoute;
    if (previousRoute != null && identical(previousRoute, _routeWithOverlay)) {
      deactivateOverlay();
      _deactivatedByPush = true;
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    _currentRoute = previousRoute;
    _previousRoute = route;
    if (identical(route, _routeWithOverlay)) {
      deactivateOverlay();
    } else if (identical(previousRoute, _routeWithOverlay) &&
        _deactivatedByPush) {
      _activateOverlayAfterPopAnimations(route, previousRoute);
    }
  }

  void _activateOverlayAfterPopAnimations(
      Route<dynamic> route, Route<dynamic> previousRoute) {
    if (route is ModalRoute && previousRoute is ModalRoute) {
      _doOnceAfter(route.animation, () {
        _doOnceAfter(previousRoute.secondaryAnimation, () {
          activateOverlay();
          _deactivatedByPush = false;
        });
      });
    } else if (route is ModalRoute) {
      _doOnceAfter(route.animation, () {
        activateOverlay();
        _deactivatedByPush = false;
      });
    } else if (previousRoute is ModalRoute) {
      _doOnceAfter(previousRoute.secondaryAnimation, () {
        activateOverlay();
        _deactivatedByPush = false;
      });
    }
  }

  void _activateOverlayAfterPushAnimations(
      Route<dynamic> route, Route<dynamic> previousRoute) {
    if (route is ModalRoute && previousRoute is ModalRoute) {
      _doOnceAfter(route.animation, () {
        _doOnceAfter(previousRoute.secondaryAnimation, () {
          activateOverlay();
        });
      });
    } else if (route is ModalRoute) {
      _doOnceAfter(route.animation, () {
        activateOverlay();
      });
    } else if (previousRoute is ModalRoute) {
      _doOnceAfter(previousRoute.secondaryAnimation, () {
        activateOverlay();
      });
    }
  }

  void _doOnceAfter(Animation<dynamic> animation, void onDone()) {
    void listener() {
      if (animation.status != AnimationStatus.forward &&
          animation.status != AnimationStatus.reverse) {
        animation.removeListener(listener);
        onDone();
      }
    }

    if (animation.status != AnimationStatus.completed &&
        animation.status != AnimationStatus.dismissed) {
      animation.addListener(listener);
    } else {
      onDone();
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
    // TODO(mravn)
  }

  void dispose() {
    if (!_disposed) {
      disposeOverlay();
      _disposed = true;
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    deactivateOverlay();
    activateOverlay();
  }

  /// Subclasses implement this method to create a platform view of the
  /// specified [physicalSize] (in device pixels).
  ///
  /// The view should remain hidden.
  @protected
  Future<int> createOverlay(Size physicalSize);

  /// Subclasses implement this method to display the platform view at the
  /// specified [physicalOffset] (in device pixels).
  @protected
  Future<void> showOverlay(Offset physicalOffset);

  /// Subclasses implement this method to hide the platform view.
  @protected
  Future<void> hideOverlay();

  /// Subclasses implement this method to dispose of the platform view.
  Future<void> disposeOverlay();
}
