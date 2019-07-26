import 'package:flutter/cupertino.dart';

typedef ShouldSwipePopCallback = bool Function();

class CustomPageRoute<T> extends CupertinoPageRoute<T> {
  CustomPageRoute({
    @required WidgetBuilder builder,
    RouteSettings settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
            builder: builder,
            settings: settings,
            maintainState: maintainState,
            fullscreenDialog: fullscreenDialog);

  final List<ShouldSwipePopCallback> _shouldSwipePopCallbacks =
      <ShouldSwipePopCallback>[];

  void addShouldSwipePopCallback(ShouldSwipePopCallback callback) {
    _shouldSwipePopCallbacks.add(callback);
  }

  void removeShouldSwipePopCallback(ShouldSwipePopCallback callback) {
    _shouldSwipePopCallbacks.remove(callback);
  }

  @protected
  bool get hasScopedWillPopCallback {
    for (final callback
        in List<ShouldSwipePopCallback>.from(_shouldSwipePopCallbacks)) {
      if (!callback()) return true;
    }
    return false;
  }
}
