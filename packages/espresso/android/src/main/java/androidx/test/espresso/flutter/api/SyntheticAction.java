// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.api;

import static androidx.test.espresso.flutter.common.Constants.DEFAULT_INTERACTION_TIMEOUT;
import static com.google.common.base.Preconditions.checkNotNull;

import com.google.common.annotations.Beta;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;
import java.util.Objects;
import javax.annotation.Nonnull;

/**
 * Base Flutter synthetic action.
 *
 * <p>A synthetic action is not a real gesture event issued to the Android system, rather it's an
 * action that's performed via Flutter engine. It's supposed to be used for complex interactions or
 * those that are brittle if performed through Android system. Most of the actions should be
 * associated with a {@link WidgetMatcher}, but some may not, e.g. an action that checks the
 * rendering status of the entire {@link io.flutter.view.FlutterView}.
 */
@Beta
public abstract class SyntheticAction {

  @Expose
  @SerializedName("command")
  protected String actionId;

  @Expose
  @SerializedName("timeout")
  protected long timeOutInMillis;

  protected SyntheticAction(@Nonnull String actionId) {
    this(actionId, DEFAULT_INTERACTION_TIMEOUT.toMillis());
  }

  protected SyntheticAction(@Nonnull String actionId, long timeOutInMillis) {
    this.actionId = checkNotNull(actionId);
    this.timeOutInMillis = timeOutInMillis;
  }

  @Override
  public String toString() {
    return actionId;
  }

  @Override
  public boolean equals(Object obj) {
    if (obj == null) {
      return false;
    } else if (obj instanceof SyntheticAction) {
      SyntheticAction otherAction = (SyntheticAction) obj;
      return Objects.equals(actionId, otherAction.actionId);
    } else {
      return false;
    }
  }

  @Override
  public int hashCode() {
    return Objects.hashCode(actionId);
  }
}
