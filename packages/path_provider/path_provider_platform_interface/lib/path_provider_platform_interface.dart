import 'dart:async';
import 'dart:io' show Directory;

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel_path_provider.dart';

/// The interface that implementations of path_provider must implement.
///
/// Platform implementations should extend this class rather than implement it as `path_provider`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [PathProviderPlatform] methods.
abstract class PathProviderPlatform extends PlatformInterface {
  /// Constructs a PathProviderPlatform.
  PathProviderPlatform() : super(token: _token);

  static final Object _token = Object();

  static PathProviderPlatform _instance = MethodChannelPathProvider();

  /// The default instance of [PathProviderPlatform] to use.
  ///
  /// Defaults to [MethodChannelPathProvider].
  static PathProviderPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [PathProviderPlatform] when they register themselves.
  static set instance(PathProviderPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Path to the temporary directory on the device that is not backed up and is
  /// suitable for storing caches of downloaded files.
  ///
  /// Files in this directory may be cleared at any time. This does *not* return
  /// a new temporary directory. Instead, the caller is responsible for creating
  /// (and cleaning up) files or directories within this directory. This
  /// directory is scoped to the calling application.
  ///
  /// On iOS, this uses the `NSCachesDirectory` API.
  ///
  /// On Android, this uses the `getCacheDir` API on the context.
  Future<String> getTemporaryDirectory() {
    throw UnimplementedError('getTemporaryDirectory() has not been implemented.');
  }

  /// Path to a directory where the application may place application support
  /// files.
  ///
  /// Use this for files you don’t want exposed to the user. Your app should not
  /// use this directory for user data files.
  ///
  /// On iOS, this uses the `NSApplicationSupportDirectory` API.
  /// If this directory does not exist, it is created automatically.
  ///
  /// On Android, this function uses the `getFilesDir` API on the context.
  Future<String> getApplicationSupportDirectory() {
    throw UnimplementedError('getApplicationSupportDirectory() has not been implemented.');
  }

  /// Path to the directory where application can store files that are persistent,
  /// backed up, and not visible to the user, such as sqlite.db.
  ///
  /// On Android, this function throws an [UnsupportedError] as no equivalent
  /// path exists.

  Future<String> getLibraryDirectory() {
    throw UnimplementedError('getLibraryDirectory() has not been implemented.');
  }

  /// Path to a directory where the application may place data that is
  /// user-generated, or that cannot otherwise be recreated by your application.
  ///
  /// On iOS, this uses the `NSDocumentDirectory` API. Consider using
  /// [getApplicationSupportDirectory] instead if the data is not user-generated.
  ///
  /// On Android, this uses the `getDataDirectory` API on the context. Consider
  /// using [getExternalStorageDirectory] instead if data is intended to be visible
  /// to the user.
  Future<String> getApplicationDocumentsDirectory() {
    throw UnimplementedError('getApplicationDocumentsDirectory() has not been implemented.');
  }

  /// Path to a directory where the application may access top level storage.
  /// The current operating system should be determined before issuing this
  /// function call, as this functionality is only available on Android.
  ///
  /// On iOS, this function throws an [UnsupportedError] as it is not possible
  /// to access outside the app's sandbox.
  ///
  /// On Android this uses the `getExternalFilesDir(null)`.
  Future<String> getExternalStorageDirectory() {
    throw UnimplementedError('getExternalStorageDirectory() has not been implemented.');
  }

  /// Paths to directories where application specific external cache data can be
  /// stored. These paths typically reside on external storage like separate
  /// partitions or SD cards. Phones may have multiple storage directories
  /// available.
  ///
  /// The current operating system should be determined before issuing this
  /// function call, as this functionality is only available on Android.
  ///
  /// On iOS, this function throws an UnsupportedError as it is not possible
  /// to access outside the app's sandbox.
  ///
  /// On Android this returns Context.getExternalCacheDirs() or
  /// Context.getExternalCacheDir() on API levels below 19.
  Future<List<String>> getExternalCacheDirectories() {
    throw UnimplementedError('getExternalCacheDirectories() has not been implemented.');
  }

  /// Paths to directories where application specific data can be stored.
  /// These paths typically reside on external storage like separate partitions
  /// or SD cards. Phones may have multiple storage directories available.
  ///
  /// The current operating system should be determined before issuing this
  /// function call, as this functionality is only available on Android.
  ///
  /// On iOS, this function throws an UnsupportedError as it is not possible
  /// to access outside the app's sandbox.
  ///
  /// On Android this returns Context.getExternalFilesDirs(String type) or
  /// Context.getExternalFilesDir(String type) on API levels below 19.
  Future<List<String>> getExternalStorageDirectories({
    /// Optional parameter. See [StorageDirectory] for more informations on
    /// how this type translates to Android storage directories.
    StorageDirectory type,
  }) {
    throw UnimplementedError('getExternalCacheDirectories() has not been implemented.');
  }

  /// Path to the directory where downloaded files can be stored.
  /// This is typically only relevant on desktop operating systems.
  ///
  /// On Android and on iOS, this function throws an [UnsupportedError] as no equivalent
  /// path exists.
  Future<String> getDownloadsDirectory() {
    throw UnimplementedError('getDownloadsDirectory() has not been implemented.');
  }
}

/// Corresponds to constants defined in Androids `android.os.Environment` class.
///
/// https://developer.android.com/reference/android/os/Environment.html#fields_1
enum StorageDirectory {
  /// Contains audio files that should be treated as music.
  ///
  /// See https://developer.android.com/reference/android/os/Environment.html#DIRECTORY_MUSIC.
  music,

  /// Contains audio files that should be treated as podcasts.
  ///
  /// See https://developer.android.com/reference/android/os/Environment.html#DIRECTORY_PODCASTS.
  podcasts,

  /// Contains audio files that should be treated as ringtones.
  ///
  /// See https://developer.android.com/reference/android/os/Environment.html#DIRECTORY_RINGTONES.
  ringtones,

  /// Contains audio files that should be treated as alarm sounds.
  ///
  /// See https://developer.android.com/reference/android/os/Environment.html#DIRECTORY_ALARMS.
  alarms,

  /// Contains audio files that should be treated as notification sounds.
  ///
  /// See https://developer.android.com/reference/android/os/Environment.html#DIRECTORY_NOTIFICATIONS.
  notifications,

  /// Contains images. See https://developer.android.com/reference/android/os/Environment.html#DIRECTORY_PICTURES.
  pictures,

  /// Contains movies. See https://developer.android.com/reference/android/os/Environment.html#DIRECTORY_MOVIES.
  movies,

  /// Contains files of any type that have been downloaded by the user.
  ///
  /// See https://developer.android.com/reference/android/os/Environment.html#DIRECTORY_DOWNLOADS.
  downloads,

  /// Used to hold both pictures and videos when the device filesystem is
  /// treated like a camera's.
  ///
  /// See https://developer.android.com/reference/android/os/Environment.html#DIRECTORY_DCIM.
  dcim,

  /// Holds user-created documents. See https://developer.android.com/reference/android/os/Environment.html#DIRECTORY_DOCUMENTS.
  documents,
}
