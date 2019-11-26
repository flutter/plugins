/*
 * Copyright (C) 2019 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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
