package io.flutter.plugins.webviewflutter;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.os.Build;
import android.webkit.WebViewClient;
import androidx.webkit.WebViewClientCompat;
import io.flutter.plugins.webviewflutter.utils.TestUtils;
import org.junit.Assert;
import org.junit.Test;

public class WebViewClientHostApiImplTest {

  @Test
  public void WebViewClientCreator_createWebViewClient_createsWebViewClientOnAndroidNOrAbove() {
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.N);
    WebViewClientHostApiImpl.WebViewClientCreator webViewClientCreator =
        new WebViewClientHostApiImpl.WebViewClientCreator();

    WebViewClient webViewClient = webViewClientCreator.createWebViewClient(1L, null, false, null);

    Assert.assertFalse(webViewClient instanceof WebViewClientCompat);
  }

  @Test
  public void WebViewClientCreator_createWebViewClient_createsWebViewClientCompatBelowAndroidN() {
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.M);
    WebViewClientHostApiImpl.WebViewClientCreator webViewClientCreator =
        new WebViewClientHostApiImpl.WebViewClientCreator();

    WebViewClient webViewClient = webViewClientCreator.createWebViewClient(1L, null, false, null);

    Assert.assertTrue(webViewClient instanceof WebViewClientCompat);
  }

  @Test
  public void
      WebViewClientCreator_createWebViewClient_WebViewClient_doUpdateVisitedHistory_shouldCallOnUrlChangedEvent() {
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.N);
    WebViewClientHostApiImpl.WebViewClientCreator webViewClientCreator =
        new WebViewClientHostApiImpl.WebViewClientCreator();
    InstanceManager mockInstanceManager = mock(InstanceManager.class);
    when(mockInstanceManager.getInstanceId(any())).thenReturn(2L);
    GeneratedAndroidWebView.WebViewClientFlutterApi mockWebViewClientFlutterApi =
        mock(GeneratedAndroidWebView.WebViewClientFlutterApi.class);

    WebViewClient webViewClient =
        webViewClientCreator.createWebViewClient(
            1L, mockInstanceManager, false, mockWebViewClientFlutterApi);
    webViewClient.doUpdateVisitedHistory(null, "https://flutter.dev/", false);

    verify(mockWebViewClientFlutterApi)
        .onUrlChanged(eq(1L), eq(2L), eq("https://flutter.dev/"), any());
  }

  @Test
  public void
      WebViewClientCreator_createWebViewClient_WebViewClientCompat_doUpdateVisitedHistory_shouldCallOnUrlChangedEvent() {
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.M);
    WebViewClientHostApiImpl.WebViewClientCreator webViewClientCreator =
        new WebViewClientHostApiImpl.WebViewClientCreator();
    InstanceManager mockInstanceManager = mock(InstanceManager.class);
    when(mockInstanceManager.getInstanceId(any())).thenReturn(2L);
    GeneratedAndroidWebView.WebViewClientFlutterApi mockWebViewClientFlutterApi =
        mock(GeneratedAndroidWebView.WebViewClientFlutterApi.class);

    WebViewClientCompat webViewClient =
        (WebViewClientCompat)
            webViewClientCreator.createWebViewClient(
                1L, mockInstanceManager, false, mockWebViewClientFlutterApi);
    webViewClient.doUpdateVisitedHistory(null, "https://flutter.dev/", false);

    verify(mockWebViewClientFlutterApi)
        .onUrlChanged(eq(1L), eq(2L), eq("https://flutter.dev/"), any());
  }
}
