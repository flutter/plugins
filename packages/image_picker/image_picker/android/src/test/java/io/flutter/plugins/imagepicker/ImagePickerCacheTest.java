// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

public class ImagePickerCacheTest {
  //  private static final int IMAGE_QUALITY = 90;
  //
  //  @Mock Activity mockActivity;
  //  @Mock SharedPreferences mockPreference;
  //  @Mock SharedPreferences.Editor mockEditor;
  //  @Mock MethodCall mockMethodCall;
  //
  //  static Map<String, Object> preferenceStorage;
  //
  //  @Before
  //  public void setUp() {
  //    MockitoAnnotations.initMocks(this);
  //
  //    preferenceStorage = new HashMap();
  //    when(mockActivity.getPackageName()).thenReturn("com.example.test");
  //    when(mockActivity.getPackageManager()).thenReturn(mock(PackageManager.class));
  //    when(mockActivity.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE))
  //        .thenReturn(mockPreference);
  //    when(mockPreference.edit()).thenReturn(mockEditor);
  //    when(mockEditor.putInt(any(String.class), any(int.class)))
  //        .then(
  //            i -> {
  //              preferenceStorage.put(i.getArgument(0), i.getArgument(1));
  //              return mockEditor;
  //            });
  //    when(mockEditor.putLong(any(String.class), any(long.class)))
  //        .then(
  //            i -> {
  //              preferenceStorage.put(i.getArgument(0), i.getArgument(1));
  //              return mockEditor;
  //            });
  //    when(mockEditor.putString(any(String.class), any(String.class)))
  //        .then(
  //            i -> {
  //              preferenceStorage.put(i.getArgument(0), i.getArgument(1));
  //              return mockEditor;
  //            });
  //
  //    when(mockPreference.getInt(any(String.class), any(int.class)))
  //        .then(
  //            i -> {
  //              int result =
  //                  (int)
  //                      ((preferenceStorage.get(i.getArgument(0)) != null)
  //                          ? preferenceStorage.get(i.getArgument(0))
  //                          : i.getArgument(1));
  //              return result;
  //            });
  //    when(mockPreference.getLong(any(String.class), any(long.class)))
  //        .then(
  //            i -> {
  //              long result =
  //                  (long)
  //                      ((preferenceStorage.get(i.getArgument(0)) != null)
  //                          ? preferenceStorage.get(i.getArgument(0))
  //                          : i.getArgument(1));
  //              return result;
  //            });
  //    when(mockPreference.getString(any(String.class), any(String.class)))
  //        .then(
  //            i -> {
  //              String result =
  //                  (String)
  //                      ((preferenceStorage.get(i.getArgument(0)) != null)
  //                          ? preferenceStorage.get(i.getArgument(0))
  //                          : i.getArgument(1));
  //              return result;
  //            });
  //
  //    when(mockPreference.contains(any(String.class))).thenReturn(true);
  //  }
  //
  //  @Test
  //  public void ImageCache_ShouldBeAbleToSetAndGetQuality() {
  //    when(mockMethodCall.argument(MAP_KEY_IMAGE_QUALITY)).thenReturn(IMAGE_QUALITY);
  //    ImagePickerCache cache = new ImagePickerCache(mockActivity);
  //    cache.saveDimensionWithMethodCall(mockMethodCall);
  //    Map<String, Object> resultMap = cache.getCacheMap();
  //    int imageQuality = (int) resultMap.get(cache.MAP_KEY_IMAGE_QUALITY);
  //    assertThat(imageQuality, equalTo(IMAGE_QUALITY));
  //
  //    when(mockMethodCall.argument(MAP_KEY_IMAGE_QUALITY)).thenReturn(null);
  //    cache.saveDimensionWithMethodCall(mockMethodCall);
  //    Map<String, Object> resultMapWithDefaultQuality = cache.getCacheMap();
  //    int defaultImageQuality = (int) resultMapWithDefaultQuality.get(cache.MAP_KEY_IMAGE_QUALITY);
  //    assertThat(defaultImageQuality, equalTo(100));
  //  }
  //
  //  @Test
  //  public void ImageCache_ShouldCacheCorrectType() {
  //    ImagePickerCache cache = new ImagePickerCache(mockActivity);
  //    Map<String, String> methodToTypeMap =
  //        new HashMap<String, String>() {
  //          {
  //            put(ImagePickerPlugin.METHOD_CALL_IMAGE, "image");
  //            put(ImagePickerPlugin.METHOD_CALL_MULTI_IMAGE, "image");
  //            put(ImagePickerPlugin.METHOD_CALL_VIDEO, "video");
  //            put(ImagePickerPlugin.METHOD_CALL_IMAGE_OR_VIDEO, "imageOrVideo");
  //            put(ImagePickerPlugin.METHOD_CALL_MULTI_IMAGE_AND_VIDEO, "imageOrVideo");
  //          }
  //        };
  //    methodToTypeMap
  //        .entrySet()
  //        .forEach(
  //            (entry) -> {
  //              cache.saveTypeWithMethodCallName(entry.getKey());
  //              assertEquals(entry.getValue(), preferenceStorage.get("flutter_image_picker_type"));
  //            });
  //  }
}
