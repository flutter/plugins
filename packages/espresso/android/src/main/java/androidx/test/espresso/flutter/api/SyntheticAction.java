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
