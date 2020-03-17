// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.action;

import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.base.Preconditions.checkState;

import android.os.Looper;
import androidx.test.espresso.IdlingRegistry;
import androidx.test.espresso.IdlingResource;
import androidx.test.espresso.UiController;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Future;
import java.util.concurrent.FutureTask;

/** Utils for the Flutter actions. */
final class ActionUtil {

  /**
   * Loops the main thread until the given future task has been done. Users could use this method to
   * "synchronize" between the main thread and {@code Future} instances running on its own thread
   * (e.g. methods of the {@code FlutterTestingProtocol}), without blocking the main thread.
   *
   * <p>Usage:
   *
   * <pre>{@code
   * Future<T> fooFuture = flutterTestingProtocol.callFoo();
   * T fooResult = loopUntilCompletion("fooTask", androidUiController, fooFuture, executor);
   * // Then consumes the fooResult on main thread.
   * }</pre>
   *
   * @param taskName the name that shall be used when registering the task as an {@link
   *     IdlingResource}. Espresso ignores {@link IdlingResource} with the same name, so always uses
   *     a unique name if you don't want Espresso to ignore your task.
   * @param androidUiController the controller to use to interact with the Android UI.
   * @param futureTask the future task that main thread should wait for a completion signal.
   * @param executor the executor to use for running async tasks within the method.
   * @param <T> the return value type.
   * @return the result of the future task.
   * @throws ExecutionException if any error occurs during executing the future task.
   * @throws InterruptedException when any internal thread is interrupted.
   */
  public static <T> T loopUntilCompletion(
      String taskName,
      UiController androidUiController,
      Future<T> futureTask,
      ExecutorService executor)
      throws ExecutionException, InterruptedException {

    checkState(Looper.myLooper() == Looper.getMainLooper(), "Expecting to be on main thread!");

    FutureIdlingResource<T> idlingResourceFuture = new FutureIdlingResource<>(taskName, futureTask);
    IdlingRegistry.getInstance().register(idlingResourceFuture);
    try {
      // It's fine to ignore this {@code Future} handler, since {@code idlingResourceFuture} should
      // give us the result/error any way.
      @SuppressWarnings("unused")
      Future<?> possiblyIgnoredError = executor.submit(idlingResourceFuture);
      androidUiController.loopMainThreadUntilIdle();
      checkState(idlingResourceFuture.isDone(), "Future task signaled - but it wasn't done.");
      return idlingResourceFuture.get();
    } finally {
      IdlingRegistry.getInstance().unregister(idlingResourceFuture);
    }
  }

  /**
   * An {@code IdlingResource} implementation that takes in a {@code Future}, and sends the idle
   * signal to the main thread when the given {@code Future} is done.
   *
   * @param <T> the return value type of this {@code FutureTask}.
   */
  private static class FutureIdlingResource<T> extends FutureTask<T> implements IdlingResource {

    private final String taskName;
    // Written from main thread, read from any thread.
    private volatile ResourceCallback resourceCallback;

    public FutureIdlingResource(String taskName, final Future<T> future) {
      super(
          new Callable<T>() {
            @Override
            public T call() throws Exception {
              return future.get();
            }
          });
      this.taskName = checkNotNull(taskName);
    }

    @Override
    public String getName() {
      return taskName;
    }

    @Override
    public void done() {
      resourceCallback.onTransitionToIdle();
    }

    @Override
    public boolean isIdleNow() {
      return isDone();
    }

    @Override
    public void registerIdleTransitionCallback(ResourceCallback callback) {
      this.resourceCallback = callback;
    }
  }
}
