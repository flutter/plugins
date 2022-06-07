// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

export 'package:file_selector_platform_interface/file_selector_platform_interface.dart'
    show XFile, XTypeGroup;

/// Opens a file selection dialog and returns the path chosen by the user.
///
/// [acceptedTypeGroups] is a list of file type groups that can be selected in
/// the dialog. How this is displayed depends on the pltaform, for example:
/// - On Windows and Linux, each group will be an entry in a list of filter
///   options.
/// - On macOS, the union of all types allowed by all of the groups will be
///   allowed.
///
/// [initialDirectory] is the full path to the directory that will be displayed
/// when the dialog is opened. When not provided, the platform will pick an
/// initial location.
///
/// [confirmButtonText] is the text in the confirmation button of the dialog.
/// When not provided, the default OS label is used (for example, "Open").
///
/// Returns `null` if the user cancels the operation.
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

/// Open file dialog for loading files and return a list of file paths.
///
/// [acceptedTypeGroups] is the file type that can be selected in the dialog.
/// there are differences in behavior depending on the platform as follows.
/// - Windows: Each group will be an entry in a list of filter options.
/// - macOS: The union of all types allowed by all of the groups will be allowed.
///
/// [initialDirectory] is the full path to the directory that will be displayed
/// when the dialog is opened. When not provided, the platform will pick an
/// initial location.
///
/// [confirmButtonText] is the text in the confirmation button of the dialog.
/// When not provided, the default OS label is used (for example, "Open").
///
/// Returns an empty list if the user cancels the operation.
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

/// Saves File to user's file system.
///
/// [acceptedTypeGroups] is the file type that can be selected in the dialog.
/// There are differences in behavior depending on the platform as follows.
/// - Windows: Each group will be an entry in a list of filter options.
/// - macOS: The union of all types allowed by all of the groups will be allowed.
///
/// [initialDirectory] is the full path to the directory that will be displayed
/// when the dialog is opened. When not provided, the platform will pick an
/// initial location.
///
/// [suggestedName] is initial value of file name.
///
/// [confirmButtonText] is the text in the confirmation button of the dialog.
/// When not provided, the default OS label is used (for example, "Save").
///
/// Returns `null` if the user cancels the operation.
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

/// Gets a directory path from a user's file system.
///
/// [initialDirectory] is the full path to the directory that will be displayed
/// when the dialog is opened. When not provided, the platform will pick an
/// initial location.
///
/// [confirmButtonText] is the text in the confirmation button of the dialog.
/// When not provided, the default OS label is used (for example, "Open").
///
/// Returns `null` if the user cancels the operation.
Future<String?> getDirectoryPath({
  String? initialDirectory,
  String? confirmButtonText,
}) async {
  return FileSelectorPlatform.instance.getDirectoryPath(
      initialDirectory: initialDirectory, confirmButtonText: confirmButtonText);
}
