package io.flutter.plugins.imagepicker;

import static org.hamcrest.core.IsEqual.equalTo;
import static org.junit.Assert.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoMoreInteractions;
import static org.mockito.Mockito.when;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.io.File;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

public class ImagePickerDelegateTest {
  private static final double WIDTH = 10.0;
  private static final double HEIGHT = 10.0;

  @Mock Activity mockActivity;
  @Mock ImageResizer mockImageResizer;
  @Mock MethodCall mockMethodCall;
  @Mock MethodChannel.Result mockResult;
  @Mock ImagePickerDelegate.PermissionManager mockPermissionManager;
  @Mock ImagePickerDelegate.IntentResolver mockIntentResolver;
  @Mock FileUtils mockFileUtils;
  @Mock Intent mockIntent;

  ImagePickerDelegate.FileUriResolver mockFileUriResolver;

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

    when(mockActivity.getPackageName()).thenReturn("com.example.test");
    when(mockActivity.getPackageManager()).thenReturn(mock(PackageManager.class));

    when(mockFileUtils.getPathFromUri(any(Context.class), any(Uri.class)))
        .thenReturn("pathFromUri");

    when(mockImageResizer.resizeImageIfNeeded("pathFromUri", null, null))
        .thenReturn("originalPath");
    when(mockImageResizer.resizeImageIfNeeded("pathFromUri", WIDTH, HEIGHT))
        .thenReturn("scaledPath");
    when(mockImageResizer.resizeImageIfNeeded("pathFromUri", WIDTH, null)).thenReturn("scaledPath");
    when(mockImageResizer.resizeImageIfNeeded("pathFromUri", null, HEIGHT))
        .thenReturn("scaledPath");

    mockFileUriResolver = new MockFileUriResolver();

    Uri mockUri = mock(Uri.class);
    when(mockIntent.getData()).thenReturn(mockUri);
  }

  @Test
  public void whenConstructed_setsCorrectFileProviderName() {
    ImagePickerDelegate delegate = createDelegate();
    assertThat(delegate.fileProviderName, equalTo("com.example.test.flutter.image_provider"));
  }

  @Test
  public void chooseImageFromGallery_WhenPendingResultExists_FinishesWithAlreadyActiveError() {
    ImagePickerDelegate delegate = createDelegateWithPendingResultAndMethodCall();

    delegate.chooseImageFromGallery(mockMethodCall, mockResult);

    verifyFinishedWithAlreadyActiveError();
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void chooseImageFromGallery_WhenHasNoExternalStoragePermission_RequestsForPermission() {
    when(mockPermissionManager.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE))
        .thenReturn(false);

    ImagePickerDelegate delegate = createDelegate();
    delegate.chooseImageFromGallery(mockMethodCall, mockResult);

    verify(mockPermissionManager)
        .askForPermission(
            Manifest.permission.READ_EXTERNAL_STORAGE,
            ImagePickerDelegate.REQUEST_EXTERNAL_IMAGE_STORAGE_PERMISSION);
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
            any(Intent.class), eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY));
  }

  @Test
  public void takeImageWithCamera_WhenPendingResultExists_FinishesWithAlreadyActiveError() {
    ImagePickerDelegate delegate = createDelegateWithPendingResultAndMethodCall();

    delegate.takeImageWithCamera(mockMethodCall, mockResult);

    verifyFinishedWithAlreadyActiveError();
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void
      onRequestPermissionsResult_WhenReadExternalStoragePermissionDenied_FinishesWithNull() {
    ImagePickerDelegate delegate = createDelegateWithPendingResultAndMethodCall();

    delegate.onRequestPermissionsResult(
        ImagePickerDelegate.REQUEST_EXTERNAL_IMAGE_STORAGE_PERMISSION,
        new String[] {Manifest.permission.READ_EXTERNAL_STORAGE},
        new int[] {PackageManager.PERMISSION_DENIED});

    verify(mockResult).success(null);
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void
      onRequestChooseImagePermissionsResult_WhenReadExternalStorageGranted_LaunchesChooseImageFromGalleryIntent() {
    ImagePickerDelegate delegate = createDelegateWithPendingResultAndMethodCall();

    delegate.onRequestPermissionsResult(
        ImagePickerDelegate.REQUEST_EXTERNAL_IMAGE_STORAGE_PERMISSION,
        new String[] {Manifest.permission.READ_EXTERNAL_STORAGE},
        new int[] {PackageManager.PERMISSION_GRANTED});

    verify(mockActivity)
        .startActivityForResult(
            any(Intent.class), eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY));
  }

  @Test
  public void
      onRequestChooseVideoPermissionsResult_WhenReadExternalStorageGranted_LaunchesChooseVideoFromGalleryIntent() {
    ImagePickerDelegate delegate = createDelegateWithPendingResultAndMethodCall();

    delegate.onRequestPermissionsResult(
        ImagePickerDelegate.REQUEST_EXTERNAL_VIDEO_STORAGE_PERMISSION,
        new String[] {Manifest.permission.READ_EXTERNAL_STORAGE},
        new int[] {PackageManager.PERMISSION_GRANTED});

    verify(mockActivity)
        .startActivityForResult(
            any(Intent.class), eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_VIDEO_FROM_GALLERY));
  }

  @Test
  public void onActivityResult_WhenPickFromGalleryCanceled_FinishesWithNull() {
    ImagePickerDelegate delegate = createDelegateWithPendingResultAndMethodCall();

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY, Activity.RESULT_CANCELED, null);

    verify(mockResult).success(null);
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void
      onActivityResult_WhenImagePickedFromGallery_AndNoResizeNeeded_FinishesWithImagePath() {
    ImagePickerDelegate delegate = createDelegateWithPendingResultAndMethodCall();

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY, Activity.RESULT_OK, mockIntent);

    verify(mockResult).success("originalPath");
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void
      onActivityResult_WhenImagePickedFromGallery_AndResizeNeeded_FinishesWithScaledImagePath() {
    when(mockMethodCall.argument("maxWidth")).thenReturn(WIDTH);

    ImagePickerDelegate delegate = createDelegateWithPendingResultAndMethodCall();
    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY, Activity.RESULT_OK, mockIntent);

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

  private ImagePickerDelegate createDelegate() {
    return new ImagePickerDelegate(
        mockActivity,
        null,
        mockImageResizer,
        null,
        null,
        mockPermissionManager,
        mockIntentResolver,
        mockFileUriResolver,
        mockFileUtils);
  }

  private ImagePickerDelegate createDelegateWithPendingResultAndMethodCall() {
    return new ImagePickerDelegate(
        mockActivity,
        null,
        mockImageResizer,
        mockResult,
        mockMethodCall,
        mockPermissionManager,
        mockIntentResolver,
        mockFileUriResolver,
        mockFileUtils);
  }

  private void verifyFinishedWithAlreadyActiveError() {
    verify(mockResult).error("already_active", "Image picker is already active", null);
  }
}
