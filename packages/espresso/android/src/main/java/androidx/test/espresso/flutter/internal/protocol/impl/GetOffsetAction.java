// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.internal.protocol.impl;

import static com.google.common.base.Preconditions.checkNotNull;

import androidx.test.espresso.flutter.api.SyntheticAction;
import com.google.common.base.Ascii;
import com.google.gson.annotations.Expose;

/** An action that retrieves the widget offset coordinates to the outer Flutter view. */
final class GetOffsetAction extends SyntheticAction {

  /** The position of the offset coordinates. */
  public enum OffsetType {
    TOP_LEFT("topLeft"),
    TOP_RIGHT("topRight"),
    BOTTOM_LEFT("bottomLeft"),
    BOTTOM_RIGHT("bottomRight");

    private OffsetType(String type) {
      this.type = type;
    }

    private final String type;

    @Override
    public String toString() {
      return type;
    }

    public static OffsetType fromString(String typeString) {
      if (typeString == null) {
        return null;
      }
      for (OffsetType offsetType : OffsetType.values()) {
        if (Ascii.equalsIgnoreCase(offsetType.type, typeString)) {
          return offsetType;
        }
      }
      return null;
    }
  }

  @Expose private final String offsetType;

  /**
   * Constructor.
   *
   * @param type the vertex position.
   */
  public GetOffsetAction(OffsetType type) {
    super("get_offset");
    this.offsetType = checkNotNull(type).toString();
  }

  /**
   * Constructor.
   *
   * @param type the vertex position.
   * @param timeOutInMillis action's timeout setting in milliseconds.
   */
  public GetOffsetAction(OffsetType type, long timeOutInMillis) {
    super("get_offset", timeOutInMillis);
    this.offsetType = checkNotNull(type).toString();
  }
}
