package io.flutter.plugins.webviewflutter;

import static android.content.Context.INPUT_METHOD_SERVICE;

import android.content.Context;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.webkit.WebView;

/**
 * A WebView subclass that mirrors the same implementation hacks that the system WebView does in
 * order to correctly create an InputConnection.
 *
 * <p>These hacks are only needed in Android versions below N and exist to create an InputConnection
 * on the WebView's dedicated input, or IME, thread. The majority of this proxying logic is in
 * {@link #checkInputConnectionProxy}.
 *
 * <p>See also {@link ThreadedInputConnectionProxyAdapterView}.
 */
final class InputAwareWebView extends WebView {
  private final View containerView;

  private View threadedInputConnectionProxyView;
  private ThreadedInputConnectionProxyAdapterView proxyAdapterView;

  InputAwareWebView(Context context, View containerView) {
    super(context);
    this.containerView = containerView;
  }

  /**
   * Set our proxy adapter view to use its cached input connection instead of creating new ones.
   *
   * <p>This is used to avoid losing our input connection when the virtual display is resized.
   */
  void lockInputConnection() {
    if (proxyAdapterView == null) {
      return;
    }

    proxyAdapterView.setLocked(true);
  }

  /** Sets the proxy adapter view back to its default behavior. */
  void unlockInputConnection() {
    if (proxyAdapterView != null) {
      proxyAdapterView.setLocked(false);
    }

    // Restart the input connection to avoid ViewRootImpl assuming an incorrect window state.
    InputMethodManager imm =
        (InputMethodManager) containerView.getContext().getSystemService(INPUT_METHOD_SERVICE);
    imm.restartInput(containerView);
  }

  /**
   * Creates an InputConnection from the IME thread when needed.
   *
   * <p>We only need to create a {@link ThreadedInputConnectionProxy} and create an
   * InputConnectionProxy on the IME thread when WebView is doing the same thing. So we rely on the
   * system calling this method for WebView's proxy view in order to know when we need to create our
   * own.
   *
   * <p>This method would normally be called for any View that used the InputMethodManager. We rely
   * on flutter/engine filtering the calls we receive down to the ones in our hierarchy and the
   * system WebView in order to know whether or not the system WebView expects an InputConnection on
   * the IME thread.
   */
  @Override
  public boolean checkInputConnectionProxy(final View view) {
    // Check to see if the view param is WebView's ThreadedInputConnectionProxyView.
    View previousProxy = threadedInputConnectionProxyView;
    threadedInputConnectionProxyView = view;
    if (previousProxy == view) {
      // This isn't a new ThreadedInputConnectionProxyView. Ignore it.
      return super.checkInputConnectionProxy(view);
    }

    // We've never seen this before, so we make the assumption that this is WebView's
    // ThreadedInputConnectionProxyView. We are making the assumption that the only view that could
    // possibly be interacting the the IMM here is WebView's ThreadedInputConnectionProxyView.
    proxyAdapterView =
        new ThreadedInputConnectionProxyAdapterView(
            /*containerView=*/ containerView,
            /*targetView=*/ view,
            /*imeHandler=*/ view.getHandler());
    final View container = this;
    proxyAdapterView.requestFocus();
    // This is the crucial trick that gets the InputConnection creation to happen on the correct
    // thread.
    // https://cs.chromium.org/chromium/src/content/public/android/java/src/org/chromium/content/browser/input/ThreadedInputConnectionFactory.java?l=169&rcl=f0698ee3e4483fad5b0c34159276f71cfaf81f3a
    post(
        new Runnable() {
          @Override
          public void run() {
            InputMethodManager imm =
                (InputMethodManager) getContext().getSystemService(INPUT_METHOD_SERVICE);
            // This is a hack to make InputMethodManager believe that the proxy view now has focus.
            // As a result, InputMethodManager will think that proxyAdapterView is focused, and will
            // call getHandler() of the view when creating input connection.

            // Step 1: Set proxyAdapterView as InputMethodManager#mNextServedView. This does not
            // affect the real window focus.
            proxyAdapterView.onWindowFocusChanged(true);

            // Step 2: Have InputMethodManager focus in on proxyAdapterView. As a result, IMM will
            // call onCreateInputConnection() on proxyAdapterView on the same thread as
            // proxyAdapterView.getHandler(). It will also call subsequent InputConnection methods
            // on this IME thread.
            imm.isActive(containerView);
          }
        });
    return super.checkInputConnectionProxy(view);
  }
}
