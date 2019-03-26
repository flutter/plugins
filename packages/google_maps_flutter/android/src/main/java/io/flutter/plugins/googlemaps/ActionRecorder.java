package io.flutter.plugins.googlemaps;

import androidx.annotation.Nullable;
import java.util.ArrayList;
import java.util.List;

public class ActionRecorder {

  private boolean recordActions = false;
  private final List<String> recordedActions = new ArrayList<>();

  public void startRecordingActions() {
    recordActions = true;
  }

  // TODO need to implement in delegater
  public void stopRecordingActions() {
    recordActions = false;
  }

  public void clearRecordedActions() {
    recordedActions.clear();
  }

  void recordAction(String actionName, @Nullable Object value) {
    if (!recordActions) {
      return;
    }
    StringBuilder sb = new StringBuilder();
    sb.append(actionName);
    if (value != null) {
      sb.append(" ");
      sb.append(value);
    }
    recordedActions.add(sb.toString());
  }

  List<String> getRecordedActions() {
    return recordedActions;
  }

}
