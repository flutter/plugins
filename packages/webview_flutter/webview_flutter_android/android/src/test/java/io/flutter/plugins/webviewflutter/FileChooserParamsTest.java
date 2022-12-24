package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.webkit.WebChromeClient.FileChooserParams;

import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

import java.util.Arrays;
import java.util.List;
import java.util.Objects;

import io.flutter.plugin.common.BinaryMessenger;

public class FileChooserParamsTest {
  @Rule
  public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock
  public FileChooserParams mockFileChooserParams;

  @Mock public BinaryMessenger mockBinaryMessenger;

  InstanceManager instanceManager;

  @Before
  public void setUp() {
    instanceManager = InstanceManager.open(identifier -> {});
  }

  @After
  public void tearDown() {
    instanceManager.close();
  }

  @Test
  public void flutterApiCreate() {
    final FileChooserParamsFlutterApiImpl spyFlutterApi =
        spy(new FileChooserParamsFlutterApiImpl(mockBinaryMessenger, instanceManager));

    when(mockFileChooserParams.isCaptureEnabled()).thenReturn(true);
    when(mockFileChooserParams.getAcceptTypes()).thenReturn(new String[]{"my", "list"});
    when(mockFileChooserParams.getMode()).thenReturn(FileChooserParams.MODE_OPEN_MULTIPLE);
    when(mockFileChooserParams.getFilenameHint()).thenReturn("filenameHint");
    spyFlutterApi.create(mockFileChooserParams, reply -> {});

    final long identifier =
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(mockFileChooserParams));
    final ArgumentCaptor<GeneratedAndroidWebView.FileChooserModeEnumData> modeCaptor = ArgumentCaptor.forClass(GeneratedAndroidWebView.FileChooserModeEnumData.class);

    verify(spyFlutterApi).create(eq(identifier), eq(true),
        eq(Arrays.asList("my", "list")),
        modeCaptor.capture(),
        eq("filenameHint"),
        any());
    assertEquals(modeCaptor.getValue().getValue(), GeneratedAndroidWebView.FileChooserMode.OPEN_MULTIPLE);
  }

  @Test
  public void activityResultIsSetInPlugin() {

  }

  @Test
  public void openFilePickerForResult() {
    final FileChooserParamsHostApiImpl.FileChooserParamsProxy mockFileChooserParamsProxy = mock(FileChooserParamsHostApiImpl.FileChooserParamsProxy.class);
    final FileChooserParamsHostApiImpl hostApi =
        new FileChooserParamsHostApiImpl(instanceManager, mockFileChooserParamsProxy);

    final Activity mockActivity = mock(Activity.class);
    hostApi.setActivity(mockActivity);

    final Intent mockIntent = mock(Intent.class);
    when(mockFileChooserParams.createIntent()).thenReturn(mockIntent);
    instanceManager.addDartCreatedInstance(mockFileChooserParams, 0);

    final String[] successResult = new String[1];
    hostApi.openFilePickerForResult(0L, new GeneratedAndroidWebView.Result<List<String>>() {
      @Override
      public void success(List<String> result) {
        assertEquals(result.size(), 1);
        successResult[0] = result.get(0);
      }

      @Override
      public void error(Throwable error) {

      }
    });
    verify(mockActivity).startActivityForResult(mockIntent, 0);

    final Uri mockUri = mock(Uri.class);
    when(mockUri.toString()).thenReturn("my/file");

    when(mockFileChooserParamsProxy.parseResult(0, mockIntent)).thenReturn(new Uri[]{mockUri});
    hostApi.getActivityResultListener().onActivityResult(0, 0, mockIntent);

    assertEquals(successResult[0], "my/file");
  }
}