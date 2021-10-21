package io.flutter.plugins.webviewflutter;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;

import android.webkit.WebView;
import android.webkit.WebViewClient;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class WebViewClientTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public GeneratedAndroidWebView.WebViewClientFlutterApi mockFlutterApi;

  @Mock public WebView mockWebView;

  InstanceManager testInstanceManager;
  WebViewClientHostApiImpl testHostApiImpl;
  WebViewClient testWebViewClient;

  @Before
  public void setUp() {
    testInstanceManager = new InstanceManager();
    testInstanceManager.addInstance(mockWebView, 0L);

    final WebViewClientHostApiImpl.WebViewClientProxy webViewClientProxy =
        new WebViewClientHostApiImpl.WebViewClientProxy() {
          @Override
          WebViewClient createWebViewClient(
              Long instanceId,
              InstanceManager instanceManager,
              Boolean shouldOverrideUrlLoading,
              GeneratedAndroidWebView.WebViewClientFlutterApi webViewClientFlutterApi) {
            testWebViewClient =
                super.createWebViewClient(
                    instanceId, instanceManager, shouldOverrideUrlLoading, webViewClientFlutterApi);
            return testWebViewClient;
          }
        };

    testHostApiImpl =
        new WebViewClientHostApiImpl(testInstanceManager, webViewClientProxy, mockFlutterApi);
    testHostApiImpl.create(1L, true);
  }

  @Test
  public void onPageStarted() {
    testWebViewClient.onPageStarted(mockWebView, "https://www.google.com", null);
    verify(mockFlutterApi).onPageStarted(eq(1L), eq(0L), eq("https://www.google.com"), any());
  }

  @Test
  public void onReceivedError() {
    testWebViewClient.onReceivedError(mockWebView, 32, "description", "https://www.google.com");
    verify(mockFlutterApi)
        .onReceivedError(
            eq(1L), eq(0L), eq(32L), eq("description"), eq("https://www.google.com"), any());
  }

  @Test
  public void urlLoading() {
    testWebViewClient.shouldOverrideUrlLoading(mockWebView, "https://www.google.com");
    verify(mockFlutterApi).urlLoading(eq(1L), eq(0L), eq("https://www.google.com"), any());
  }
}
