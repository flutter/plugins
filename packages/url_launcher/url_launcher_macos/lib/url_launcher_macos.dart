// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import '../../url_launcher_platform_interface/lib/method_channel_url_launcher.dart';
import '../../url_launcher_platform_interface/lib/url_launcher_platform_interface.dart';

/// The macos implementation of [UrlLauncherPlatform].
/// 
/// This class implements the `package:url_launcher` functionality for macos.
class UrlLauncherPlugin extends UrlLauncherPlatform {
  static void registerWith(Registrar registrar) {
    UrlLauncherPlatform.instance = MethodChannelUrlLauncher();
  }
}