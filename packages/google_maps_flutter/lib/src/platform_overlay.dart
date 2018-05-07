// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

/// Controller of platform overlays used for creating the illusion, in *very
/// limited situations*, of in-line compositing of platform views with Flutter
/// widgets.
///
/// Platform overlays are normal platform views that are displayed on top of the
/// Flutter view when so directed by the Flutter app's Dart code. The platform
/// overlay is placed on top of a [Texture] widget acting as a non-interactive
/// stand in while the conditions for correctly displaying the overlay are not
/// met. Those conditions are:
///
/// * the widget must be stationary
/// * the widget must be rendered on top of all other widgets within bounds
/// * touch events originating within the widget's bounds can be safely ignored
///   by Flutter code (they will be intercepted by the platform overlay)
///
/// These conditions severely restrict the contexts in which platform overlays
/// can be used. Worse, there is no easy way of learning if a given widget
/// currently satisfies those conditions, so they must be explicitly enforced
/// by the app author. Examples include avoiding placing the widget on a
/// scrollable view; hiding the overlay during animated transitions or while a
/// drawer is being shown on top; avoiding placing the widget at the edge of
/// the screen where the platform view would interfere with edge swipes; etc.
/// The app author should expect little help from existing widgets in this
/// endeavor; some widgets (Material Scaffold being a prime example) do not
/// offer to notify clients before and after they display Flutter overlays or
/// animate to new configurations. Using platform overlays may require custom
/// implementations of such widgets.
///
/// *Warning*: Platform overlays cannot be freely composed with other widgets.
///
/// For the above reasons, *the use of platform overlays is generally
/// discouraged*. Still, overlays provide an interim solution in situations
/// where one wants to create the illusion of in-line compositing of native
/// platform views (such as GoogleMaps) for which no API exists for connecting a
/// Texture widget directly to the native OpenGL rendering pipeline.
///
/// Overlays may be attached to the [BuildContext] in which the Texture widget
/// is built and are then automatically hidden when the ambient ModalRoute (if
/// any) is not on top of the navigator stack. This is currently the *only*
/// built-in mechanism for helping the app author ensure that the overlay
/// conditions mentioned above are met. Making use of this mechanism requires
/// the overlay controller to be added as an observer of the main Navigator.
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
        _overlayIdCompleter.complete(overlay.create(new Size(width, height)));
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
          offset = object.localToGlobal(Offset.zero);
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

/// Interface of platform overlay implementations. Typical implementation use
/// a [MethodChannel] to communicate with platform-specific code and have it
/// manage a collection of related platform overlays.
abstract class PlatformOverlay {
  /// Creates a platform view of the specified [size].
  ///
  /// The platform view should remain hidden until explicitly shown by calling
  /// [show].
  Future<int> create(Size size);

  /// Shows the platform view at the specified [offset].
  Future<void> show(Offset offset);

  /// Hides the platform view.
  Future<void> hide();

  /// Disposes of the platform view.
  Future<void> dispose();
}
