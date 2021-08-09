package io.flutter.plugins.webviewflutter;

import android.os.Handler;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Map;
import java.util.concurrent.Executor;

/** Defines callback methods for the CustomHttpPostRequest. */
interface CustomRequestCallback {
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
 * <p>In the implementation, I used {@link HttpURLConnection} to create a post request with the HTTP
 * headers and the HTTP body.
 */
public class CustomHttpPostRequest {
  private final Executor executor;
  private final Handler resultHandler;

  CustomHttpPostRequest(Executor executor, Handler resultHandler) {
    this.executor = executor;
    this.resultHandler = resultHandler;
  }

  /**
   * Executes synchronous HTTP request method in the background thread since it creates {@link
   * HttpURLConnection} and made the custom post request with headers. If the HTTP post request is
   * completed successfully then notifies with the HTTP response. Otherwise notifies with the error.
   * See https://developer.android.com/guide/background/threading.
   *
   * @param request {@link WebViewRequest} instance to access its arguments.
   * @param callback method to invoke after HTTP request is completed.
   */
  public void makePostRequest(final WebViewRequest request, final CustomRequestCallback callback) {
    executor.execute(
        new Runnable() {
          @Override
          public void run() {
            try {
              String responseResult = makeSynchronousPostRequest(request);
              notifyComplete(responseResult, callback);

            } catch (IOException e) {
              notifyError(e, callback);
            }
          }
        });
  }

  private String makeSynchronousPostRequest(WebViewRequest request) throws IOException {
    URL url = new URL(request.getUrl());
    HttpURLConnection httpURLConnection = (HttpURLConnection) url.openConnection();
    try {
      // Set HTTP headers
      for (Map.Entry<String, String> entry : request.getHeaders().entrySet()) {
        httpURLConnection.setRequestProperty(entry.getKey(), entry.getValue());
      }

      httpURLConnection.setConnectTimeout(5000);
      httpURLConnection.setRequestMethod("POST");

      // Set DoOutput flag to true to be able to upload data to a web server.
      httpURLConnection.setDoOutput(true);

      // Used to enable streaming of a HTTP request body without internal buffering,
      // when the content length is known in advance. It improves the performance
      // because otherwise HTTPUrlConnection will be forced to buffer the complete
      // request body in memory before it is transmitted, wasting (and possibly exhausting)
      // heap and increasing latency.
      httpURLConnection.setFixedLengthStreamingMode(request.getBody().length);

      // Set HTTP body
      OutputStream os = new BufferedOutputStream(httpURLConnection.getOutputStream());
      os.write(request.getBody(), 0, request.getBody().length);
      os.flush();

      String line = "";
      StringBuilder contentBuilder = new StringBuilder();
      BufferedReader rd =
          new BufferedReader(new InputStreamReader(httpURLConnection.getInputStream()));
      while ((line = rd.readLine()) != null) {
        contentBuilder.append(line);
      }
      return contentBuilder.toString();

    } finally {
      httpURLConnection.disconnect();
    }
  }

  private void notifyComplete(final String responseResult, final CustomRequestCallback callback) {
    resultHandler.post(
        new Runnable() {
          @Override
          public void run() {
            callback.onComplete(responseResult);
          }
        });
  }

  private void notifyError(final Exception error, final CustomRequestCallback callback) {
    resultHandler.post(
        new Runnable() {
          @Override
          public void run() {
            callback.onError(error);
          }
        });
  }
}
