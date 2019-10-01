package io.flutter.embedding.engine.plugins.lifecycle;

import android.arch.lifecycle.Lifecycle;
import android.support.annotation.NonNull;

public class FlutterLifecycleAdapter {
  @NonNull
  private final Lifecycle lifecycle;

  public FlutterLifecycleAdapter(@NonNull Object reference) {
    if (!(reference instanceof HiddenLifecycleReference)) {
      throw new IllegalArgumentException("The reference argument must be of type HiddenLifecycleReference. Was actually " + reference);
    }

    this.lifecycle = ((HiddenLifecycleReference) reference).getLifecycle();
  }

  @NonNull
  public Lifecycle getLifecycle() {
    return lifecycle;
  }
}
