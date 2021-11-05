// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.os.Handler;
import androidx.annotation.VisibleForTesting;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Map;
import java.util.concurrent.Executor;

/** Defines callback methods for the HttpRequestManager. */
interface HttpRequestCallback {
  void onComplete(String result);

  void onError(Exception error);
}

/**
 * Works around on Android WebView postUrl method to accept headers.
 *
 * <p>Android WebView does not provide a post request method that accepts headers. Only method that
 * is provided is {@link android.webkit.WebView#postUrl(String, byte[])} and it accepts only URL and
 * HTTP body. CustomHttpPostRequest is implemented to provide this feature since adding a header to
 * post requests is a feature that is likely to be wanted.
 *
 * <p>In the implementation, {@link HttpURLConnection} is used to create a post request with the
 * HTTP headers and the HTTP body.
 */
public class HttpRequestManager {
  private final Executor executor;
  private final Handler resultHandler;

  HttpRequestManager(Executor executor, Handler resultHandler) {
    this.executor = executor;
    this.resultHandler = resultHandler;
  }

  /**
   * Executes the given HTTP request in a background thread. See <a
   * href="https://developer.android.com/guide/background/threading">https://developer.android.com/guide/background/threading</a>.
   *
   * @param request {@link WebViewRequest} to execute.
   * @param callback methods to invoke after the HTTP request has completed.
   */
  public void requestAsync(final WebViewRequest request, final HttpRequestCallback callback) {
    executor.execute(
        new Runnable() {
          @Override
          public void run() {
            try {
              String responseResult = request(request);
              notifyComplete(responseResult, callback);
            } catch (IOException e) {
              notifyError(e, callback);
            }
          }
        });
  }

  /**
   * Executes the given HTTP request synchronously.
   *
   * @param request {@link WebViewRequest} to execute.
   * @return The response body as a String.
   */
  public String request(WebViewRequest request) throws IOException {
    URL url = URLFactory.create(request.getUri());
    HttpURLConnection httpURLConnection = (HttpURLConnection) url.openConnection();
    try {
      // Basic request configuration
      httpURLConnection.setConnectTimeout(5000);
      httpURLConnection.setRequestMethod(request.getMethod().getValue().toUpperCase());

      // Set HTTP headers
      for (Map.Entry<String, String> entry : request.getHeaders().entrySet()) {
        httpURLConnection.setRequestProperty(entry.getKey(), entry.getValue());
      }

      // Set HTTP body
      if (request.getBody() != null && request.getBody().length > 0) {
        // Used to enable streaming of a HTTP request body without internal buffering,
        // when the content length is known in advance. It improves the performance
        // because otherwise HTTPUrlConnection will be forced to buffer the complete
        // request body in memory before it is transmitted, wasting (and possibly exhausting)
        // heap and increasing latency.
        httpURLConnection.setFixedLengthStreamingMode(request.getBody().length);

        httpURLConnection.setDoOutput(true);
        OutputStream os = BufferedOutputStreamFactory.create(httpURLConnection.getOutputStream());
        os.write(request.getBody());
        os.flush();
        os.close();
      }

      // Collect and return response body
      String line = "";
      StringBuilder contentBuilder = new StringBuilder();
      BufferedReader rd =
          BufferedReaderFactory.create(
              InputStreamReaderFactory.create(httpURLConnection.getInputStream()));
      while ((line = rd.readLine()) != null) {
        contentBuilder.append(line);
      }
      return contentBuilder.toString();
    } finally {
      httpURLConnection.disconnect();
    }
  }

  private void notifyComplete(final String responseResult, final HttpRequestCallback callback) {
    resultHandler.post(
        new Runnable() {
          @Override
          public void run() {
            callback.onComplete(responseResult);
          }
        });
  }

  private void notifyError(final Exception error, final HttpRequestCallback callback) {
    resultHandler.post(
        new Runnable() {
          @Override
          public void run() {
            callback.onError(error);
          }
        });
  }
  /** Factory class for creating a {@link URL} */
  static class URLFactory {
    /**
     * Creates a {@link URL}.
     *
     * <p><strong>Important:</strong> This method is visible for testing purposes only and should
     * never be called from outside this class.
     *
     * @param url to create the instance for.
     * @return The new {@link URL} object.
     */
    @VisibleForTesting
    public static URL create(String url) throws MalformedURLException {
      return new URL(url);
    }
  }
  /** Factory class for creating a {@link BufferedOutputStream} */
  static class BufferedOutputStreamFactory {
    /**
     * Creates a {@link BufferedOutputStream}.
     *
     * <p><strong>Important:</strong> This method is visible for testing purposes only and should
     * never be called from outside this class.
     *
     * @param stream to create the instance for.
     * @return The new {@link BufferedOutputStream} object.
     */
    @VisibleForTesting
    public static BufferedOutputStream create(OutputStream stream) {
      return new BufferedOutputStream(stream);
    }
  }
  /** Factory class for creating a {@link BufferedReader} */
  static class BufferedReaderFactory {
    /**
     * Creates a {@link BufferedReader}.
     *
     * <p><strong>Important:</strong> This method is visible for testing purposes only and should
     * never be called from outside this class.
     *
     * @param stream to create the instance for.
     * @return The new {@link BufferedReader} object.
     */
    @VisibleForTesting
    public static BufferedReader create(InputStreamReader stream) {
      return new BufferedReader(stream);
    }
  }
  /** Factory class for creating a {@link InputStreamReader} */
  static class InputStreamReaderFactory {
    /**
     * Creates a {@link InputStreamReader}.
     *
     * <p><strong>Important:</strong> This method is visible for testing purposes only and should
     * never be called from outside this class.
     *
     * @param stream to create the instance for.
     * @return The new {@link InputStreamReader} object.
     */
    @VisibleForTesting
    public static InputStreamReader create(InputStream stream) {
      return new InputStreamReader(stream);
    }
  }
}
