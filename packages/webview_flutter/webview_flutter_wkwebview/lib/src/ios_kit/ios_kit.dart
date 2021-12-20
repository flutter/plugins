// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import '../foundation/foundation.dart';

/// An object that manages the content for a rectangular area on the screen.
///
/// Views are the fundamental building blocks of your app's user interface, and
/// the [IosView] class defines the behaviors that are common to all views. A
/// view object renders content within its bounds rectangle, and handles any
/// interactions with that content. The [IosView] class is a concrete class that
/// you can instantiate and use to display a fixed background color. You can
/// also subclass it to draw more sophisticated content. To display labels,
/// images, buttons, and other interface elements commonly found in apps, use
/// the view subclasses that the UIKit framework provides rather than trying to
/// define your own.
class IosView extends FoundationObject {
  /// The view’s background color.
  ///
  /// The default value is nil, which results in a transparent background color.
  set backgroundColor(Color color) {
    throw UnimplementedError();
  }

  /// Determines whether the view is opaque.
  ///
  /// This property provides a hint to the drawing system as to how it should
  /// treat the view. If set to true, the drawing system treats the view as
  /// fully opaque, which allows the drawing system to optimize some drawing
  /// operations and improve performance. If set to false, the drawing system
  /// composites the view normally with other content. The default value of this
  /// property is true.
  ///
  /// An opaque view is expected to fill its bounds with entirely opaque
  /// content—that is, the content should have an alpha value of 1.0. If the
  /// view is opaque and either does not fill its bounds or contains wholly o
  /// r partially transparent content, the results are unpredictable. You should
  /// always set the value of this property to false if the view is fully or
  /// partially transparent.
  set opaque(bool opaque) {
    throw UnimplementedError();
  }
}

/// A view that allows the scrolling and zooming of its contained views.
class ScrollView extends IosView {
  /// Point at which the origin of the content view is offset from the origin of the scroll view.
  Future<Point<double>> get contentOffset {
    throw UnimplementedError();
  }

  /// Set point at which the origin of the content view is offset from the origin of the scroll view.
  ///
  /// The default value is `Point<double>(0.0, 0.0)`.
  set contentOffset(FutureOr<Point<double>> offset) {
    throw UnimplementedError();
  }
}
