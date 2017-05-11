// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import '../firebase_database.dart';
import 'package:flutter/material.dart';

typedef Widget FirebaseAnimatedListItemBuilder(
  BuildContext context,
  DataSnapshot snapshot,
  Animation<double> animation,
);

/// An AnimatedList widget that is bound to a query
class FirebaseAnimatedList extends StatefulWidget {
  /// Creates a scrolling container that animates items when they are inserted or removed.
  FirebaseAnimatedList({
    Key key,
    @required this.query,
    @required this.itemBuilder,
    this.defaultChild,
    this.scrollDirection: Axis.vertical,
    this.reverse: false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap: false,
    this.padding,
    this.duration: const Duration(milliseconds: 300),
  }) : super(key: key) {
    assert(itemBuilder != null);
  }

  /// A Firebase query to use to populate the animated list
  final Query query;

  /// A widget to display while the query is loading. Defaults to an empty
  /// Container().
  final Widget defaultChild;

  /// Called, as needed, to build list item widgets.
  ///
  /// List items are only built when they're scrolled into view.
  ///
  /// The [AnimatedListItemBuilder] index parameter indicates the item's
  /// posiition in the list. The value of the index parameter will be between 0 and
  /// [initialItemCount] plus the total number of items that have been inserted
  /// with [AnimatedListState.insertItem] and less the total number of items
  /// that have been removed with [AnimatedList.removeItem].
  ///
  /// Implementations of this callback should assume that [AnimatedList.removeItem]
  /// removes an item immediately.
  final FirebaseAnimatedListItemBuilder itemBuilder;

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
  FirebaseAnimatedListState createState() => new FirebaseAnimatedListState();
}

class FirebaseAnimatedListState extends State<FirebaseAnimatedList> {
  GlobalKey<AnimatedListState> _animatedListKey = new GlobalKey<AnimatedListState>();
  _ListModel _model;
  bool _dataAvailable = false;

  @override initState() {
    super.initState();
    _model = new _ListModel(
      query: widget.query,
      onValue: _onValue,
      onChildAdded: _onChildAdded,
      onChildRemoved: _onChildRemoved,
    );
  }

  void _onValue() {
    setState(() {
      _dataAvailable = true;
    });
  }

  void _onChildAdded(int index, DataSnapshot snapshot) {
    _animatedListKey.currentState.insertItem(index, duration: widget.duration);
  }

  void _onChildRemoved(int index, DataSnapshot snapshot) {
    _animatedListKey.currentState.removeItem(
      index,
      (BuildContext context, int index, Animation<double> animation) {
        return new widget.itemBuilder(context, snapshot, animation);
      },
      duration: widget.duration,
    );
  }

  Widget _buildItem(BuildContext context, int index, Animation<double> animation) {
    return widget.itemBuilder(context, _model[index], animation);
  }

  @override
  Widget build(BuildContext context) {
    if (!_dataAvailable)
      return defaultChild ?? new Container();
    return new AnimatedList(
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

  @override void dispose() {
    _model.dispose();
    super.dispose();
  }
}

typedef void _ChildCallback(int index, DataSnapshot snapshot);

// Wrapper around an array that is bound to a query that notifies on changes.
// TODO(jackson): Refactor this into a public class supporting more use cases.
class _ListModel {
  _ListModel({
    @required this.query,
    @required VoidCallback this.onValue,
    @required _ChildCallback this.onChildAdded,
    @required _ChildCallback this.onChildRemoved,
  }) {
    _subscriptions = [
      query.onChildAdded.listen(_onChildAdded),
      // TODO(jackson): Add support for more types of data events
      //      query.onChildRemoved.listen(_onChildRemoved),
      //      query.onValue.listen(_onValue),
    ];
    // For now, pretend all the data is loaded immediately.
    onValue();
  }

  final Query query;
  final VoidCallback onValue;
  final _ChildCallback onChildAdded;
  final _ChildCallback onChildRemoved;

  final List<DataSnapshot> _items = <DataSnapshot>[];
  List<StreamSubscription<Event>> _subscriptions;

  // TODO(jackson): Find the correct position in the array to insert into
  void _onChildAdded(Event event)
  {
    _items.insert(0, event.snapshot);
    onChildAdded(0, event.snapshot);
  }

  int get length => _items.length;
  DataSnapshot operator [](int index) => _items[index];
  int indexOf(DataSnapshot item) => _items.indexOf(item);

  void dispose() {
    assert(_subscriptions != null);
    for (StreamSubscription<Event> subscription in _subscriptions)
      subscription.cancel();
    _subscriptions = null;
  }
}
