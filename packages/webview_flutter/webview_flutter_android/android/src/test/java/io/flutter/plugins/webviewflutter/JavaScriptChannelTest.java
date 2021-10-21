package io.flutter.plugins.webviewflutter;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;

import android.os.Handler;

import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class JavaScriptChannelTest {
  @Rule
  public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock
  public GeneratedAndroidWebView.JavaScriptChannelFlutterApi mockFlutterApi;

  InstanceManager testInstanceManager;
  JavaScriptChannelHostApiImpl testHostApiImpl;
  JavaScriptChannel testJavaScriptChannel;

  @Before
  public void setUp() {
    testInstanceManager = new InstanceManager();

    final JavaScriptChannelHostApiImpl.JavaScriptChannelProxy javaScriptChannelProxy = new JavaScriptChannelHostApiImpl.JavaScriptChannelProxy() {
      @Override
      JavaScriptChannel createJavaScriptChannel(Long instanceId, GeneratedAndroidWebView.JavaScriptChannelFlutterApi javaScriptChannelFlutterApi, String channelName, Handler platformThreadHandler) {
        testJavaScriptChannel = super.createJavaScriptChannel(instanceId, javaScriptChannelFlutterApi, channelName, platformThreadHandler);
        return testJavaScriptChannel;
      }
    };

    testHostApiImpl = new JavaScriptChannelHostApiImpl(testInstanceManager, javaScriptChannelProxy, mockFlutterApi, new Handler());
    testHostApiImpl.create(0L, "aChannelName");
  }

  @Test
  public void postMessage() {
    testJavaScriptChannel.postMessage("A message post.");
    verify(mockFlutterApi).postMessage(eq(0L), eq("A message post."), any());
  }
}
