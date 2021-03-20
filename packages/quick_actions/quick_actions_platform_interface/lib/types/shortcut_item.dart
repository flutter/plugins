// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Home screen quick-action shortcut item.
class ShortcutItem {
  /// Constructs an instance with the given [type], [localizedTitle], and
  /// [icon].
  ///
  /// Only [icon] should be nullable. It will remain `null` if unset.
  const ShortcutItem({
    required this.type,
    required this.localizedTitle,
    this.icon,
  });

  /// The identifier of this item; should be unique within the app.
  final String type;

  /// Localized title of the item.
  final String localizedTitle;

  /// Name of native resource (xcassets etc; NOT a Flutter asset) to be
  /// displayed as the icon for this item.
  final String? icon;
}
