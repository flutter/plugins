// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';

/// Gets message from platform implementation
Future<String> getMessage() async {
  final String result = await FilePickerPlatform.instance.getMessage();
  return result;
}

