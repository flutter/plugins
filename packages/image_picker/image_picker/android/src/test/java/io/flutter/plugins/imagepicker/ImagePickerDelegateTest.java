// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import static org.hamcrest.core.IsEqual.equalTo;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.reset;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoMoreInteractions;
import static org.mockito.Mockito.when;

import android.Manifest;
import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.imagepicker.utils.TestUtils;
import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.ArgumentMatcher;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class ImagePickerDelegateTest {
  private static final Double WIDTH = 10.0;
  private static final Double HEIGHT = 10.0;
  private static final Double MAX_DURATION = 10.0;
  private static final Integer IMAGE_QUALITY = 90;

  @Mock Activity mockActivity;
  @Mock ImageResizer mockImageResizer;
  @Mock MethodCall mockMethodCall;
  @Mock MethodChannel.Result mockResult;
  @Mock ImagePickerDelegate.PermissionManager mockPermissionManager;
  @Mock FileUtils mockFileUtils;
  @Mock Intent mockIntent;
  @Mock ImagePickerCache cache;

  ImagePickerDelegate.FileUriResolver mockFileUriResolver;
  MockedStatic<File> mockStaticFile;

  private static class MockFileUriResolver implements ImagePickerDelegate.FileUriResolver {
    @Override
    public Uri resolveFileProviderUriForFile(String fileProviderName, File imageFile) {
      return null;
    }

    @Override
    public void getFullImagePath(Uri imageUri, ImagePickerDelegate.OnPathReadyListener listener) {
      listener.onPathReady("pathFromUri");
    }
  }

  @Before
  public void setUp() {
    MockitoAnnotations.initMocks(this);
    reset(mockActivity);

    mockStaticFile = Mockito.mockStatic(File.class);
    mockStaticFile
        .when(() -> File.createTempFile(any(), any(), any()))
        .thenReturn(new File("/tmpfile"));

    when(mockActivity.getPackageName()).thenReturn("com.example.test");
    when(mockActivity.getPackageManager()).thenReturn(mock(PackageManager.class));

    when(mockFileUtils.getPathFromUri(any(Context.class), any(Uri.class)))
        .thenReturn("pathFromUri");

    when(mockImageResizer.resizeImageIfNeeded("pathFromUri", null, null, null))
        .thenReturn("originalPath");
    when(mockImageResizer.resizeImageIfNeeded("pathFromUri", null, null, IMAGE_QUALITY))
        .thenReturn("originalPath");
    when(mockImageResizer.resizeImageIfNeeded("pathFromUri", WIDTH, HEIGHT, null))
        .thenReturn("scaledPath");
    when(mockImageResizer.resizeImageIfNeeded("pathFromUri", WIDTH, null, null))
        .thenReturn("scaledPath");
    when(mockImageResizer.resizeImageIfNeeded("pathFromUri", null, HEIGHT, null))
        .thenReturn("scaledPath");

    mockFileUriResolver = new MockFileUriResolver();

    Uri mockUri = mock(Uri.class);
    when(mockIntent.getData()).thenReturn(mockUri);
  }

  @After
  public void tearDown() {
    mockStaticFile.close();
  }

  @Test
  public void whenConstructed_setsCorrectFileProviderName() {
    ImagePickerDelegate delegate = createDelegate();
    assertThat(delegate.fileProviderName, equalTo("com.example.test.flutter.image_provider"));
  }

  @Test
  public void chooseImageFromGallery_launchesCorrectIntent() {
    ImagePickerDelegate delegate;
    Intent expectedIntent;

    // On API 19 and up
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.KITKAT);
    delegate = createDelegate();
    expectedIntent = new Intent(Intent.ACTION_GET_CONTENT);
    expectedIntent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, false);
    expectedIntent.setType("*/*");
    expectedIntent.putExtra(Intent.EXTRA_MIME_TYPES, new String[] {"image/*"});

    delegate.chooseImageFromGallery(mockMethodCall, mockResult);

    verify(mockActivity)
        .startActivityForResult(
            argThat(new IntentMatcher(expectedIntent)),
            eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_FROM_GALLERY));

    // On API 18 and below
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.JELLY_BEAN_MR2);
    delegate = createDelegate();
    expectedIntent = new Intent(Intent.ACTION_GET_CONTENT);
    expectedIntent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, false);
    expectedIntent.setType("image/*");

    delegate.chooseImageFromGallery(mockMethodCall, mockResult);

    verify(mockActivity)
        .startActivityForResult(
            argThat(new IntentMatcher(expectedIntent)),
            eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_FROM_GALLERY));
  }

  @Test
  public void chooseMultiImageFromGallery_launchesCorrectIntent() {
    ImagePickerDelegate delegate;
    Intent expectedIntent;

    // On API 19 and up
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.KITKAT);
    delegate = createDelegate();
    expectedIntent = new Intent(Intent.ACTION_GET_CONTENT);
    expectedIntent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true);
    expectedIntent.setType("*/*");
    expectedIntent.putExtra(Intent.EXTRA_MIME_TYPES, new String[] {"image/*"});

    delegate.chooseMultiImageFromGallery(mockMethodCall, mockResult);

    verify(mockActivity)
        .startActivityForResult(
            argThat(new IntentMatcher(expectedIntent)),
            eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_MULTI_FROM_GALLERY));

    // On API 18 and up
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.JELLY_BEAN_MR2);
    delegate = createDelegate();
    expectedIntent = new Intent(Intent.ACTION_GET_CONTENT);
    expectedIntent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true);
    expectedIntent.setType("*/*");
    expectedIntent.putExtra(Intent.EXTRA_MIME_TYPES, new String[] {"image/*"});

    delegate.chooseMultiImageFromGallery(mockMethodCall, mockResult);

    verify(mockActivity)
        .startActivityForResult(
            argThat(new IntentMatcher(expectedIntent)),
            eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_MULTI_FROM_GALLERY));

    // On API 17 and below
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.JELLY_BEAN_MR1);
    delegate = createDelegate();
    expectedIntent = new Intent(Intent.ACTION_GET_CONTENT);
    expectedIntent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, false);
    expectedIntent.setType("image/*");

    delegate.chooseMultiImageFromGallery(mockMethodCall, mockResult);

    verify(mockActivity)
        .startActivityForResult(
            argThat(new IntentMatcher(expectedIntent)),
            eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_MULTI_FROM_GALLERY));
  }

  @Test
  public void chooseMediaFromGallery_launchesCorrectIntent_multiple() {
    ImagePickerDelegate delegate;
    Intent expectedIntent;

    when(mockMethodCall.argument("allowMultiple")).thenReturn(true);
    when(mockMethodCall.argument("types"))
        .thenReturn(
            new ArrayList<String>() {
              {
                add("image");
                add("video");
              }
            });

    // On API 19 and up
    reset(mockActivity);
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.KITKAT);
    delegate = createDelegate();
    expectedIntent = new Intent(Intent.ACTION_GET_CONTENT);
    expectedIntent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true);
    expectedIntent.setType("*/*");
    expectedIntent.putExtra(Intent.EXTRA_MIME_TYPES, new String[] {"image/*", "video/*"});

    delegate.chooseMediaFromGallery(mockMethodCall, mockResult);

    verify(mockActivity)
        .startActivityForResult(
            argThat(new IntentMatcher(expectedIntent)),
            eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_MULTI_FROM_GALLERY));

    // On API 18 and up
    reset(mockActivity);
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.JELLY_BEAN_MR2);
    delegate = createDelegate();
    expectedIntent = new Intent(Intent.ACTION_GET_CONTENT);
    expectedIntent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true);
    expectedIntent.setType("image/* video/*");

    delegate.chooseMediaFromGallery(mockMethodCall, mockResult);

    verify(mockActivity)
        .startActivityForResult(
            argThat(new IntentMatcher(expectedIntent)),
            eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_MULTI_FROM_GALLERY));

    // On API 17 and below
    reset(mockActivity);
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.JELLY_BEAN_MR1);
    delegate = createDelegate();
    expectedIntent = new Intent(Intent.ACTION_GET_CONTENT);
    expectedIntent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, false);
    expectedIntent.setType("image/* video/*");

    delegate.chooseMediaFromGallery(mockMethodCall, mockResult);

    verify(mockActivity)
        .startActivityForResult(
            argThat(new IntentMatcher(expectedIntent)),
            eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_MULTI_FROM_GALLERY));
  }

  @Test
  public void chooseMediaFromGallery_launchesCorrectIntent_single() {
    ImagePickerDelegate delegate;
    Intent expectedIntent;

    when(mockMethodCall.argument("allowMultiple")).thenReturn(false);
    when(mockMethodCall.argument("types"))
        .thenReturn(
            new ArrayList<String>() {
              {
                add("image");
                add("video");
              }
            });

    // On API 19 and up
    reset(mockActivity);
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.KITKAT);
    delegate = createDelegate();
    expectedIntent = new Intent(Intent.ACTION_GET_CONTENT);
    expectedIntent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, false);
    expectedIntent.setType("*/*");
    expectedIntent.putExtra(Intent.EXTRA_MIME_TYPES, new String[] {"image/*", "video/*"});

    delegate.chooseMediaFromGallery(mockMethodCall, mockResult);

    verify(mockActivity)
        .startActivityForResult(
            argThat(new IntentMatcher(expectedIntent)),
            eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_FROM_GALLERY));

    // On API 18 and up
    reset(mockActivity);
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.JELLY_BEAN_MR2);
    delegate = createDelegate();
    expectedIntent = new Intent(Intent.ACTION_GET_CONTENT);
    expectedIntent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, false);
    expectedIntent.setType("image/* video/*");

    delegate.chooseMediaFromGallery(mockMethodCall, mockResult);

    verify(mockActivity)
        .startActivityForResult(
            argThat(new IntentMatcher(expectedIntent)),
            eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_FROM_GALLERY));

    // On API 17 and below
    reset(mockActivity);
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.JELLY_BEAN_MR1);
    delegate = createDelegate();
    expectedIntent = new Intent(Intent.ACTION_GET_CONTENT);
    expectedIntent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, false);
    expectedIntent.setType("image/* video/*");

    delegate.chooseMediaFromGallery(mockMethodCall, mockResult);

    verify(mockActivity)
        .startActivityForResult(
            argThat(new IntentMatcher(expectedIntent)),
            eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_FROM_GALLERY));
  }

  @Test
  public void chooseImageFromGallery_WhenPendingResultExists_FinishesWithAlreadyActiveError() {
    ImagePickerDelegate delegate = createDelegateWithPendingResultAndMethodCall();

    delegate.chooseImageFromGallery(mockMethodCall, mockResult);

    verifyFinishedWithAlreadyActiveError();
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void chooseMultiImageFromGallery_WhenPendingResultExists_FinishesWithAlreadyActiveError() {
    ImagePickerDelegate delegate = createDelegateWithPendingResultAndMethodCall();

    delegate.chooseMultiImageFromGallery(mockMethodCall, mockResult);

    verifyFinishedWithAlreadyActiveError();
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void chooseMediaFromGallery_WhenPendingResultExists_FinishesWithAlreadyActiveError() {
    ImagePickerDelegate delegate = createDelegateWithPendingResultAndMethodCall();

    delegate.chooseMediaFromGallery(mockMethodCall, mockResult);

    verifyFinishedWithAlreadyActiveError();
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void
      chooseImageFromGallery_WhenHasExternalStoragePermission_LaunchesChooseFromGalleryIntent() {
    when(mockPermissionManager.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE))
        .thenReturn(true);

    ImagePickerDelegate delegate = createDelegate();
    delegate.chooseImageFromGallery(mockMethodCall, mockResult);

    verify(mockActivity)
        .startActivityForResult(
            any(Intent.class), eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_FROM_GALLERY));
  }

  @Test
  public void takeImageWithCamera_WhenPendingResultExists_FinishesWithAlreadyActiveError() {
    ImagePickerDelegate delegate = createDelegateWithPendingResultAndMethodCall();

    delegate.takeImageWithCamera(mockMethodCall, mockResult);

    verifyFinishedWithAlreadyActiveError();
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void takeImageWithCamera_WhenHasNoCameraPermission_RequestsForPermission() {
    when(mockPermissionManager.isPermissionGranted(Manifest.permission.CAMERA)).thenReturn(false);
    when(mockPermissionManager.needRequestCameraPermission()).thenReturn(true);

    ImagePickerDelegate delegate = createDelegate();
    delegate.takeImageWithCamera(mockMethodCall, mockResult);

    verify(mockPermissionManager)
        .askForPermission(
            Manifest.permission.CAMERA, ImagePickerDelegate.REQUEST_CAMERA_IMAGE_PERMISSION);
  }

  @Test
  public void takeImageWithCamera_WhenCameraPermissionNotPresent_RequestsForPermission() {
    when(mockPermissionManager.needRequestCameraPermission()).thenReturn(false);

    ImagePickerDelegate delegate = createDelegate();
    delegate.takeImageWithCamera(mockMethodCall, mockResult);

    verify(mockActivity)
        .startActivityForResult(
            any(Intent.class), eq(ImagePickerDelegate.REQUEST_CODE_TAKE_IMAGE_WITH_CAMERA));
  }

  @Test
  public void
      takeImageWithCamera_WhenHasCameraPermission_AndAnActivityCanHandleCameraIntent_LaunchesTakeWithCameraIntent() {
    when(mockPermissionManager.isPermissionGranted(Manifest.permission.CAMERA)).thenReturn(true);

    ImagePickerDelegate delegate = createDelegate();
    delegate.takeImageWithCamera(mockMethodCall, mockResult);

    verify(mockActivity)
        .startActivityForResult(
            any(Intent.class), eq(ImagePickerDelegate.REQUEST_CODE_TAKE_IMAGE_WITH_CAMERA));
  }

  @Test
  public void
      takeImageWithCamera_WhenHasCameraPermission_AndNoActivityToHandleCameraIntent_FinishesWithNoCamerasAvailableError() {
    when(mockPermissionManager.isPermissionGranted(Manifest.permission.CAMERA)).thenReturn(true);
    doThrow(ActivityNotFoundException.class)
        .when(mockActivity)
        .startActivityForResult(any(Intent.class), anyInt());
    ImagePickerDelegate delegate = createDelegate();
    delegate.takeImageWithCamera(mockMethodCall, mockResult);

    verify(mockResult)
        .error("no_available_camera", "No cameras available for taking pictures.", null);
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void takeImageWithCamera_WritesImageToCacheDirectory() {
    when(mockPermissionManager.isPermissionGranted(Manifest.permission.CAMERA)).thenReturn(true);

    ImagePickerDelegate delegate = createDelegate();
    delegate.takeImageWithCamera(mockMethodCall, mockResult);

    mockStaticFile.verify(
        () -> File.createTempFile(any(), eq(".jpg"), eq(new File("/image_picker_cache"))),
        times(1));
  }

  @Test
  public void onRequestPermissionsResult_WhenCameraPermissionDenied_FinishesWithError() {
    ImagePickerDelegate delegate = createDelegateWithPendingResultAndMethodCall();

    delegate.onRequestPermissionsResult(
        ImagePickerDelegate.REQUEST_CAMERA_IMAGE_PERMISSION,
        new String[] {Manifest.permission.CAMERA},
        new int[] {PackageManager.PERMISSION_DENIED});

    verify(mockResult).error("camera_access_denied", "The user did not allow camera access.", null);
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void
      onRequestTakeVideoPermissionsResult_WhenCameraPermissionGranted_LaunchesTakeVideoWithCameraIntent() {

    ImagePickerDelegate delegate = createDelegateWithPendingResultAndMethodCall();
    delegate.onRequestPermissionsResult(
        ImagePickerDelegate.REQUEST_CAMERA_VIDEO_PERMISSION,
        new String[] {Manifest.permission.CAMERA},
        new int[] {PackageManager.PERMISSION_GRANTED});

    verify(mockActivity)
        .startActivityForResult(
            any(Intent.class), eq(ImagePickerDelegate.REQUEST_CODE_TAKE_VIDEO_WITH_CAMERA));
  }

  @Test
  public void
      onRequestTakeImagePermissionsResult_WhenCameraPermissionGranted_LaunchesTakeWithCameraIntent() {

    ImagePickerDelegate delegate = createDelegateWithPendingResultAndMethodCall();
    delegate.onRequestPermissionsResult(
        ImagePickerDelegate.REQUEST_CAMERA_IMAGE_PERMISSION,
        new String[] {Manifest.permission.CAMERA},
        new int[] {PackageManager.PERMISSION_GRANTED});

    verify(mockActivity)
        .startActivityForResult(
            any(Intent.class), eq(ImagePickerDelegate.REQUEST_CODE_TAKE_IMAGE_WITH_CAMERA));
  }

  @Test
  public void onActivityResult_WhenPickFromGalleryCanceled_FinishesWithNull() {
    ImagePickerDelegate delegate = createDelegateWithPendingResultAndMethodCall();

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_CHOOSE_FROM_GALLERY, Activity.RESULT_CANCELED, null);

    verify(mockResult).success(null);
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void
      onActivityResult_WhenImagePickedFromGallery_AndNoResizeNeeded_FinishesWithImagePath() {
    ImagePickerDelegate delegate = createDelegateWithPendingResultAndMethodCall();
    when(mockFileUtils.getMimeFromUri(any(), any())).thenReturn("image/png");
    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_CHOOSE_FROM_GALLERY, Activity.RESULT_OK, mockIntent);

    verify(mockResult).success("originalPath");
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void
      onActivityResult_WhenImagePickedFromGallery_AndResizeNeeded_FinishesWithScaledImagePath() {
    when(mockMethodCall.argument("maxWidth")).thenReturn(WIDTH);
    when(mockFileUtils.getMimeFromUri(any(), any())).thenReturn("image/png");
    ImagePickerDelegate delegate = createDelegateWithPendingResultAndMethodCall();
    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_CHOOSE_FROM_GALLERY, Activity.RESULT_OK, mockIntent);

    verify(mockResult).success("scaledPath");
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void
      onActivityResult_WhenVideoPickedFromGallery_AndResizeParametersSupplied_FinishesWithFilePath() {
    when(mockMethodCall.argument("maxWidth")).thenReturn(WIDTH);

    ImagePickerDelegate delegate = createDelegateWithPendingResultAndMethodCall();
    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_CHOOSE_VIDEO_FROM_GALLERY, Activity.RESULT_OK, mockIntent);

    verify(mockResult).success("pathFromUri");
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void onActivityResult_WhenTakeImageWithCameraCanceled_FinishesWithNull() {
    ImagePickerDelegate delegate = createDelegateWithPendingResultAndMethodCall();

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_TAKE_IMAGE_WITH_CAMERA, Activity.RESULT_CANCELED, null);

    verify(mockResult).success(null);
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void onActivityResult_WhenImageTakenWithCamera_AndNoResizeNeeded_FinishesWithImagePath() {
    ImagePickerDelegate delegate = createDelegateWithPendingResultAndMethodCall();

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_TAKE_IMAGE_WITH_CAMERA, Activity.RESULT_OK, mockIntent);

    verify(mockResult).success("originalPath");
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void
      onActivityResult_WhenImageTakenWithCamera_AndResizeNeeded_FinishesWithScaledImagePath() {
    when(mockMethodCall.argument("maxWidth")).thenReturn(WIDTH);

    ImagePickerDelegate delegate = createDelegateWithPendingResultAndMethodCall();
    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_TAKE_IMAGE_WITH_CAMERA, Activity.RESULT_OK, mockIntent);

    verify(mockResult).success("scaledPath");
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void
      onActivityResult_WhenVideoTakenWithCamera_AndResizeParametersSupplied_FinishesWithFilePath() {
    when(mockMethodCall.argument("maxWidth")).thenReturn(WIDTH);

    ImagePickerDelegate delegate = createDelegateWithPendingResultAndMethodCall();
    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_TAKE_VIDEO_WITH_CAMERA, Activity.RESULT_OK, mockIntent);

    verify(mockResult).success("pathFromUri");
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void
      onActivityResult_WhenVideoTakenWithCamera_AndMaxDurationParametersSupplied_FinishesWithFilePath() {
    when(mockMethodCall.argument("maxDuration")).thenReturn(MAX_DURATION);

    ImagePickerDelegate delegate = createDelegateWithPendingResultAndMethodCall();
    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_TAKE_VIDEO_WITH_CAMERA, Activity.RESULT_OK, mockIntent);

    verify(mockResult).success("pathFromUri");
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void
      retrieveLostData_ShouldBeAbleToReturnLastItemFromResultMapWhenSingleFileIsRecovered() {
    Map<String, Object> resultMap = new HashMap<>();
    ArrayList<String> pathList = new ArrayList<>();
    pathList.add("/example/first_item");
    pathList.add("/example/last_item");
    resultMap.put("pathList", pathList);

    when(mockFileUtils.getMimeFromUri(any(), any())).thenReturn("image/png");
    when(mockImageResizer.resizeImageIfNeeded(pathList.get(0), null, null, 100))
        .thenReturn(pathList.get(0));
    when(mockImageResizer.resizeImageIfNeeded(pathList.get(1), null, null, 100))
        .thenReturn(pathList.get(1));
    when(cache.getCacheMap()).thenReturn(resultMap);

    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);

    ImagePickerDelegate mockDelegate = createDelegate();

    ArgumentCaptor<Map<String, Object>> valueCapture = ArgumentCaptor.forClass(Map.class);

    doNothing().when(mockResult).success(valueCapture.capture());

    mockDelegate.retrieveLostData(mockResult);

    assertEquals("/example/last_item", valueCapture.getValue().get("path"));
  }

  private ImagePickerDelegate createDelegate() {
    return new ImagePickerDelegate(
        mockActivity,
        new File("/image_picker_cache"),
        mockImageResizer,
        null,
        null,
        cache,
        mockPermissionManager,
        mockFileUriResolver,
        mockFileUtils);
  }

  private ImagePickerDelegate createDelegateWithPendingResultAndMethodCall() {
    return new ImagePickerDelegate(
        mockActivity,
        new File("/image_picker_cache"),
        mockImageResizer,
        mockResult,
        mockMethodCall,
        cache,
        mockPermissionManager,
        mockFileUriResolver,
        mockFileUtils);
  }

  private void verifyFinishedWithAlreadyActiveError() {
    verify(mockResult).error("already_active", "Image picker is already active", null);
  }

  private class IntentMatcher implements ArgumentMatcher<Intent> {

    private Intent expected;

    public IntentMatcher(Intent expected) {
      this.expected = expected;
    }

    @Override
    public boolean matches(Intent actual) {

      return actual.getAction().equals(expected.getAction())
          && actual.getBooleanExtra(Intent.EXTRA_ALLOW_MULTIPLE, false)
              == expected.getBooleanExtra(Intent.EXTRA_ALLOW_MULTIPLE, false)
          && actual.getType().equals(expected.getType())
          && (actual.getStringArrayExtra(Intent.EXTRA_MIME_TYPES)
                  == actual.getStringArrayExtra(Intent.EXTRA_MIME_TYPES)
              || Arrays.equals(
                  actual.getStringArrayExtra(Intent.EXTRA_MIME_TYPES),
                  expected.getStringArrayExtra(Intent.EXTRA_MIME_TYPES)));
    }
  }
}
