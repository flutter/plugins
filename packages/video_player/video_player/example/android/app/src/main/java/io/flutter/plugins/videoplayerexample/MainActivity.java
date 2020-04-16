// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

<<<<<<< HEAD:packages/connectivity/connectivity_macos/example/android/app/src/main/java/io/flutter/plugins/connectivityexample/MainActivity.java
package io.flutter.plugins.connectivityexample;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.connectivity.ConnectivityPlugin;
=======
package io.flutter.plugins.videoplayerexample;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.videoplayer.VideoPlayerPlugin;
>>>>>>> master:packages/video_player/video_player/example/android/app/src/main/java/io/flutter/plugins/videoplayerexample/MainActivity.java

public class MainActivity extends FlutterActivity {

  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
<<<<<<< HEAD:packages/connectivity/connectivity_macos/example/android/app/src/main/java/io/flutter/plugins/connectivityexample/MainActivity.java
    super.configureFlutterEngine(flutterEngine);
    flutterEngine.getPlugins().add(new ConnectivityPlugin());
=======
    flutterEngine.getPlugins().add(new VideoPlayerPlugin());
>>>>>>> master:packages/video_player/video_player/example/android/app/src/main/java/io/flutter/plugins/videoplayerexample/MainActivity.java
  }
}
