package io.flutter.embedding.engine.plugins;

import android.arch.lifecycle.Lifecycle;
import android.support.annotation.NonNull;

public class FlutterLifecycleAdapter {
  @NonNull
  private final Lifecycle lifecycle;

  public FlutterLifecycleAdapter(@NonNull LifecycleReference reference) {
    if (!(reference instanceof ConcreteLifecycleReference)) {
      throw new IllegalArgumentException("The reference argument must be of type ConcreteLifecycleReference. Was actually " + reference);
    }

    this.lifecycle = ((ConcreteLifecycleReference) reference).getLifecycle();
  }

  @NonNull
  public Lifecycle getLifecycle() {
    return lifecycle;
  }
}
