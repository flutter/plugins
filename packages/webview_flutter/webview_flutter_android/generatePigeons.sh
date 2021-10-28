# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

flutter pub run pigeon \
--input pigeons/android_webview.dart \
--dart_out lib/src/android_webview.pigeon.dart \
--dart_test_out test/android_webview.pigeon.dart \
--java_out android/src/main/java/io/flutter/plugins/webviewflutter/GeneratedAndroidWebView.Java \
--java_package io.flutter.plugins.webviewflutter
