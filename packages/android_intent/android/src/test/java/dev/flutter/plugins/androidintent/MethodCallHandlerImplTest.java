package dev.flutter.plugins.androidintent;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.robolectric.Shadows.shadowOf;

import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import androidx.annotation.Nullable;
import androidx.test.core.app.ApplicationProvider;
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
  private Context context;
  private IntentSender sender;
  private MethodCallHandlerImpl methodCallHandler;

  public MethodCallHandlerImplTest() {}

  @Before
  public void setUp() {
    context = ApplicationProvider.getApplicationContext();
    sender = new IntentSender(null, null);
    methodCallHandler = new MethodCallHandlerImpl(sender);
  }

  @Test
  public void onMethodCall_doesNothingWhenContextIsNull() {
    sendLaunchMethodCall("foo", null, null, null, null);

    assertNull(shadowOf((Application) context).getNextStartedActivity());
  }

  @Test
  public void onMethodCall_setsAction() {
    sender.setApplicationContext(context);

    sendLaunchMethodCall("foo", null, null, null, null);

    Intent intent = shadowOf((Application) context).getNextStartedActivity();
    assertNotNull(intent);
    assertEquals("foo", intent.getAction());
  }

  @Test
  public void onMethodCall_setsNewTaskFlagWithApplicationContext() {
    sender.setApplicationContext(context);

    sendLaunchMethodCall("foo", null, null, null, null);

    Intent intent = shadowOf((Application) context).getNextStartedActivity();
    assertNotNull(intent);
    assertEquals(Intent.FLAG_ACTIVITY_NEW_TASK, intent.getFlags());
  }

  @Test
  public void onMethodCall_addsFlags() {
    sender.setApplicationContext(context);

    Integer requestFlags = Intent.FLAG_FROM_BACKGROUND;
    sendLaunchMethodCall("foo", requestFlags, null, null, null);

    Intent intent = shadowOf((Application) context).getNextStartedActivity();
    assertNotNull(intent);
    assertEquals(Intent.FLAG_ACTIVITY_NEW_TASK | requestFlags, intent.getFlags());
  }

  @Test
  public void onMethodCall_addsCategory() {
    sender.setApplicationContext(context);

    String category = "bar";
    sendLaunchMethodCall("foo", null, category, null, null);

    Intent intent = shadowOf((Application) context).getNextStartedActivity();
    assertNotNull(intent);
    assertTrue(intent.getCategories().contains(category));
  }

  @Test
  public void onMethodCall_setsData() {
    sender.setApplicationContext(context);

    Uri data = Uri.parse("http://flutter.dev");
    sendLaunchMethodCall("foo", null, null, data, null);

    Intent intent = shadowOf((Application) context).getNextStartedActivity();
    assertNotNull(intent);
    assertEquals(data, intent.getData());
  }

  @Test
  public void onMethodCall_clearsInvalidPackageNames() {
    sender.setApplicationContext(context);

    sendLaunchMethodCall("foo", null, null, null, "foo");

    Intent intent = shadowOf((Application) context).getNextStartedActivity();
    assertNotNull(intent);
    assertNull(intent.getPackage());
  }

  private void sendLaunchMethodCall(
      String action,
      @Nullable Integer flags,
      @Nullable String category,
      @Nullable Uri data,
      @Nullable String packageName) {
    Map<String, Object> args = new HashMap<>();
    args.put("action", action);
    args.put("flags", flags);
    args.put("category", category);
    args.put("data", String.valueOf(data));
    args.put("packageName", packageName);
    MethodCall call = new MethodCall("launch", args);
    Result result = mock(Result.class);
    methodCallHandler.onMethodCall(call, result);

    // No matter what, should always succeed.
    verify(result, times(1)).success(null);
  }
}
