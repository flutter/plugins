// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

export 'package:file_selector_platform_interface/file_selector_platform_interface.dart'
    show XFile, XTypeGroup;

/// Open file dialog for loading files and return a file path
///
/// The [acceptedTypeGroups] argument is the file type that can be selected in the dialog.
/// When omitted, Open file dialog with all file types.
///
/// The [initialDirectory] argument is directory that will be displayed when the dialog is opened.
/// (NOTICE: specify a directory as a full path, not a relative path.)
/// When omitted, The result of each platform's `getDirectoryPath()` execution is used.
///
/// The [confirmButtonText] argument is the text in the confirmation button of the dialog.
/// When omitted, the wording specified in the OS standard is used.(e.g. open)
///
/// Returns `null` if user cancels the operation.
Future<XFile?> openFile({
  List<XTypeGroup> acceptedTypeGroups = const <XTypeGroup>[],
  String? initialDirectory,
  String? confirmButtonText,
}) {
  return FileSelectorPlatform.instance.openFile(
      acceptedTypeGroups: acceptedTypeGroups,
      initialDirectory: initialDirectory,
      confirmButtonText: confirmButtonText);
}

/// Open file dialog for loading files and return a list of file paths
///
/// The [acceptedTypeGroups] argument is the file type that can be selected in the dialog.
/// When omitted, Open file dialog with all file types.
///
/// The [initialDirectory] argument is directory that will be displayed when the dialog is opened.
/// (NOTICE: specify a directory as a full path, not a relative path.)
/// When omitted, The result of each platform's `getDirectoryPath()` execution is used.
///
/// The [confirmButtonText] argument is the text in the confirmation button of the dialog.
/// When omitted, the wording specified in the OS standard is used.(e.g. open)
Future<List<XFile>> openFiles({
  List<XTypeGroup> acceptedTypeGroups = const <XTypeGroup>[],
  String? initialDirectory,
  String? confirmButtonText,
}) {
  return FileSelectorPlatform.instance.openFiles(
      acceptedTypeGroups: acceptedTypeGroups,
      initialDirectory: initialDirectory,
      confirmButtonText: confirmButtonText);
}

/// Saves File to user's file system
///
/// The [acceptedTypeGroups] argument is the file type that can be selected in the dialog.
/// When omitted, Open file dialog with all file types.
///
/// The [initialDirectory] argument is directory that will be displayed when the dialog is opened.
/// (NOTICE: specify a directory as a full path, not a relative path.)
/// When omitted, The result of each platform's `getDirectoryPath()` execution is used.
///
/// The [suggestedName] argument is he name of the file to save.
/// When omitted, use UUID(version4) as file name.
///
/// The [confirmButtonText] argument is the text in the confirmation button of the dialog.
/// When omitted, the wording specified in the OS standard is used.(e.g. open)
///
/// Returns `null` if user cancels the operation.
Future<String?> getSavePath({
  List<XTypeGroup> acceptedTypeGroups = const <XTypeGroup>[],
  String? initialDirectory,
  String? suggestedName,
  String? confirmButtonText,
}) async {
  return FileSelectorPlatform.instance.getSavePath(
      acceptedTypeGroups: acceptedTypeGroups,
      initialDirectory: initialDirectory,
      suggestedName: suggestedName,
      confirmButtonText: confirmButtonText);
}

/// Gets a directory path from a user's file system
///
/// The [initialDirectory] argument is directory that will be displayed when the dialog is opened.
/// (NOTICE: specify a directory as a full path, not a relative path.)
/// When omitted, The result of each platform's `getDirectoryPath()` execution is used.
///
/// The [confirmButtonText] argument is the text in the confirmation button of the dialog.
/// When omitted, the wording specified in the OS standard is used.(e.g. open)
///
/// Returns `null` if user cancels the operation.
Future<String?> getDirectoryPath({
  String? initialDirectory,
  String? confirmButtonText,
}) async {
  return FileSelectorPlatform.instance.getDirectoryPath(
      initialDirectory: initialDirectory, confirmButtonText: confirmButtonText);
}
