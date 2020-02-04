package io.flutter.plugins.urllauncher;

import static org.mockito.Matchers.any;
import static org.mockito.Matchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.test.core.app.ApplicationProvider;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.BinaryMessenger.BinaryMessageHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;
import java.util.HashMap;
import java.util.Map;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class MethodCallHandlerImplTest {
  private static final String CHANNEL_NAME = "plugins.flutter.io/url_launcher";
  private UrlLauncher urlLauncher;
  private MethodCallHandlerImpl methodCallHandler;

  @Before
  public void setUp() {
    urlLauncher = new UrlLauncher(ApplicationProvider.getApplicationContext(), /*activity=*/ null);
    methodCallHandler = new MethodCallHandlerImpl(urlLauncher);
  }

  @Test
  public void startListening_registersChannel() {
    BinaryMessenger messenger = mock(BinaryMessenger.class);

    methodCallHandler.startListening(messenger);

    verify(messenger, times(1))
        .setMessageHandler(eq(CHANNEL_NAME), any(BinaryMessageHandler.class));
  }

  @Test
  public void startListening_unregistersExistingChannel() {
    BinaryMessenger firstMessenger = mock(BinaryMessenger.class);
    BinaryMessenger secondMessenger = mock(BinaryMessenger.class);
    methodCallHandler.startListening(firstMessenger);

    methodCallHandler.startListening(secondMessenger);

    // Unregisters the first and then registers the second.
    verify(firstMessenger, times(1)).setMessageHandler(CHANNEL_NAME, null);
    verify(secondMessenger, times(1))
        .setMessageHandler(eq(CHANNEL_NAME), any(BinaryMessageHandler.class));
  }

  @Test
  public void stopListening_unregistersExistingChannel() {
    BinaryMessenger messenger = mock(BinaryMessenger.class);
    methodCallHandler.startListening(messenger);

    methodCallHandler.stopListening();

    verify(messenger, times(1)).setMessageHandler(CHANNEL_NAME, null);
  }

  @Test
  public void stopListening_doesNothingWhenUnset() {
    BinaryMessenger messenger = mock(BinaryMessenger.class);

    methodCallHandler.stopListening();

    verify(messenger, never()).setMessageHandler(CHANNEL_NAME, null);
  }

  @Test
  public void onMethodCall_canLaunchReturnsTrue() {
    urlLauncher = mock(UrlLauncher.class);
    methodCallHandler = new MethodCallHandlerImpl(urlLauncher);
    String url = "foo";
    when(urlLauncher.canLaunch(url)).thenReturn(true);
    Result result = mock(Result.class);
    Map<String, Object> args = new HashMap<>();
    args.put("url", url);

    methodCallHandler.onMethodCall(new MethodCall("canLaunch", args), result);

    verify(result, times(1)).success(true);
  }

  @Test
  public void onMethodCall_canLaunchReturnsFalse() {
    urlLauncher = mock(UrlLauncher.class);
    methodCallHandler = new MethodCallHandlerImpl(urlLauncher);
    String url = "foo";
    when(urlLauncher.canLaunch(url)).thenReturn(false);
    Result result = mock(Result.class);
    Map<String, Object> args = new HashMap<>();
    args.put("url", url);

    methodCallHandler.onMethodCall(new MethodCall("canLaunch", args), result);

    verify(result, times(1)).success(false);
  }

  @Test
  public void onMethodCall_closeWebView() {
    urlLauncher = mock(UrlLauncher.class);
    methodCallHandler = new MethodCallHandlerImpl(urlLauncher);
    String url = "foo";
    when(urlLauncher.canLaunch(url)).thenReturn(true);
    Result result = mock(Result.class);
    Map<String, Object> args = new HashMap<>();
    args.put("url", url);

    methodCallHandler.onMethodCall(new MethodCall("closeWebView", args), result);

    verify(urlLauncher, times(1)).closeWebView();
    verify(result, times(1)).success(null);
  }
}
