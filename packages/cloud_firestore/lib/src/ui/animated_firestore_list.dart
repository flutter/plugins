// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../cloud_firestore.dart';
import 'firestore_list.dart';

typedef Widget FirestoreAnimatedListItemBuilder(
  BuildContext context,
  DocumentSnapshot snapshot,
  Animation<double> animation,
  int index,
);

/// An AnimatedList widget that is bound to a query
class FirestoreAnimatedList extends StatefulWidget {
  /// Creates a scrolling container that animates items when they are inserted or removed.
  FirestoreAnimatedList({
    Key key,
    @required this.query,
    @required this.itemBuilder,
    this.defaultChild,
    this.errorChild,
    this.emptyChild,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key) {
    assert(itemBuilder != null);
  }

  /// A Firestore query to use to populate the animated list
  final Stream<QuerySnapshot> query;

  /// A widget to display while the query is loading. Defaults to a
  /// centered [CircularProgressIndicator];
  final Widget defaultChild;

  /// A widget to display if an error ocurred. Defaults to a
  /// centered [Column] with `Icons.error` and the error itsef;
  final Widget errorChild;

  /// A widget to display if the query returns empty. Defaults to a
  /// `Container()`;
  final Widget emptyChild;

  /// Called, as needed, to build list item widgets.
  ///
  /// List items are only built when they're scrolled into view.
  ///
  /// The [DocumentSnapshot] parameter indicates the snapshot that should be used
  /// to build the item.
  ///
  /// Implementations of this callback should assume that [AnimatedList.removeItem]
  /// removes an item immediately.
  final FirestoreAnimatedListItemBuilder itemBuilder;

  /// The axis along which the scroll view scrolls.
  ///
  /// Defaults to [Axis.vertical].
  final Axis scrollDirection;

  /// Whether the scroll view scrolls in the reading direction.
  ///
  /// For example, if the reading direction is left-to-right and
  /// [scrollDirection] is [Axis.horizontal], then the scroll view scrolls from
  /// left to right when [reverse] is false and from right to left when
  /// [reverse] is true.
  ///
  /// Similarly, if [scrollDirection] is [Axis.vertical], then the scroll view
  /// scrolls from top to bottom when [reverse] is false and from bottom to top
  /// when [reverse] is true.
  ///
  /// Defaults to false.
  final bool reverse;

  /// An object that can be used to control the position to which this scroll
  /// view is scrolled.
  ///
  /// Must be null if [primary] is true.
  final ScrollController controller;

  /// Whether this is the primary scroll view associated with the parent
  /// [PrimaryScrollController].
  ///
  /// On iOS, this identifies the scroll view that will scroll to top in
  /// response to a tap in the status bar.
  ///
  /// Defaults to true when [scrollDirection] is [Axis.vertical] and
  /// [controller] is null.
  final bool primary;

  /// How the scroll view should respond to user input.
  ///
  /// For example, determines how the scroll view continues to animate after the
  /// user stops dragging the scroll view.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics physics;

  /// Whether the extent of the scroll view in the [scrollDirection] should be
  /// determined by the contents being viewed.
  ///
  /// If the scroll view does not shrink wrap, then the scroll view will expand
  /// to the maximum allowed size in the [scrollDirection]. If the scroll view
  /// has unbounded constraints in the [scrollDirection], then [shrinkWrap] must
  /// be true.
  ///
  /// Shrink wrapping the content of the scroll view is significantly more
  /// expensive than expanding to the maximum allowed size because the content
  /// can expand and contract during scrolling, which means the size of the
  /// scroll view needs to be recomputed whenever the scroll position changes.
  ///
  /// Defaults to false.
  final bool shrinkWrap;

  /// The amount of space by which to inset the children.
  final EdgeInsets padding;

  /// The duration of the insert and remove animation.
  ///
  /// Defaults to const Duration(milliseconds: 300).
  final Duration duration;

  @override
  FirestoreAnimatedListState createState() => FirestoreAnimatedListState();
}

class FirestoreAnimatedListState extends State<FirestoreAnimatedList> {
  final GlobalKey<AnimatedListState> _animatedListKey =
      GlobalKey<AnimatedListState>();
  FirestoreList _model;
  String _error;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    _model = FirestoreList(
      query: widget.query,
      onDocumentAdded: _onDocumentAdded,
      onDocumentRemoved: _onDocumentRemoved,
      onDocumentChanged: _onDocumentChanged,
      onValue: _onValue,
      onError: _onError,
      debug: true,
    );
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // Cancel the Firebase stream subscriptions
    _model.clear();
    super.dispose();
  }

  void _onError(Error error) {
    if (mounted) {
      setState(() {
        error = error;
      });
    }
  }

  void _onDocumentAdded(int index, DocumentSnapshot snapshot) {
    if (!_loaded) {
      return; // AnimatedList is not created yet
    }
    if (mounted) {
      _animatedListKey.currentState
          .insertItem(index, duration: widget.duration);
    }
  }

  void _onDocumentRemoved(int index, DocumentSnapshot snapshot) {
    // The child should have already been removed from the model by now
    assert(!_model.contains(snapshot));
    if (mounted) {
      try {
        _animatedListKey.currentState.removeItem(
          index,
          (BuildContext context, Animation<double> animation) {
            return widget.itemBuilder(context, snapshot, animation, index);
          },
          duration: widget.duration,
        );
        setState(() {});
      } catch (error) {
        _model.log("Failed to remove Widget on index $index");
      }
    }
  }

  // No animation, just update contents
  void _onDocumentChanged(int index, DocumentSnapshot snapshot) {
    if (mounted) {
      setState(() {});
    }
  }

  void _onValue(DocumentSnapshot _) {
    if (mounted) {
      setState(() {
        _loaded = true;
      });
    }
  }

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return widget.itemBuilder(context, _model[index], animation, index);
  }

  @override
  Widget build(BuildContext context) {
    if (_model == null || _model.isEmpty) {
      return widget.emptyChild ?? Container();
    }

    if (!_loaded) {
      return widget.defaultChild ??
          const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _error.isNotEmpty) {
      return widget.errorChild ??
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.error),
                Text(_error),
              ],
            ),
          );
    }

    return AnimatedList(
      key: _animatedListKey,
      itemBuilder: _buildItem,
      initialItemCount: _model.length,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.controller,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
    );
  }
}
