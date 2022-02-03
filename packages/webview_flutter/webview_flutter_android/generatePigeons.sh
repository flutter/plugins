# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

flutter pub run pigeon \
--input pigeons/android_webkit.dart \
--dart_out lib/src/android_webkit/android_webkit.pigeon.dart \
--dart_test_out lib/src/android_webkit/test_android_webkit.pigeon.dart \
--java_out android/src/main/java/io/flutter/plugins/webviewflutterandroid/GeneratedAndroidWebKit.java \
--java_package io.flutter.plugins.webviewflutterandroid
