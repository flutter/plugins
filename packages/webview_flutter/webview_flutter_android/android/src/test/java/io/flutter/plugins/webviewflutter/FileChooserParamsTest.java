// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.webkit.WebChromeClient.FileChooserParams;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.platform.PlatformViewRegistry;
import io.flutter.plugins.webviewflutter.utils.TestUtils;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class FileChooserParamsTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public FileChooserParams mockFileChooserParams;

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
    when(mockFileChooserParams.getAcceptTypes()).thenReturn(new String[] {"my", "list"});
    when(mockFileChooserParams.getMode()).thenReturn(FileChooserParams.MODE_OPEN_MULTIPLE);
    when(mockFileChooserParams.getFilenameHint()).thenReturn("filenameHint");
    spyFlutterApi.create(mockFileChooserParams, reply -> {});

    final long identifier =
        Objects.requireNonNull(
            instanceManager.getIdentifierForStrongReference(mockFileChooserParams));
    final ArgumentCaptor<GeneratedAndroidWebView.FileChooserModeEnumData> modeCaptor =
        ArgumentCaptor.forClass(GeneratedAndroidWebView.FileChooserModeEnumData.class);

    verify(spyFlutterApi)
        .create(
            eq(identifier),
            eq(true),
            eq(Arrays.asList("my", "list")),
            modeCaptor.capture(),
            eq("filenameHint"),
            any());
    assertEquals(
        modeCaptor.getValue().getValue(), GeneratedAndroidWebView.FileChooserMode.OPEN_MULTIPLE);
  }

  @Test
  public void activityResultIsSetInPlugin() {
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.LOLLIPOP);

    final Activity mockActivity = mock(Activity.class);

    final BinaryMessenger mockBinaryMessenger = mock(BinaryMessenger.class);
    final PlatformViewRegistry mockViewRegistry = mock(PlatformViewRegistry.class);

    final FlutterPlugin.FlutterPluginBinding mockPluginBinding =
        mock(FlutterPlugin.FlutterPluginBinding.class);
    when(mockPluginBinding.getApplicationContext()).thenReturn(mockActivity);
    when(mockPluginBinding.getPlatformViewRegistry()).thenReturn(mockViewRegistry);
    when(mockPluginBinding.getBinaryMessenger()).thenReturn(mockBinaryMessenger);

    final WebViewFlutterPlugin webViewFlutterPlugin = new WebViewFlutterPlugin();
    webViewFlutterPlugin.onAttachedToEngine(mockPluginBinding);

    final ActivityPluginBinding mockActivityBinding = mock(ActivityPluginBinding.class);
    when(mockActivityBinding.getActivity()).thenReturn(mockActivity);

    webViewFlutterPlugin.onAttachedToActivity(mockActivityBinding);

    verify(mockActivityBinding).addActivityResultListener(any());

    // Closes the InstanceManager.
    webViewFlutterPlugin.onDetachedFromEngine(mockPluginBinding);
  }

  @Test
  public void openFilePickerForResult() {
    final FileChooserParamsHostApiImpl.FileChooserParamsProxy mockFileChooserParamsProxy =
        mock(FileChooserParamsHostApiImpl.FileChooserParamsProxy.class);
    final FileChooserParamsHostApiImpl hostApi =
        new FileChooserParamsHostApiImpl(instanceManager, mockFileChooserParamsProxy);

    final Activity mockActivity = mock(Activity.class);
    hostApi.setActivity(mockActivity);

    final Intent mockIntent = mock(Intent.class);
    when(mockFileChooserParams.createIntent()).thenReturn(mockIntent);
    instanceManager.addDartCreatedInstance(mockFileChooserParams, 0);

    //noinspection unchecked
    final GeneratedAndroidWebView.Result<List<String>> mockResult =
        mock(GeneratedAndroidWebView.Result.class);
    hostApi.openFilePickerForResult(
        0L, mockResult);
    verify(mockActivity).startActivityForResult(mockIntent, 0);

    final Uri mockUri = mock(Uri.class);
    when(mockUri.toString()).thenReturn("my/file");

    when(mockFileChooserParamsProxy.parseResult(0, mockIntent)).thenReturn(new Uri[] {mockUri});
    hostApi.getActivityResultListener().onActivityResult(0, 0, mockIntent);

    verify(mockResult).success(Collections.singletonList("my/file"));
  }

  @Test
  public void openFilePickerNullActivity() {
    final FileChooserParamsHostApiImpl hostApi = new FileChooserParamsHostApiImpl(instanceManager);

    final Intent mockIntent = mock(Intent.class);
    when(mockFileChooserParams.createIntent()).thenReturn(mockIntent);
    instanceManager.addDartCreatedInstance(mockFileChooserParams, 0);

    //noinspection unchecked
    final GeneratedAndroidWebView.Result<List<String>> mockResult =
        mock(GeneratedAndroidWebView.Result.class);
    hostApi.openFilePickerForResult(0L, mockResult);

    verify(mockResult).error(any());
  }

  @Test
  public void openFilePickerPendingResultHasNotFinished() {
    final FileChooserParamsHostApiImpl hostApi = new FileChooserParamsHostApiImpl(instanceManager);

    final Activity mockActivity = mock(Activity.class);
    hostApi.setActivity(mockActivity);

    final Intent mockIntent = mock(Intent.class);
    when(mockFileChooserParams.createIntent()).thenReturn(mockIntent);
    instanceManager.addDartCreatedInstance(mockFileChooserParams, 0);

    //noinspection unchecked
    final GeneratedAndroidWebView.Result<List<String>> mockResult =
        mock(GeneratedAndroidWebView.Result.class);
    hostApi.openFilePickerForResult(0L, mockResult);

    verify(mockResult, never()).error(any());

    hostApi.openFilePickerForResult(0L, mockResult);
    verify(mockResult).error(any());
  }
}
