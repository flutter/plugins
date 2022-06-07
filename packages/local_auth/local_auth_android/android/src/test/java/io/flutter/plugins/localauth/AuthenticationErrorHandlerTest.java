package io.flutter.plugins.localauth;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockConstruction;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.AlertDialog;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import androidx.fragment.app.FragmentActivity;

import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mockito.ArgumentMatchers;
import org.mockito.MockedConstruction;
import org.mockito.MockedStatic;

import java.util.HashMap;

import io.flutter.plugin.common.MethodCall;

public class AuthenticationErrorHandlerTest {
  MockedStatic<LayoutInflater> layoutInflaterStaticMock;
  MockedConstruction<AlertDialog.Builder> alertDialogBuilderConstruction;

  @Before
  public void setUp() {
    layoutInflaterStaticMock = mockStatic(LayoutInflater.class);
    alertDialogBuilderConstruction = mockConstruction(AlertDialog.Builder.class,
        new MockedConstruction.MockInitializer<AlertDialog.Builder>(
        ) {
          @Override
          public void prepare(AlertDialog.Builder mock, MockedConstruction.Context context) {
            when(mock.setView(any())).thenReturn(mock);
            when(mock.setPositiveButton(anyString(), any())).thenReturn(mock);
            when(mock.setNegativeButton(anyString(), any())).thenReturn(mock);
            when(mock.setCancelable(anyBoolean())).thenReturn(mock);
          }
        }
    );
  }

  @After
  public void close() {
    layoutInflaterStaticMock.close();
    alertDialogBuilderConstruction.close();
  }

  @Test
  public void handleCredentialsNotAvailableError_doNotTrySettingsUpdate() {
    final AuthenticationErrorHandler authErrorHandler = new AuthenticationErrorHandler();
    final FragmentActivity mockActivity = buildMockActivity();
    final MethodCall methodCall = new MethodCall("authenticate", new HashMap<String, Object>() {
      {
        put("useErrorDialogs", true);
      }
    });
    final AuthenticationHelper.AuthCompletionHandler completionHandler = mock(AuthenticationHelper.AuthCompletionHandler.class);
    final Runnable onStopCallback = mock(Runnable.class);
    authErrorHandler.handleCredentialsNotAvailableError(
        mockActivity,
        false,
        methodCall,
        completionHandler,
        onStopCallback
    );
    verify(completionHandler).onError(ArgumentMatchers.eq(AuthResultErrorCodes.NOT_AVAILABLE), anyString());
    verify(onStopCallback).run();
    Assert.assertTrue(alertDialogBuilderConstruction.constructed().isEmpty());
  }

  @Test
  public void handleCredentialsNotAvailableError_doNotUseErrorDialog() {
    final AuthenticationErrorHandler authErrorHandler = new AuthenticationErrorHandler();
    final FragmentActivity mockActivity = buildMockActivity();
    final MethodCall methodCall = new MethodCall("authenticate", new HashMap<String, Object>() {
      {
        put("useErrorDialogs", false);
      }
    });
    final AuthenticationHelper.AuthCompletionHandler completionHandler = mock(AuthenticationHelper.AuthCompletionHandler.class);
    final Runnable onStopCallback = mock(Runnable.class);
    authErrorHandler.handleCredentialsNotAvailableError(
        mockActivity,
        true,
        methodCall,
        completionHandler,
        onStopCallback
    );
    verify(completionHandler).onError(ArgumentMatchers.eq(AuthResultErrorCodes.NOT_AVAILABLE), anyString());
    verify(onStopCallback).run();
    Assert.assertTrue(alertDialogBuilderConstruction.constructed().isEmpty());
  }

  @Test
  public void handleCredentialsNotAvailableError_showSettingsUpdateDialog() {
    final AuthenticationErrorHandler authErrorHandler = new AuthenticationErrorHandler();
    final FragmentActivity mockActivity = buildMockActivity();
    mockDialogViewInflation();
    final MethodCall methodCall = new MethodCall("authenticate", new HashMap<String, Object>() {
      {
        put("useErrorDialogs", true);
        put("goToSetting", "Go to Setting");
        put("cancelButton", "Cancel");
      }
    });
    final AuthenticationHelper.AuthCompletionHandler completionHandler = mock(AuthenticationHelper.AuthCompletionHandler.class);
    final Runnable onStopCallback = mock(Runnable.class);
    authErrorHandler.handleCredentialsNotAvailableError(
        mockActivity,
        true,
        methodCall,
        completionHandler,
        onStopCallback
    );
    verify(completionHandler, never()).onError(ArgumentMatchers.anyString(), anyString());
    final AlertDialog.Builder alertDialogBuilder = alertDialogBuilderConstruction.constructed().get(0);
    verify(alertDialogBuilder).show();
    verify(onStopCallback, never()).run();
  }

  @Test
  public void handleNotEnrolledError_showSettingsUpdateDialog() {
    final AuthenticationErrorHandler authErrorHandler = new AuthenticationErrorHandler();
    final FragmentActivity mockActivity = buildMockActivity();
    mockDialogViewInflation();
    final MethodCall methodCall = new MethodCall("authenticate", new HashMap<String, Object>() {
      {
        put("useErrorDialogs", true);
        put("goToSetting", "Go to Setting");
        put("cancelButton", "Cancel");
      }
    });
    final AuthenticationHelper.AuthCompletionHandler completionHandler = mock(AuthenticationHelper.AuthCompletionHandler.class);
    final Runnable onStopCallback = mock(Runnable.class);
    authErrorHandler.handleNotEnrolledError(
        mockActivity,
        false,
        methodCall,
        completionHandler,
        onStopCallback
    );
    verify(completionHandler, never()).onError(ArgumentMatchers.anyString(), anyString());
    final AlertDialog.Builder alertDialogBuilder = alertDialogBuilderConstruction.constructed().get(0);
    verify(alertDialogBuilder).show();
    verify(onStopCallback, never()).run();
  }

  @Test
  public void handleNotEnrolledError_doNotUseErrorDialog() {
    final AuthenticationErrorHandler authErrorHandler = new AuthenticationErrorHandler();
    final FragmentActivity mockActivity = buildMockActivity();
    mockDialogViewInflation();
    final MethodCall methodCall = new MethodCall("authenticate", new HashMap<String, Object>() {
      {
        put("useErrorDialogs", false);
      }
    });
    final AuthenticationHelper.AuthCompletionHandler completionHandler = mock(AuthenticationHelper.AuthCompletionHandler.class);
    final Runnable onStopCallback = mock(Runnable.class);
    authErrorHandler.handleNotEnrolledError(
        mockActivity,
        false,
        methodCall,
        completionHandler,
        onStopCallback
    );
    verify(completionHandler).onError(ArgumentMatchers.eq(AuthResultErrorCodes.NOT_ENROLLED), anyString());
    Assert.assertTrue(alertDialogBuilderConstruction.constructed().isEmpty());
    verify(onStopCallback).run();
  }

  @Test
  public void handleNotEnrolledError_deviceCredentialAllowed() {
    final AuthenticationErrorHandler authErrorHandler = new AuthenticationErrorHandler();
    final FragmentActivity mockActivity = buildMockActivity();
    mockDialogViewInflation();
    final MethodCall methodCall = new MethodCall("authenticate", new HashMap<String, Object>() {
      {
        put("useErrorDialogs", false);
      }
    });
    final AuthenticationHelper.AuthCompletionHandler completionHandler = mock(AuthenticationHelper.AuthCompletionHandler.class);
    final Runnable onStopCallback = mock(Runnable.class);
    authErrorHandler.handleNotEnrolledError(
        mockActivity,
        true,
        methodCall,
        completionHandler,
        onStopCallback
    );
    verify(completionHandler, never()).onError(anyString(), anyString());
    Assert.assertTrue(alertDialogBuilderConstruction.constructed().isEmpty());
    verify(onStopCallback, never()).run();
  }

  private FragmentActivity buildMockActivity() {
    final FragmentActivity mockActivity = mock(FragmentActivity.class);
    final Context mockContext = mock(Context.class);
    when(mockActivity.getBaseContext()).thenReturn(mockContext);
    when(mockActivity.getApplicationContext()).thenReturn(mockContext);
    return mockActivity;
  }

  private void mockDialogViewInflation() {
    final LayoutInflater layoutInflaterMock = mock(LayoutInflater.class);
    final View dialogView = mock(View.class);
    when(LayoutInflater.from(any())).thenReturn(layoutInflaterMock);
    when(layoutInflaterMock.inflate(anyInt(), any(), anyBoolean())).thenReturn(dialogView);
    when(dialogView.findViewById(R.id.fingerprint_required)).thenReturn(mock(TextView.class));
    when(dialogView.findViewById(R.id.go_to_setting_description)).thenReturn(mock(TextView.class));
  }
}
