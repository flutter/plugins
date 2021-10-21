package io.flutter.plugins.webviewflutter;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;

import android.webkit.DownloadListener;

import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class DownloadListenerTest {
  @Rule
  public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock
  public GeneratedAndroidWebView.DownloadListenerFlutterApi mockFlutterApi;

  InstanceManager testInstanceManager;
  DownloadListenerHostApiImpl testHostApiImpl;
  DownloadListener testDownloadListener;

  @Before
  public void setUp() {
    testInstanceManager = new InstanceManager();

    final DownloadListenerHostApiImpl.DownloadListenerProxy downloadListenerProxy = new DownloadListenerHostApiImpl.DownloadListenerProxy() {
      @Override
      DownloadListener createDownloadListener(Long instanceId, GeneratedAndroidWebView.DownloadListenerFlutterApi downloadListenerFlutterApi) {
        testDownloadListener = super.createDownloadListener(instanceId, downloadListenerFlutterApi);
        return testDownloadListener;
      }
    };

    testHostApiImpl = new DownloadListenerHostApiImpl(testInstanceManager, downloadListenerProxy, mockFlutterApi);
    testHostApiImpl.create(0L);
  }

  @Test
  public void postMessage() {
    testDownloadListener.onDownloadStart("https://www.google.com",
        "userAgent",
        "contentDisposition",
        "mimetype",
        54);
    verify(mockFlutterApi).onDownloadStart(eq(0L), eq("https://www.google.com"), eq("userAgent"), eq("contentDisposition"), eq("mimetype"), eq(54L), any());
  }
}
