// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.quickactionsexample;

import android.content.pm.ShortcutInfo;
import java.util.Objects;

class Shortcut {
  final String type;
  final String shortLabel;
  final String longLabel;
  String icon;

  public Shortcut(ShortcutInfo shortcutInfo) {
    this.type = shortcutInfo.getId();
    this.shortLabel = shortcutInfo.getShortLabel().toString();
    this.longLabel = shortcutInfo.getLongLabel().toString();
  }

  public Shortcut(String type, String shortLabel, String longLabel) {
    this.type = type;
    this.shortLabel = shortLabel;
    this.longLabel = longLabel;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;

    Shortcut shortcut = (Shortcut) o;

    if (!type.equals(shortcut.type)) return false;
    if (!shortLabel.equals(shortcut.shortLabel)) return false;
    if (!longLabel.equals(shortcut.longLabel)) return false;
    return Objects.equals(icon, shortcut.icon);
  }

  @Override
  public int hashCode() {
    int result = type.hashCode();
    result = 31 * result + shortLabel.hashCode();
    result = 31 * result + longLabel.hashCode();
    result = 31 * result + (icon != null ? icon.hashCode() : 0);
    return result;
  }
}
