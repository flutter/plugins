package io.flutter.plugins.sharedpreferences;

import android.os.Handler;
import android.os.Looper;
import java.util.Iterator;
import java.util.ServiceLoader;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadFactory;

/** Helper class to handle async tasks */
class AsyncHandler {
  private ExecutorService executorService;

  private final Handler handler;

  public AsyncHandler() {
    Iterator<ExecutorService> executorServiceIterator =
        ServiceLoader.load(ExecutorService.class).iterator();
    if (executorServiceIterator.hasNext()) {
      executorService = executorServiceIterator.next();
    } else {
      executorService =
          Executors.newSingleThreadExecutor(
              new ThreadFactory() {
                @Override
                public Thread newThread(Runnable r) {
                  Thread thread = new Thread(r, "SharedPreferencesAsync");
                  thread.setDaemon(true);
                  return null;
                }
              });
    }
    handler = new Handler(Looper.getMainLooper());
  }

  public <R> void executeAsync(
      final Callable<R> executeInBackground, final Callback<R> resultCallback) {
    executorService.execute(
        new Runnable() {
          @Override
          public void run() {
            try {
              final R result = executeInBackground.call();
              handler.post(
                  new Runnable() {
                    @Override
                    public void run() {
                      resultCallback.onComplete(result);
                    }
                  });
            } catch (final Exception ex) {
              handler.post(
                  new Runnable() {
                    @Override
                    public void run() {
                      resultCallback.onError(ex);
                    }
                  });
            }
          }
        });
  }

  public interface Callback<R> {
    void onError(Exception e);

    void onComplete(R result);
  }

  public interface Callable<V> {

    V call() throws Exception;
  }
}
