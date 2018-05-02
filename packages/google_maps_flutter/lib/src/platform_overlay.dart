// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

/// Controller of platform overlays, supporting a very limited form
/// of compositing with Flutter Widgets.
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
class PlatformOverlayController extends NavigatorObserver
    with WidgetsBindingObserver {
  final double width;
  final double height;
  final PlatformOverlay overlay;
  final Completer<int> _overlayIdCompleter = new Completer<int>();
  BuildContext _context;

  // Current route as observed via NavigatorObserver calls.
  Route<dynamic> _currentRoute;

  // Previous route as observed via NavigatorObserver calls.
  Route<dynamic> _previousRoute;

  // Current route at the most recent time [attachTo] was called.
  Route<dynamic> _routeWithOverlay;

  // Number of calls to [activateOverlay] minus number of calls to
  // [deactivateOverlay].
  int _activationCount = 0;

  // True if [deactivateOverlay] has been called due to another route
  // having been pushed atop [_routeWithOverlay].
  bool _deactivatedByPush = false;

  // True if [dispose] has been called.
  bool _disposed = false;

  PlatformOverlayController(this.width, this.height, this.overlay);

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
            overlay.create(new Size(width, height) * window.devicePixelRatio));
      }
    });
  }

  void detach() {
    WidgetsBinding.instance.removeObserver(this);
    _context = null;
    _routeWithOverlay = null;
  }

  /// Allow activating the overlay, unless there are other pending calls to
  /// [deactivateOverlay].
  void activateOverlay() {
    assert(_activationCount <= 0);
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
        overlay.show(offset);
      });
    }
  }

  /// Prevent activating the overlay until a matching call to [activateOverlay].
  void deactivateOverlay() {
    _activationCount -= 1;
    if (_activationCount == 0) {
      overlay.hide();
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
      if (animation.status == AnimationStatus.completed ||
          animation.status == AnimationStatus.dismissed) {
        animation.removeListener(listener);
        onDone();
      }
    }

    if (animation.status == AnimationStatus.forward ||
        animation.status == AnimationStatus.reverse) {
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
      overlay.dispose();
      _disposed = true;
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    deactivateOverlay();
    activateOverlay();
  }
}

/// Platform overlay.
abstract class PlatformOverlay {
  /// Creates a platform view of the specified [physicalSize] (in device pixels).
  ///
  /// The platform view should remain hidden until explicitly shown by calling
  /// [showOverlay].
  Future<int> create(Size physicalSize);

  /// Shows the platform view at the specified [physicalOffset] (in device
  /// pixels).
  Future<void> show(Offset physicalOffset);

  /// Hides the platform view.
  Future<void> hide();

  /// Disposes of the platform view.
  Future<void> dispose();
}
