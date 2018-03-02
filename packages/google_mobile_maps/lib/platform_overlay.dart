import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:meta/meta.dart';

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

  @protected
  Future<int> createOverlay(Size physicalSize);

  @protected
  Future<void> showOverlay(Offset physicalOffset);

  @protected
  Future<void> hideOverlay();

  Future<void> disposeOverlay();
}
