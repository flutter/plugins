// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' show Directory;

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:platform/platform.dart';

const MethodChannel _channel =
    MethodChannel('plugins.flutter.io/path_provider');

Platform _platform = const LocalPlatform();

/// This API is only exposed for the unit tests. It should not be used by
/// any code outside of the plugin itself.
@visibleForTesting
void setMockPathProviderPlatform(Platform platform) {
  _platform = platform;
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
Future<Directory> getTemporaryDirectory() async {
  final String path =
      await _channel.invokeMethod<String>('getTemporaryDirectory');
  if (path == null) {
    return null;
  }
  return Directory(path);
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
Future<Directory> getApplicationSupportDirectory() async {
  final String path =
      await _channel.invokeMethod<String>('getApplicationSupportDirectory');
  if (path == null) {
    return null;
  }

  return Directory(path);
}

/// Path to the directory where application can store files that are persistent,
/// backed up, and not visible to the user, such as sqlite.db.
///
/// On Android, this function throws an [UnsupportedError] as no equivalent
/// path exists.
Future<Directory> getLibraryDirectory() async {
  if (_platform.isAndroid) {
    throw UnsupportedError('Functionality not available on Android');
  }
  final String path =
      await _channel.invokeMethod<String>('getLibraryDirectory');
  if (path == null) {
    return null;
  }
  return Directory(path);
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
Future<Directory> getApplicationDocumentsDirectory() async {
  final String path =
      await _channel.invokeMethod<String>('getApplicationDocumentsDirectory');
  if (path == null) {
    return null;
  }
  return Directory(path);
}

/// Path to a directory where the application may access top level storage.
/// The current operating system should be determined before issuing this
/// function call, as this functionality is only available on Android.
///
/// On iOS, this function throws an [UnsupportedError] as it is not possible
/// to access outside the app's sandbox.
///
/// On Android this uses the `getExternalFilesDir(null)`.
Future<Directory> getExternalStorageDirectory() async {
  if (_platform.isIOS) {
    throw UnsupportedError('Functionality not available on iOS');
  }
  final String path =
      await _channel.invokeMethod<String>('getStorageDirectory');
  if (path == null) {
    return null;
  }
  return Directory(path);
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
Future<List<Directory>> getExternalCacheDirectories() async {
  if (_platform.isIOS) {
    throw UnsupportedError('Functionality not available on iOS');
  }
  final List<String> paths =
      await _channel.invokeListMethod<String>('getExternalCacheDirectories');

  return paths.map((String path) => Directory(path)).toList();
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
Future<List<Directory>> getExternalStorageDirectories({
  /// Optional parameter. See [StorageDirectory] for more informations on
  /// how this type translates to Android storage directories.
  StorageDirectory type,
}) async {
  if (_platform.isIOS) {
    throw UnsupportedError('Functionality not available on iOS');
  }
  final List<String> paths = await _channel.invokeListMethod<String>(
    'getExternalStorageDirectories',
    <String, dynamic>{'type': type?.index},
  );

  return paths.map((String path) => Directory(path)).toList();
}

/// Path to the directory where downloaded files can be stored.
/// This is typically only relevant on desktop operating systems.
///
/// On Android and on iOS, this function throws an [UnsupportedError] as no equivalent
/// path exists.
Future<Directory> getDownloadsDirectory() async {
  if (_platform.isAndroid) {
    throw UnsupportedError('Functionality not available on Android');
  }
  if (_platform.isIOS) {
    throw UnsupportedError('Functionality not available on iOS');
  }
  final String path =
      await _channel.invokeMethod<String>('getDownloadsDirectory');
  if (path == null) {
    return null;
  }
  return Directory(path);
}
