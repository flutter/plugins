package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.mockito.Mockito.*;

import android.content.Context;
import android.view.View;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import java.io.IOException;
import org.junit.Before;
import org.junit.Test;

public class WebViewBuilderTest {
  private Context mockContext;
  private View mockContainerView;

  @Before
  public void before() {
    mockContext = mock(Context.class);
    mockContainerView = mock(View.class);
  }

  @Test
  public void ctor_test() {
    WebViewBuilder builder =
        new WebViewBuilder(mockContext, false, mockContainerView);

    assertNotNull(builder);
  }

  @Test
  public void build_Should_set_values() throws IOException {
    WebViewBuilder.WebViewFactory mockFactory =
        mock(WebViewBuilder.WebViewFactory.class);
    WebView mockWebView = mock(WebView.class);
    WebSettings mockWebSettings = mock(WebSettings.class);
    WebChromeClient mockWebChromeClient = mock(WebChromeClient.class);

    when(mockWebView.getSettings()).thenReturn(mockWebSettings);

    WebViewBuilder builder =
        new WebViewBuilder(mockContext, false, mockContainerView, mockFactory)
            .setDomStorageEnabled(true)
            .setJavaScriptCanOpenWindowsAutomatically(true)
            .setSupportMultipleWindows(true)
            .setWebChromeClient(mockWebChromeClient);

    when(mockFactory.create(mockContext, false, mockContainerView)).thenReturn(mockWebView);

    WebView webView = builder.build();

    assertNotNull(webView);
    verify(mockWebSettings).setDomStorageEnabled(true);
    verify(mockWebSettings).setJavaScriptCanOpenWindowsAutomatically(true);
    verify(mockWebSettings).setSupportMultipleWindows(true);
    verify(mockWebView).setWebChromeClient(mockWebChromeClient);
  }
}
